import 'package:flutter/material.dart';
import 'navScreen.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final latController = TextEditingController();
  final lonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Flutter Uber'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:  [
            const Text(
              'Enter your location',
              style: TextStyle(fontSize: 30,
              fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: latController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Latitude',
              ),
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: lonController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Longitude',
              ),
            ),
            const SizedBox(height: 20,),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NavScreen(
                            double.parse(latController.text),
                            double.parse(lonController.text))));
                  },
                  child: const Text('Get Directions')),
            ),
          ],
        ),
      ),
    );
  }
}

// App Features
// Provide destination Latitude and Longitude.
// Show markers for source and destination locations.
// Draw polyline for the closest path between source and destination.
// Navigate destination to google map app and use route direction.