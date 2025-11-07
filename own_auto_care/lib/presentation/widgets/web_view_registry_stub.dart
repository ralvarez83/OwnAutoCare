/// Non-web stub for view registry. No-op on non-web platforms.
void registerViewFactory(String viewId, Object Function(int) factory) {
  // No-op: platform views are only supported on web.
}
