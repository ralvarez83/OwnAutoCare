import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'web_view_registry.dart' as web_registry;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/secrets.dart';

/// Web implementation: try to render the native Google Identity Services button
/// using `google.accounts.id.renderButton`. If the `google` API is not
/// available for any reason, fallback to the regular `SignInButton` which
/// calls the existing auth flow.
class AuthButton extends StatefulWidget {
  final GoogleDriveProvider googleDriveProvider;
  final VoidCallback onAuthenticated;

  const AuthButton({super.key, required this.googleDriveProvider, required this.onAuthenticated});

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  late final String _viewId;
  html.EventListener? _messageListener;

  @override
  void initState() {
    super.initState();
    _viewId = 'g_signin_${DateTime.now().millisecondsSinceEpoch}';

    // Register a platform view for the div that will hold the Google button.
    web_registry.registerViewFactory(_viewId, (int viewId) {
      final el = html.DivElement()..id = _viewId;
      return el;
    });

    // Listen for messages posted from the google.accounts callback.
    _messageListener = (html.Event e) {
      if (e is html.MessageEvent) {
        final data = e.data;
        try {
          // Expecting an object with a 'credential' field (the ID token)
          final token = (data is Map && data['credential'] != null) ? data['credential'] : null;
          if (token != null) {
            _onTokenReceived(token as String);
          }
        } catch (_) {
          // ignore parsing errors
        }
      }
    };
    html.window.addEventListener('message', _messageListener!);

    // Try to initialize and render the button if google.accounts exists.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryRenderNativeButton();
    });
  }

  Future<void> _onTokenReceived(String credential) async {
    try {
      await widget.googleDriveProvider.authenticateWithToken(credential);
      widget.onAuthenticated();
    } catch (e) {
      // If token flow fails, leave fallback available.
    }
  }

  void _tryRenderNativeButton() {
    try {
      final google = js_util.getProperty(html.window, 'google');
      if (google == null) return;
      final accounts = js_util.getProperty(google, 'accounts');
      if (accounts == null) return;

      // Initialize the Google Identity Services client and render the button
      // The callback will post a message to window which we listen for.
      final callback = js.allowInterop((response) {
        try {
          // Post the whole response (contains 'credential') to the window
          html.window.postMessage(response, html.window.location.origin ?? '*');
        } catch (_) {}
      });

      js_util.callMethod(js_util.getProperty(accounts, 'id'), 'initialize', [
        js_util.jsify({
          'client_id': googleClientId,
          'callback': callback,
        })
      ]);

      // Render the button inside our div
      final div = html.document.getElementById(_viewId);
      if (div != null) {
        js_util.callMethod(js_util.getProperty(accounts, 'id'), 'renderButton', [
          div,
          js_util.jsify({
            'theme': 'outline',
            'size': 'large',
          })
        ]);
      }
    } catch (e) {
      // If anything fails, we'll rely on the fallback SignInButton below.
    }
  }

  @override
  void dispose() {
    if (_messageListener != null) html.window.removeEventListener('message', _messageListener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If not web (defensive), return the normal button.
    if (!kIsWeb) {
      return SignInButton(
        Buttons.Google,
        onPressed: () async {
          await widget.googleDriveProvider.authenticate();
          widget.onAuthenticated();
        },
      );
    }

    // On web: show the HtmlElementView where GSI will render the native button.
    // Also provide a fallback button below in case rendering fails or user prefers it.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 240,
          height: 48,
          child: HtmlElementView(viewType: _viewId),
        ),
        const SizedBox(height: 8),
        SignInButton(
          Buttons.Google,
          onPressed: () async {
            // Fallback: call existing flow (may show deprecation warning in console)
            try {
              await widget.googleDriveProvider.authenticate();
              widget.onAuthenticated();
            } catch (_) {
              // ignore
            }
          },
        ),
      ],
    );
  }
}
