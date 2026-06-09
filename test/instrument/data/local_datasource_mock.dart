import 'package:cuacfm/data/datasource/alerts_local_datasource_contract.dart';
import 'package:cuacfm/data/datasource/favorites_local_datasource_contract.dart';
import 'package:cuacfm/data/datasource/playlist_local_datasource_contract.dart';
import 'package:cuacfm/data/datasource/wrapped_local_datasource_contract.dart';
import 'package:cuacfm/models/alert_record.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:mockito/mockito.dart';

import '../model/episode_instrument.dart';
import '../model/program_instrument.dart';

class MockAlertsLocalDataSource extends Mock
    implements AlertsLocalDataSourceContract {
  @override
  Future<void> migratePending() => super.noSuchMethod(
        Invocation.method(#migratePending, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
  @override
  void saveFromForeground(Map<String, dynamic> data) =>
      super.noSuchMethod(Invocation.method(#saveFromForeground, [data]));
  @override
  List<AlertRecord> getAlerts() => super.noSuchMethod(
        Invocation.method(#getAlerts, []),
        returnValue: alerts(),
      );
  @override
  Future<int> getUnreadCount() => super.noSuchMethod(
        Invocation.method(#getUnreadCount, []),
        returnValue: Future.value(0),
        returnValueForMissingStub: Future.value(0),
      );
  @override
  Future<void> markAllRead() => super.noSuchMethod(
        Invocation.method(#markAllRead, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  static List<AlertRecord> alerts({bool isEmpty = false}) {
    if (isEmpty) return [];
    return [
      AlertRecord(
        programName: 'Spoiler',
        programLogoUrl: 'assets/graphics/cuac-logo.png',
        rssUrl: 'http://feed',
        episodeTitle: 'Episode 1',
        episodeId: 'ep-001',
        receivedAt: DateTime.now(),
      )
    ];
  }
}

class MockFavoritesLocalDataSource extends Mock
    implements FavoritesLocalDataSourceContract {
  @override
  void addProgram(Map program) =>
      super.noSuchMethod(Invocation.method(#addProgram, [program]));
  @override
  void removeProgram(String rssUrl) =>
      super.noSuchMethod(Invocation.method(#removeProgram, [rssUrl]));
  @override
  List getFavorites() => super.noSuchMethod(
        Invocation.method(#getFavorites, []),
        returnValue: favorites(),
      );
  @override
  bool isFavorite(String rssUrl) => super.noSuchMethod(
        Invocation.method(#isFavorite, [rssUrl]),
        returnValue: false,
      );

  static List favorites({bool isEmpty = false}) {
    if (isEmpty) return [];
    return [ProgramInstrument.givenAProgram().toMap()];
  }
}

class MockPlaylistLocalDataSource extends Mock
    implements PlaylistLocalDataSourceContract {
  @override
  void addEpisode(Episode episode, String programName, String logoUrl) =>
      super.noSuchMethod(
          Invocation.method(#addEpisode, [episode, programName, logoUrl]));
  @override
  void addEpisodeAtStart(Episode episode, String programName, String logoUrl) =>
      super.noSuchMethod(Invocation.method(
          #addEpisodeAtStart, [episode, programName, logoUrl]));
  @override
  void removeEpisode(String audioUrl) =>
      super.noSuchMethod(Invocation.method(#removeEpisode, [audioUrl]));
  @override
  void clearAll() => super.noSuchMethod(Invocation.method(#clearAll, []));
  @override
  bool isInPlaylist(String audioUrl) => super.noSuchMethod(
        Invocation.method(#isInPlaylist, [audioUrl]),
        returnValue: false,
      );
  @override
  List<Map<String, dynamic>> getRawItems() => super.noSuchMethod(
        Invocation.method(#getRawItems, []),
        returnValue: playlistItems(),
      );
  @override
  List<Episode> getEpisodes() => super.noSuchMethod(
        Invocation.method(#getEpisodes, []),
        returnValue: <Episode>[],
      );
  @override
  String programNameForAudio(String audioUrl) => super.noSuchMethod(
        Invocation.method(#programNameForAudio, [audioUrl]),
        returnValue: '',
      );
  @override
  String logoUrlForAudio(String audioUrl) => super.noSuchMethod(
        Invocation.method(#logoUrlForAudio, [audioUrl]),
        returnValue: '',
      );
  @override
  void reorderFromList(List<Map<String, dynamic>> items) =>
      super.noSuchMethod(Invocation.method(#reorderFromList, [items]));

  static List<Map<String, dynamic>> playlistItems({bool isEmpty = false}) {
    if (isEmpty) return [];
    final ep = EpisodeInstrument.givenAnEpisode();
    return [
      {
        'audio': ep.audio,
        'title': ep.title,
        'programName': 'Spoiler',
        'logoUrl': 'assets/graphics/cuac-logo.png',
      }
    ];
  }
}

class MockWrappedLocalDataSource extends Mock
    implements WrappedLocalDataSourceContract {
  @override
  void startSession({
    required bool isPodcast,
    String programName = '',
    String category = '',
    String episodeTitle = '',
    String episodeId = '',
  }) =>
      super.noSuchMethod(Invocation.method(#startSession, [], {
        #isPodcast: isPodcast,
        #programName: programName,
        #category: category,
        #episodeTitle: episodeTitle,
        #episodeId: episodeId,
      }));
  @override
  void endSession() =>
      super.noSuchMethod(Invocation.method(#endSession, []));
  @override
  void recordFavoriteChange(String programName, bool added) =>
      super.noSuchMethod(
          Invocation.method(#recordFavoriteChange, [programName, added]));
  @override
  List<Map<String, dynamic>> getSessions() => super.noSuchMethod(
        Invocation.method(#getSessions, []),
        returnValue: <Map<String, dynamic>>[],
      );
}
