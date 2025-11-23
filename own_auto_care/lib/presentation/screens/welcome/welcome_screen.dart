import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/presentation/widgets/auth_button.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  final GoogleDriveProvider googleDriveProvider;
  /// Optional builder used to create the auth button. This makes the
  /// WelcomeScreen easier to test by allowing tests to inject a simple
  /// stub widget instead of rendering platform-specific buttons.
  final Widget Function(GoogleDriveProvider provider, VoidCallback onAuthenticated)? authButtonBuilder;

  const WelcomeScreen({
    super.key,
    required this.googleDriveProvider,
    this.authButtonBuilder,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isAuthenticating = false;

  void _onAuthenticated() {
    setState(() => _isAuthenticating = true);
    // Slight delay to show loading animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/vehicle-list');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // App Logo/Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // App Title
                  Text(
                    'OwnAutoCare',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    l10n.welcomeScreenTitle,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_sync,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.readyToAuthenticate,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Auth Button or Loading
                  if (_isAuthenticating)
                    Column(
                      children: [
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Signing in...',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    )
                  else
                    // Use the injected builder when provided (tests), otherwise
                    // fall back to the real `AuthButton` implementation.
                    widget.authButtonBuilder != null
                        ? widget.authButtonBuilder!(widget.googleDriveProvider, _onAuthenticated)
                        : AuthButton(
                            googleDriveProvider: widget.googleDriveProvider,
                            onAuthenticated: _onAuthenticated,
                          ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
