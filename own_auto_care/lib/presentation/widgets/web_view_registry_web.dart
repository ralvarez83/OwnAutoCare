import 'dart:ui_web' as ui_web;

/// Register a view factory using the web-only [platformViewRegistry].
void registerViewFactory(String viewId, Object Function(int) factory) {
  ui_web.platformViewRegistry.registerViewFactory(viewId, factory);
}
