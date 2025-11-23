import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';
import 'package:own_auto_care/presentation/theme/app_theme.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/infrastructure/repositories/vehicle_repository_impl.dart';
import 'package:own_auto_care/infrastructure/repositories/service_record_repository_impl.dart';
import 'package:own_auto_care/infrastructure/repositories/reminder_repository_impl.dart'; // Import ReminderRepositoryImpl
import 'package:own_auto_care/presentation/screens/vehicle_list/vehicle_list_screen.dart';
import 'package:own_auto_care/presentation/screens/welcome/welcome_screen.dart';
import 'package:own_auto_care/shared/navigation/app_navigator.dart';

void main() {
  final googleDriveProvider = GoogleDriveProvider();
  final vehicleRepository = VehicleRepositoryImpl(googleDriveProvider);
  final serviceRecordRepository = ServiceRecordRepositoryImpl(googleDriveProvider);
  final reminderRepository = ReminderRepositoryImpl(googleDriveProvider); // Instantiate ReminderRepositoryImpl

  runApp(MyApp(
    vehicleRepository: vehicleRepository,
    serviceRecordRepository: serviceRecordRepository,
    reminderRepository: reminderRepository, // Pass reminderRepository
    googleDriveProvider: googleDriveProvider,
  ));
}

class MyApp extends StatelessWidget {
  final VehicleRepositoryImpl vehicleRepository;
  final ServiceRecordRepositoryImpl serviceRecordRepository;
  final ReminderRepositoryImpl reminderRepository; // Add reminderRepository to MyApp
  final GoogleDriveProvider googleDriveProvider;

  const MyApp({
    super.key,
    required this.vehicleRepository,
    required this.serviceRecordRepository,
    required this.reminderRepository,
    required this.googleDriveProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppNavigator.navigatorKey,
      title: 'OwnAutoCare',
      theme: AppTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(googleDriveProvider: googleDriveProvider),
        '/vehicle-list': (context) => VehicleListScreen(
              vehicleRepository: vehicleRepository,
              serviceRecordRepository: serviceRecordRepository,
              reminderRepository: reminderRepository, // Pass reminderRepository
              googleDriveProvider: googleDriveProvider,
            ),
      },
    );
  }
}
