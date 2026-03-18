import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class BackendConfig {
  static const String _kBackendBaseOverride = 'backend.baseUrlOverride';

  static const String _envBackendBase = String.fromEnvironment(
    'BACKEND_BASE',
    defaultValue: '',
  );

  static String _backendBaseUrl = _computeDefaultBackendBase();

  static String _computeDefaultBackendBase() {
    if (_envBackendBase.trim().isNotEmpty) {
      return normalizeBackendBase(_envBackendBase);
    }

    if (kIsWeb) {



      return normalizeBackendBase(Uri.base.origin);
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:



        return 'http://10.0.2.2:5000';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:5000';
      default:
        return 'http://127.0.0.1:5000';
    }
  }

  static String get backendBaseUrl => _backendBaseUrl;

  static String get apiBaseUrl => '$_backendBaseUrl/api';

  static String get detectionBaseUrl => '$apiBaseUrl/detection';


  static Future<void> init() async {
    if (_envBackendBase.trim().isNotEmpty) {
      _backendBaseUrl = normalizeBackendBase(_envBackendBase);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final override = prefs.getString(_kBackendBaseOverride);
    if (override != null && override.trim().isNotEmpty) {
      _backendBaseUrl = normalizeBackendBase(override);
    } else {
      _backendBaseUrl = _computeDefaultBackendBase();
    }
  }

  static Future<String?> getBackendBaseOverride() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kBackendBaseOverride);
    return (v == null || v.trim().isEmpty) ? null : v.trim();
  }





  static Future<void> setBackendBaseOverride(String? value) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      await prefs.remove(_kBackendBaseOverride);
      _backendBaseUrl = _computeDefaultBackendBase();
      return;
    }

    final normalized = normalizeBackendBase(raw);
    await prefs.setString(_kBackendBaseOverride, normalized);
    _backendBaseUrl = normalized;
  }

  static String normalizeBackendBase(String input) {
    var v = input.trim();


    if (!v.startsWith('http://') && !v.startsWith('https://')) {
      v = 'http://$v';
    }


    while (v.endsWith('/')) {
      v = v.substring(0, v.length - 1);
    }

    return v;
  }
}
