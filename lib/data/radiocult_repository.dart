import 'dart:async';

import 'package:cuacfm/data/datasource/radiocult_remote_datasource.dart';
import 'package:cuacfm/domain/repository/radiocult_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/radiocult/radiocult.dart';

/// Implementation of RadioCult repository
class RadioCultRepository implements RadioCultRepositoryContract {
  final RadioCultRemoteDataSourceContract remoteDataSource;

  RadioCultRepository({required this.remoteDataSource});

  @override
  Future<Result<List<RadioCultArtist>>> getArtists() async {
    List<RadioCultArtist> artists = await remoteDataSource.getArtists();
    if (artists.isEmpty) {
      return Error([], Status.fail, "Failed to fetch artists");
    }
    return Success(artists, Status.ok);
  }

  @override
  Future<Result<RadioCultArtist>> getArtistById(String artistId) async {
    RadioCultArtist? artist = await remoteDataSource.getArtistById(artistId);
    if (artist == null) {
      return Error(_emptyArtist(), Status.fail, "Artist not found");
    }
    return Success(artist, Status.ok);
  }

  @override
  Future<Result<RadioCultArtist>> getArtistBySlug(String slug) async {
    RadioCultArtist? artist = await remoteDataSource.getArtistBySlug(slug);
    if (artist == null) {
      return Error(_emptyArtist(), Status.fail, "Artist not found");
    }
    return Success(artist, Status.ok);
  }

  @override
  Future<Result<List<RadioCultEvent>>> getArtistSchedule(
      String artistId, DateTime startDate, DateTime endDate) async {
    List<RadioCultEvent> events =
        await remoteDataSource.getArtistSchedule(artistId, startDate, endDate);
    if (events.isEmpty) {
      return Error([], Status.fail, "No schedule found for artist");
    }
    return Success(events, Status.ok);
  }

  @override
  Future<Result<RadioCultLiveStatus>> getLiveStatus() async {
    RadioCultLiveStatus? status = await remoteDataSource.getLiveStatus();
    if (status == null) {
      return Error(_offAirStatus(), Status.fail, "Failed to fetch live status");
    }
    return Success(status, Status.ok);
  }

  @override
  Future<Result<List<RadioCultEvent>>> getSchedule(
      DateTime startDate, DateTime endDate,
      {bool expandArtist = false}) async {
    List<RadioCultEvent> events = await remoteDataSource.getSchedule(
        startDate, endDate,
        expandArtist: expandArtist);
    if (events.isEmpty) {
      return Error([], Status.fail, "No events found in schedule");
    }
    return Success(events, Status.ok);
  }

  @override
  Future<Result<List<RadioCultLastPlayed>>> getHistory({int limit = 5}) async {
    List<RadioCultLastPlayed> history =
        await remoteDataSource.getHistory(limit: limit);
    if (history.isEmpty) {
      return Error([], Status.fail, "No history available");
    }
    return Success(history, Status.ok);
  }

  @override
  Future<Result<List<RadioCultPlaylist>>> getPlaylists() async {
    List<RadioCultPlaylist> playlists = await remoteDataSource.getPlaylists();
    if (playlists.isEmpty) {
      return Error([], Status.fail, "No playlists found");
    }
    return Success(playlists, Status.ok);
  }

  @override
  Future<Result<List<RadioCultTag>>> getTags() async {
    List<RadioCultTag> tags = await remoteDataSource.getTags();
    if (tags.isEmpty) {
      return Error([], Status.fail, "No tags found");
    }
    return Success(tags, Status.ok);
  }

  /// Create an empty artist for error cases
  RadioCultArtist _emptyArtist() {
    return RadioCultArtist(
      id: '',
      name: '',
      stationId: '',
      slug: '',
    );
  }

  /// Create an off-air status for error cases
  RadioCultLiveStatus _offAirStatus() {
    return RadioCultLiveStatus(
      status: RadioCultLiveStatusType.offAir,
    );
  }
}
