import 'package:flutter/foundation.dart';

/// Retrieves the custom data version including the SDK version information.
///
/// Returns a Future that completes with a Map containing the version information.
Future<Map<String, dynamic>> get customDataVersion async {
  try {
    return {"dito_sdk_version": "Flutter SDK - 2.0.0"};
  } catch (e) {
    if (kDebugMode) {
      print('Error retrieving package info: $e');
    }
    return {"dito_sdk_version": "Unknown version"};
  }
}
