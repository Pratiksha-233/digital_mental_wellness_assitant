import '../services/backend_config.dart';

// These are intentionally getters (not finals) so the backend URL can be
// updated at runtime (useful for running the app on a real phone via Wi-Fi).
String get backendBaseUrl => BackendConfig.backendBaseUrl;
String get apiBaseUrl => BackendConfig.apiBaseUrl;
String get detectionBaseUrl => BackendConfig.detectionBaseUrl;

// TODO: Replace with your actual Web (and desktop) OAuth 2.0 Client ID from
// Google Cloud Console (the one that ends with .apps.googleusercontent.com)
// Example: '1234567890-abcdefg123456.apps.googleusercontent.com'
const String googleWebClientId =
    'REPLACE_WITH_WEB_CLIENT_ID.apps.googleusercontent.com';
