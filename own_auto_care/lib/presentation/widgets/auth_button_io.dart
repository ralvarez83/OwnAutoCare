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
        await googleDriveProvider.authenticate();
        onAuthenticated();
      },
    );
  }
}
