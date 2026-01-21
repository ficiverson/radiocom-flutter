import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/radiocult/radiocult.dart';

/// Contract for RadioCult repository
abstract class RadioCultRepositoryContract {
  /// Get all artists for the station
  Future<Result<List<RadioCultArtist>>> getArtists();

  /// Get a specific artist by ID
  Future<Result<RadioCultArtist>> getArtistById(String artistId);

  /// Get a specific artist by slug
  Future<Result<RadioCultArtist>> getArtistBySlug(String slug);

  /// Get schedule for a specific artist
  Future<Result<List<RadioCultEvent>>> getArtistSchedule(
      String artistId, DateTime startDate, DateTime endDate);

  /// Get current live status
  Future<Result<RadioCultLiveStatus>> getLiveStatus();

  /// Get schedule events within a date range
  Future<Result<List<RadioCultEvent>>> getSchedule(
      DateTime startDate, DateTime endDate,
      {bool expandArtist = false});

  /// Get last played tracks history
  Future<Result<List<RadioCultLastPlayed>>> getHistory({int limit = 5});

  /// Get all playlists
  Future<Result<List<RadioCultPlaylist>>> getPlaylists();

  /// Get all tags
  Future<Result<List<RadioCultTag>>> getTags();
}
