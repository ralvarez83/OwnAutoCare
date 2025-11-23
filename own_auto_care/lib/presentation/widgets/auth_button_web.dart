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

  @override
  void initState() {
    super.initState();
    _viewId = 'g_signin_${DateTime.now().millisecondsSinceEpoch}';

    // Register a platform view for the div that will hold the Google button.
    web_registry.registerViewFactory(_viewId, (int viewId) {
      final el = html.DivElement()..id = _viewId;
      return el;
    });

    // Try to initialize and render the button if google.accounts exists.
    // Also retry after short delays in case the GSI script loads later.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryRenderNativeButton();
    });
    Future.delayed(const Duration(milliseconds: 500), _tryRenderNativeButton);
    Future.delayed(const Duration(seconds: 1), _tryRenderNativeButton);
    Future.delayed(const Duration(seconds: 2), _tryRenderNativeButton);
  }

  Future<void> _onTokenReceived(dynamic response) async {
    try {
      if (kDebugMode) {
        print('AuthButton: _onTokenReceived called with response type: ${response.runtimeType}');
      }
      
      // OAuth2 response is a JavaScript object, use js_util to extract access_token
      String? accessToken;
      try {
        accessToken = js_util.getProperty(response, 'access_token') as String?;
      } catch (e) {
        if (kDebugMode) {
          print('AuthButton: Error getting access_token: $e');
        }
      }
      
      if (kDebugMode) {
        print('AuthButton: Extracted access token: ${accessToken != null ? "yes (${accessToken.substring(0, 20)}...)" : "null"}');
      }
      
      if (accessToken != null && accessToken.isNotEmpty) {
        if (kDebugMode) {
          print('AuthButton: Received access token, authenticating...');
        }
        await widget.googleDriveProvider.authenticateWithToken(accessToken);
        widget.onAuthenticated();
      } else {
        throw 'No access token in response';
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthButton: Token handling error: $e');
      }
      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _tryRenderNativeButton() {
    try {
      final google = js_util.getProperty(html.window, 'google');
      if (google == null) return;
      final accounts = js_util.getProperty(google, 'accounts');
      if (accounts == null) return;
      final oauth2 = js_util.getProperty(accounts, 'oauth2');
      if (oauth2 == null) return;

      // Use OAuth2 Token Client for proper access token (not just ID token)
      final callback = js.allowInterop((response) {
        try {
          if (kDebugMode) {
            print('OAuth2 callback received: $response');
          }
          // Call _onTokenReceived directly with the response
          _onTokenReceived(response);
        } catch (e) {
          if (kDebugMode) {
            print('OAuth2 callback error: $e');
          }
        }
      });

      // Initialize OAuth2 token client
      final tokenClient = js_util.callMethod(oauth2, 'initTokenClient', [
        js_util.jsify({
          'client_id': googleClientId,
          'scope': widget.googleDriveProvider.scopes.join(' '),
          'callback': callback,
        })
      ]);

      // Create a custom button that triggers the OAuth flow
      final div = html.document.getElementById(_viewId);
      if (div != null) {
        (div as html.HtmlElement).innerHtml = '';
        final button = html.ButtonElement()
          ..className = 'gsi-material-button'
          ..text = '🔐 Sign in with Google'
          ..onClick.listen((_) {
            // Request access token
            js_util.callMethod(tokenClient, 'requestAccessToken', []);
          });
        
        div.append(button);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error rendering OAuth button: $e');
      }
      // If anything fails, we'll rely on the fallback SignInButton below.
    }
  }

  @override
  void dispose() {
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

    // On web: show only the OAuth2 button (HtmlElementView)
    return SizedBox(
      width: 240,
      height: 48,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
