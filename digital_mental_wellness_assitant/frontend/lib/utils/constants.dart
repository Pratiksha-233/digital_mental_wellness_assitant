import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

const String _envBackendBase = String.fromEnvironment('BACKEND_BASE', defaultValue: '');

String resolveBackendBase() {
	if (_envBackendBase.isNotEmpty) {
		return _envBackendBase;
	}
	if (kIsWeb) {
		return 'http://127.0.0.1:5000';
	}
	switch (defaultTargetPlatform) {
		case TargetPlatform.android:
			// Android emulator localhost proxy; override for real devices via --dart-define=BACKEND_BASE.
			return 'http://10.0.2.2:5000';
		case TargetPlatform.iOS:
			return 'http://127.0.0.1:5000';
		default:
			return 'http://127.0.0.1:5000';
	}
}

final String backendBaseUrl = resolveBackendBase();
final String apiBaseUrl = '$backendBaseUrl/api';
final String detectionBaseUrl = '$apiBaseUrl/detection';

// TODO: Replace with your actual Web (and desktop) OAuth 2.0 Client ID from
// Google Cloud Console (the one that ends with .apps.googleusercontent.com)
// Example: '1234567890-abcdefg123456.apps.googleusercontent.com'
const String googleWebClientId = 'REPLACE_WITH_WEB_CLIENT_ID.apps.googleusercontent.com';