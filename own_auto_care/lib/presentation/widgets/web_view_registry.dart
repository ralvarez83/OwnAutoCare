// Conditional shim to register platform view factories only on the web.
// This file uses conditional imports so references to `ui.platformViewRegistry`
// are only seen by the web compiler.
export 'web_view_registry_stub.dart'
    if (dart.library.html) 'web_view_registry_web.dart';
