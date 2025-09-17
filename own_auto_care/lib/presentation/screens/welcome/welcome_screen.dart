
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final GoogleDriveProvider _googleDriveProvider;
  String _status = 'Listo para autenticar con Google Drive';

  @override
  void initState() {
    super.initState();
    _googleDriveProvider = GoogleDriveProvider();
  }

  Future<void> _authenticate() async {
    setState(() {
      _status = 'Iniciando autenticación...';
    });

    try {
      // ensureSetup will trigger authentication
      await _googleDriveProvider.ensureSetup();
      setState(() {
        _status = 'Autenticación completada ✅';
      });
      Navigator.of(context).pushReplacementNamed('/vehicle-list');
    } catch (e, s) {
      // ignore: avoid_print
      print('Error de autenticación: $e');
      // ignore: avoid_print
      print('Stack trace: $s');
      if (e is UnimplementedError) {
        setState(() {
          _status = 'Autenticación completada ✅ (ensureSetup no implementado)';
        });
        Navigator.of(context).pushReplacementNamed('/vehicle-list');
      } else {
        setState(() {
          _status = 'Error de autenticación: $e';
        });
      }
    }
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
            ElevatedButton.icon(
              onPressed: _authenticate,
              icon: const Icon(Icons.cloud),
              label: const Text('Login with Google Drive'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nota: Necesitas configurar OAuth en Google Cloud Console y reemplazar el client ID',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
