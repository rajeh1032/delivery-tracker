import 'package:flutter/material.dart';

void main() {
  runApp(const DeliveryTrackerApp());
}

class DeliveryTrackerApp extends StatelessWidget {
  const DeliveryTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Delivery Tracker Ready'),
        ),
      ),
    );
  }
}
