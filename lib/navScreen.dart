import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_navigation/api/api_key.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show sqrt, cos, asin;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';

class NavScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const NavScreen(this.latitude, this.longitude, {super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  final _controller = Completer<GoogleMapController>();
  final polylinePoints = PolylinePoints();
  final location = Location();
  LatLng curLocation = const LatLng(23.0525, 72.5667);
  Marker? sourcePosition, destinationPosition;
  loc.LocationData? _currentPosition;
  StreamSubscription<loc.LocationData>? locationSubscription;
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNavigation();
    addMarker();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }

  getNavigation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    final controller = await _controller.future;
    location.changeSettings(accuracy: loc.LocationAccuracy.high);
    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        return;
      }
    }

    if (_permissionGranted == loc.PermissionStatus.granted) {
      _currentPosition = await location.getLocation();
      curLocation =
          LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
      locationSubscription =
          location.onLocationChanged.listen((LocationData currentLocation) {
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
                _currentPosition!.latitude!, _currentPosition!.longitude!),
            zoom: 16)));
        if (mounted) {
          controller
              ?.showMarkerInfoWindow(MarkerId(sourcePosition!.markerId.value));
          setState(() {
            curLocation =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
            sourcePosition = Marker(
              markerId: MarkerId(currentLocation.toString()),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              position:
              LatLng(currentLocation.latitude!, currentLocation.longitude!),
              infoWindow: InfoWindow(
                  title: '${double.parse(
                      (getDistance(LatLng(widget.latitude, widget.longitude))
                          .toStringAsFixed(2)))} km'
              ),
              onTap: () {
                print('market tapped');
              },
            );
          });
          getDirections(LatLng(widget.latitude, widget.longitude));
        }
      });
    }
  }

  getDirections(LatLng distance) async{
    List<LatLng> polylineCoordinates = [];
    List<dynamic> points = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(APIKEY, PointLatLng(curLocation.latitude, curLocation.longitude),
      PointLatLng(distance.latitude, distance.longitude), travelMode: TravelMode.driving);
    if (result.points.isNotEmpty){
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        points.add({'lat': point.latitude, 'lon': point.longitude});
      });
    } else {
      if (kDebugMode) {
        print(result.errorMessage);
      }
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> coordinates){
    // Polyline id = PolylineId('poly');
  }

  double getDistance(LatLng disPosition){
    return calculateDistance(curLocation.latitude, curLocation.longitude,
        disPosition.latitude, disPosition.longitude);
  }
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  addMarker() {
    setState(() {
      sourcePosition = Marker(
          markerId: const MarkerId('source'),
          position: curLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure));

      destinationPosition = Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(widget.latitude, widget.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueMagenta));
    });
  }
}
