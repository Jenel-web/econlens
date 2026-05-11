/// app_constants.dart — Core Constants
///
/// Centralises all non-secret app-wide constants.
/// Secrets (API keys, passwords) come from flutter_dotenv, not here.
class AppConstants {
  AppConstants._();

  // Backend base URL (override via .env for production)
  static const String defaultBaseUrl = 'http://10.0.2.2:8080'; // Android emulator → localhost
  static const String defaultBaseUrlPhysical = 'http://localhost:8080'; // Physical device / iOS simulator

  // API routes
  static const String newsEndpoint = '/api/v1/news';

  // App info
  static const String appName = 'EconLens';
  static const String appTagline = 'Bridge news with economic impact';
  static const String appVersion = '1.0.0';
}
