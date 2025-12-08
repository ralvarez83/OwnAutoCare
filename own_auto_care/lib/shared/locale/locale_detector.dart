import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Utility class to detect and manage locales across platforms
class LocaleDetector {
  /// Get the system locale - works on both mobile and web
  static Locale? getSystemLocale() {
    try {
      // Use window.locale from Flutter (works on all platforms)
      final locale = ui.window.locale;
      if (locale.languageCode.isNotEmpty) {
        return Locale(locale.languageCode);
      }
    } catch (e) {
      // If there's any error, fall through to fallback
    }
    
    return null;
  }
  
  /// Find the best matching supported locale
  static Locale findBestMatch(
    Locale? deviceLocale,
    List<Locale> supportedLocales,
  ) {
    if (deviceLocale == null) {
      return supportedLocales.first;
    }

    // Exact match on language code
    for (final supported in supportedLocales) {
      if (supported.languageCode == deviceLocale.languageCode) {
        return supported;
      }
    }

    // No match found, return first supported locale
    return supportedLocales.first;
  }
}

