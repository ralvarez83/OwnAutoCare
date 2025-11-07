
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/presentation/widgets/auth_button.dart';

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
  String _status = 'Listo para autenticar con Google Drive';

  void _onAuthenticated() {
    Navigator.of(context).pushReplacementNamed('/vehicle-list');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to OwnAutoCare'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '🚗 OwnAutoCare',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
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
    );
  }
}
