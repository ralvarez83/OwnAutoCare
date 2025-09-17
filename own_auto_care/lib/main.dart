import 'package:flutter/material.dart';
import 'package:own_auto_care/presentation/screens/add_vehicle/add_vehicle_screen.dart';
import 'package:own_auto_care/presentation/screens/vehicle_list/vehicle_list_screen.dart';
import 'package:own_auto_care/presentation/screens/welcome/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OwnAutoCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      routes: {
        '/vehicle-list': (context) => const VehicleListScreen(),
        '/add-vehicle': (context) => const AddVehicleScreen(),
      },
    );
  }
}
