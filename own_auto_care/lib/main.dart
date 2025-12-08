import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';
import 'package:own_auto_care/presentation/theme/app_theme.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/infrastructure/repositories/vehicle_repository_impl.dart';
import 'package:own_auto_care/infrastructure/repositories/service_record_repository_impl.dart';
import 'package:own_auto_care/infrastructure/repositories/reminder_repository_impl.dart';
import 'package:own_auto_care/presentation/screens/vehicle_list/vehicle_list_screen.dart';
import 'package:own_auto_care/presentation/screens/welcome/welcome_screen.dart';
import 'package:own_auto_care/shared/navigation/app_navigator.dart';
import 'package:own_auto_care/shared/locale/locale_detector.dart';

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

class MyApp extends StatefulWidget {
  final VehicleRepositoryImpl vehicleRepository;
  final ServiceRecordRepositoryImpl serviceRecordRepository;
  final ReminderRepositoryImpl reminderRepository;
  final GoogleDriveProvider googleDriveProvider;

  const MyApp({
    super.key,
    required this.vehicleRepository,
    required this.serviceRecordRepository,
    required this.reminderRepository,
    required this.googleDriveProvider,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAuthenticated = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      // Check if user is already authenticated
      final currentUser = await widget.googleDriveProvider.getCurrentUser();
      
      if (mounted) {
        setState(() {
          _isAuthenticated = currentUser != null;
          _isCheckingAuth = false;
        });
      }
    } catch (e) {
      // If there's any error checking authentication, show welcome screen
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isCheckingAuth = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading screen while checking authentication
    if (_isCheckingAuth) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
        ],
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

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
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        if (locale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        
        // Fallback: Check browser/system language (for web compatibility)
        // In web, we can also check the platform's locale hints
        // For now, default to English if not found
        return supportedLocales.first; // English
      },
      home: _isAuthenticated 
          ? VehicleListScreen(
              vehicleRepository: widget.vehicleRepository,
              serviceRecordRepository: widget.serviceRecordRepository,
              reminderRepository: widget.reminderRepository,
              googleDriveProvider: widget.googleDriveProvider,
            )
          : WelcomeScreen(googleDriveProvider: widget.googleDriveProvider),
      routes: {
        '/vehicle-list': (context) => VehicleListScreen(
              vehicleRepository: widget.vehicleRepository,
              serviceRecordRepository: widget.serviceRecordRepository,
              reminderRepository: widget.reminderRepository,
              googleDriveProvider: widget.googleDriveProvider,
            ),
      },
    );
  }
}
