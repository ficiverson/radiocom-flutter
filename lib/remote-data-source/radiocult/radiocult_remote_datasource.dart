import 'dart:async';

import 'package:cuacfm/data/datasource/radiocult_remote_datasource.dart';
import 'package:cuacfm/models/radiocult/radiocult.dart';
import 'package:cuacfm/remote-data-source/network/radiocult_api.dart';
import 'package:cuacfm/utils/simple_client.dart';
import 'package:injector/injector.dart';

/// Implementation of RadioCult remote data source
class RadioCultRemoteDataSource implements RadioCultRemoteDataSourceContract {
  final SimpleClient client;
  final RadioCultAPIContract radioCultAPI;

  RadioCultRemoteDataSource({
    SimpleClient? client,
    RadioCultAPIContract? api,
  })  : client = client ?? Injector.appInstance.get<SimpleClient>(),
        radioCultAPI = api ?? Injector.appInstance.get<RadioCultAPIContract>();

  Map<String, String> get _headers => {
        'x-api-key': radioCultAPI.apiKey,
        'Content-Type': 'application/json',
      };

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final uri = Uri.parse(radioCultAPI.baseUrl + path);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  @override
  Future<List<RadioCultArtist>> getArtists() async {
    try {
      final uri = _buildUri(radioCultAPI.artists);
      final response = await client.get(uri, headers: _headers);

      if (response is Map && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => RadioCultArtist.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching artists: $e');
      return [];
    }
  }

  @override
  Future<RadioCultArtist?> getArtistById(String artistId) async {
    try {
      final uri = _buildUri(radioCultAPI.artistById(artistId));
      final response = await client.get(uri, headers: _headers);

      if (response is Map && response['success'] == true) {
        return RadioCultArtist.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching artist by ID: $e');
      return null;
    }
  }

  @override
  Future<RadioCultArtist?> getArtistBySlug(String slug) async {
    try {
      final uri = _buildUri(radioCultAPI.artistBySlug(slug));
      final response = await client.get(uri, headers: _headers);

      if (response is Map && response['success'] == true) {
        return RadioCultArtist.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching artist by slug: $e');
      return null;
    }
  }

  @override
  Future<List<RadioCultEvent>> getArtistSchedule(
      String artistId, DateTime startDate, DateTime endDate) async {
    try {
      final uri = _buildUri(
        radioCultAPI.artistSchedule(artistId),
        {
          'startDate': startDate.toUtc().toIso8601String(),
          'endDate': endDate.toUtc().toIso8601String(),
        },
      );
      final response = await client.get(uri, headers: _headers);

      if (response is Map && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => RadioCultEvent.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching artist schedule: $e');
      return [];
    }
  }

  @override
  Future<RadioCultLiveStatus?> getLiveStatus() async {
    try {
      final uri = _buildUri(radioCultAPI.scheduleLive);
      final response = await client.get(uri, headers: _headers);

      if (response is Map && response['success'] == true) {
        return RadioCultLiveStatus.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching live status: $e');
      return null;
    }
  }

  @override
  Future<List<RadioCultEvent>> getSchedule(DateTime startDate, DateTime endDate,
      {bool expandArtist = false}) async {
    try {
      final queryParams = {
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
      };
      if (expandArtist) {
        queryParams['expand'] = 'artist';
      }

      final uri = _buildUri(radioCultAPI.schedule, queryParams);
      final response = await client.get(uri, headers: _headers);

      if (response is Map && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => RadioCultEvent.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching schedule: $e');
      return [];
    }
  }

  @override
  Future<List<RadioCultLastPlayed>> getHistory({int limit = 5}) async {
    try {
      final uri = _buildUri(
        radioCultAPI.historyLatest,
        {'limit': limit.clamp(1, 100).toString()},
      );
      final response = await client.get(uri, headers: _headers);

      if (response is Map && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => RadioCultLastPlayed.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching history: $e');
      return [];
    }
  }

  @override
  Future<List<RadioCultPlaylist>> getPlaylists() async {
    try {
      final uri = _buildUri(radioCultAPI.playlists);
      final response = await client.get(uri, headers: _headers);

      if (response is Map && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => RadioCultPlaylist.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching playlists: $e');
      return [];
    }
  }

  @override
  Future<List<RadioCultTag>> getTags() async {
    try {
      final uri = _buildUri(radioCultAPI.tags);
      final response = await client.get(uri, headers: _headers);

      if (response is Map && response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => RadioCultTag.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching tags: $e');
      return [];
    }
  }
}
