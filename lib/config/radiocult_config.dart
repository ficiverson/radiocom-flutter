/// RadioCult API configuration
///
/// To use the RadioCult API, you need to:
/// 1. Create an account at https://app.radiocult.fm
/// 2. Go to Settings > API to get your station ID and API key
/// 3. Update the values below with your credentials
///
/// API Key Types:
/// - Publishable keys (pk_*): Read-only access, safe for frontend use
/// - Secret keys (sk_*): Full access including write operations
///
/// For a Flutter app, use a publishable key (pk_*) for security.

class RadioCultConfig {
  /// Your RadioCult station ID
  /// Found at: https://app.radiocult.fm/settings/cms/api
  static const String stationId = 'YOUR_STATION_ID';

  /// Your RadioCult API key
  /// Use a publishable key (pk_*) for client-side applications
  /// Found at: https://app.radiocult.fm/settings/cms/api
  static const String apiKey = 'YOUR_API_KEY';

  /// Whether RadioCult integration is enabled
  /// Set to true once you have configured your credentials
  static const bool isEnabled = false;

  /// Validate that the configuration is properly set up
  static bool get isConfigured {
    return stationId != 'YOUR_STATION_ID' &&
        apiKey != 'YOUR_API_KEY' &&
        stationId.isNotEmpty &&
        apiKey.isNotEmpty;
  }
}
