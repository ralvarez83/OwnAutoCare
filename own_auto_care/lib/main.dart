import 'package:flutter/material.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/infrastructure/repositories/vehicle_repository_impl.dart';
import 'package:own_auto_care/infrastructure/repositories/service_record_repository_impl.dart';
import 'package:own_auto_care/presentation/screens/vehicle_list/vehicle_list_screen.dart';
import 'package:own_auto_care/presentation/screens/welcome/welcome_screen.dart';
import 'package:own_auto_care/shared/navigation/app_navigator.dart';

void main() {
  final googleDriveProvider = GoogleDriveProvider();
  final vehicleRepository = VehicleRepositoryImpl(googleDriveProvider);
  final serviceRecordRepository = ServiceRecordRepositoryImpl(googleDriveProvider);

  runApp(MyApp(
    vehicleRepository: vehicleRepository,
    serviceRecordRepository: serviceRecordRepository,
    googleDriveProvider: googleDriveProvider,
  ));
}

class MyApp extends StatelessWidget {
  final VehicleRepositoryImpl vehicleRepository;
  final ServiceRecordRepositoryImpl serviceRecordRepository;
  final GoogleDriveProvider googleDriveProvider;

  const MyApp({
    super.key,
    required this.vehicleRepository,
    required this.serviceRecordRepository,
    required this.googleDriveProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppNavigator.navigatorKey,
      title: 'OwnAutoCare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(googleDriveProvider: googleDriveProvider),
        '/vehicle-list': (context) => VehicleListScreen(
              vehicleRepository: vehicleRepository,
              serviceRecordRepository: serviceRecordRepository,
              googleDriveProvider: googleDriveProvider,
            ),
      },
    );
  }
}
