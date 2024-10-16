import 'package:flutter/foundation.dart';

void loggerError(dynamic err) {
  if (kDebugMode) {
    print("INFO: $err");
  }
}
