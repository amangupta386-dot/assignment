import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _definedBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _definedApiHost = String.fromEnvironment('API_HOST');
  static const String _definedApiPort =
      String.fromEnvironment('API_PORT', defaultValue: '4000');
  static const String _localLanApiHost = '10.145.220.166';

  static List<String> get baseUrls {
    if (_definedBaseUrl.isNotEmpty) return <String>[_definedBaseUrl];
    if (_definedApiHost.isNotEmpty) {
      return <String>['http://$_definedApiHost:$_definedApiPort/api'];
    }

    if (kIsWeb) return <String>['http://localhost:4000/api'];

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Try the current dev machine LAN IP first for physical-device testing,
        // then common emulator host mappings and localhost-based fallbacks.
        return <String>[
          'http://$_localLanApiHost:4000/api',
          'http://10.0.2.2:4000/api',
          'http://10.0.3.2:4000/api',
          'http://127.0.0.1:4000/api',
          'http://localhost:4000/api',
        ];
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return <String>['http://127.0.0.1:4000/api'];
    }
  }

  static String get baseUrl {
    return baseUrls.first;
  }
}
