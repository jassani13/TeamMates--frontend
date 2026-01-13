import 'dart:io';

import 'package:flutter/foundation.dart';

class ServerConfig {
  ServerConfig._();

  //static const String _apiProduction = 'http://54.196.239.6';
  static const String _apiProduction = 'https://api.teammatesapp.org';
  static const String _socketProduction = 'http://13.220.132.157:3000';

  static String get _localHost =>
      Platform.isIOS ? 'http://127.0.0.1' : 'http://10.0.2.2';

  static String get _apiLocal => '$_localHost:8000';

  static String get _socketLocal => '$_localHost:3000';

  static bool get useLocalServer {
    return true;
    return !kReleaseMode;
  }

  static String get apiBaseUrl => useLocalServer ? _apiLocal : _apiProduction;

  static String get socketBaseUrl =>
      useLocalServer ? _socketLocal : _socketProduction;

  static String get publicImageBaseUrl => '$apiBaseUrl/';
}
