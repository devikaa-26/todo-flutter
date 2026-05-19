import 'dart:io';
import 'package:flutter/foundation.dart';

class APIConfig {

  static String get baseUrl {

    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    }

    if (Platform.isAndroid) {
      return "http://127.0.0.1:8000";
    }

    return "http://127.0.0.1:8000";
  }
}