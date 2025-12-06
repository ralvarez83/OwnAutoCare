import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';

class AuthButton extends StatelessWidget {
  final GoogleDriveProvider googleDriveProvider;
  final VoidCallback onAuthenticated;

  const AuthButton({super.key, required this.googleDriveProvider, required this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return SignInButton(
      Buttons.Google,
      onPressed: () async {
        try {
          print('AuthButton: Starting authentication...');
          await googleDriveProvider.authenticate();
          print('AuthButton: Authentication successful!');
          onAuthenticated();
        } catch (e) {
          print('AuthButton: Authentication error: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al iniciar sesión: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }
}
