/// RadioCult API configuration
/// Documentation: https://www.radiocult.fm/docs/api
///
/// Authentication: API key passed via 'x-api-key' header
/// - Publishable keys (pk_*): Read-only access, safe for frontend use
/// - Secret keys (sk_*): Full access including write operations

abstract class RadioCultAPIContract {
  String get baseUrl;
  String get stationId;
  String get apiKey;

  // Artists endpoints
  String get artists;
  String artistById(String artistId);
  String artistBySlug(String slug);
  String artistSchedule(String artistId);

  // Schedule endpoints
  String get scheduleLive;
  String get schedule;

  // History endpoints
  String get historyLatest;

  // Media endpoints (may be disabled by default)
  String get playlists;
  String get tags;
}

class RadioCultAPI implements RadioCultAPIContract {
  final String _stationId;
  final String _apiKey;

  RadioCultAPI({required String stationId, required String apiKey})
      : _stationId = stationId,
        _apiKey = apiKey;

  @override
  String get baseUrl => "https://api.radiocult.fm";

  @override
  String get stationId => _stationId;

  @override
  String get apiKey => _apiKey;

  // Artists endpoints
  @override
  String get artists => "/api/station/$_stationId/artists";

  @override
  String artistById(String artistId) =>
      "/api/station/$_stationId/artists/$artistId";

  @override
  String artistBySlug(String slug) => "/api/station/$_stationId/artists/$slug";

  @override
  String artistSchedule(String artistId) =>
      "/api/station/$_stationId/artists/$artistId/schedule";

  // Schedule endpoints
  @override
  String get scheduleLive => "/api/station/$_stationId/schedule/live";

  @override
  String get schedule => "/api/station/$_stationId/schedule";

  // History endpoints
  @override
  String get historyLatest =>
      "/api/station/$_stationId/streaming/history/latest-results";

  // Media endpoints
  @override
  String get playlists => "/api/station/$_stationId/media/playlist";

  @override
  String get tags => "/api/station/$_stationId/media/tag";

  /// Get headers for API requests
  Map<String, String> getHeaders() {
    return {
      'x-api-key': _apiKey,
      'Content-Type': 'application/json',
    };
  }
}
