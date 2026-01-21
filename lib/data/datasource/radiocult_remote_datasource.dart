import 'package:cuacfm/models/radiocult/radiocult.dart';

/// Contract for RadioCult remote data source
abstract class RadioCultRemoteDataSourceContract {
  /// Get all artists for the station
  Future<List<RadioCultArtist>> getArtists();

  /// Get a specific artist by ID
  Future<RadioCultArtist?> getArtistById(String artistId);

  /// Get a specific artist by slug
  Future<RadioCultArtist?> getArtistBySlug(String slug);

  /// Get schedule for a specific artist
  Future<List<RadioCultEvent>> getArtistSchedule(
      String artistId, DateTime startDate, DateTime endDate);

  /// Get current live status
  Future<RadioCultLiveStatus?> getLiveStatus();

  /// Get schedule events within a date range
  Future<List<RadioCultEvent>> getSchedule(DateTime startDate, DateTime endDate,
      {bool expandArtist = false});

  /// Get last played tracks history
  Future<List<RadioCultLastPlayed>> getHistory({int limit = 5});

  /// Get all playlists
  Future<List<RadioCultPlaylist>> getPlaylists();

  /// Get all tags
  Future<List<RadioCultTag>> getTags();
}
