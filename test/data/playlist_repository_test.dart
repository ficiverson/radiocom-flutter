import 'package:cuacfm/data/playlist_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_datasource_mock.dart';
import '../instrument/model/episode_instrument.dart';

void main() {
  late PlaylistRepository repository;
  MockPlaylistLocalDataSource mockLocalDataSource =
      MockPlaylistLocalDataSource();

  setUpAll(() {
    repository = PlaylistRepository(localDataSource: mockLocalDataSource);
  });

  test('that addEpisode delegates to local data source', () {
    final episode = EpisodeInstrument.givenAnEpisode();

    repository.addEpisode(episode, 'Spoiler', 'http://logo.png');

    verify(mockLocalDataSource.addEpisode(episode, 'Spoiler', 'http://logo.png'))
        .called(1);
  });

  test('that addEpisodeAtStart delegates to local data source', () {
    final episode = EpisodeInstrument.givenAnEpisode();

    repository.addEpisodeAtStart(episode, 'Spoiler', 'http://logo.png');

    verify(mockLocalDataSource.addEpisodeAtStart(
            episode, 'Spoiler', 'http://logo.png'))
        .called(1);
  });

  test('that removeEpisode delegates to local data source', () {
    repository.removeEpisode('http://audio.mp3');

    verify(mockLocalDataSource.removeEpisode('http://audio.mp3')).called(1);
  });

  test('that clearAll delegates to local data source', () {
    repository.clearAll();

    verify(mockLocalDataSource.clearAll()).called(1);
  });

  test('that isInPlaylist returns true when episode is in playlist', () {
    when(mockLocalDataSource.isInPlaylist('http://audio.mp3'))
        .thenReturn(true);

    final result = repository.isInPlaylist('http://audio.mp3');

    expect(result, equals(true));
  });

  test('that isInPlaylist returns false when episode is not in playlist', () {
    when(mockLocalDataSource.isInPlaylist('http://audio.mp3'))
        .thenReturn(false);

    final result = repository.isInPlaylist('http://audio.mp3');

    expect(result, equals(false));
  });

  test('that getRawItems returns list from local data source', () {
    when(mockLocalDataSource.getRawItems())
        .thenReturn(MockPlaylistLocalDataSource.playlistItems());

    final result = repository.getRawItems();

    expect(result.length, equals(1));
  });

  test('that getRawItems returns empty list when playlist is empty', () {
    when(mockLocalDataSource.getRawItems())
        .thenReturn(MockPlaylistLocalDataSource.playlistItems(isEmpty: true));

    final result = repository.getRawItems();

    expect(result.length, equals(0));
  });

  test('that getEpisodes returns list from local data source', () {
    final episode = EpisodeInstrument.givenAnEpisode();
    when(mockLocalDataSource.getEpisodes()).thenReturn([episode]);

    final result = repository.getEpisodes();

    expect(result.length, equals(1));
  });

  test('that programNameForAudio delegates to local data source', () {
    when(mockLocalDataSource.programNameForAudio('http://audio.mp3'))
        .thenReturn('Spoiler');

    final result = repository.programNameForAudio('http://audio.mp3');

    expect(result, equals('Spoiler'));
  });

  test('that logoUrlForAudio delegates to local data source', () {
    when(mockLocalDataSource.logoUrlForAudio('http://audio.mp3'))
        .thenReturn('http://logo.png');

    final result = repository.logoUrlForAudio('http://audio.mp3');

    expect(result, equals('http://logo.png'));
  });

  test('that reorderFromList delegates to local data source', () {
    final items = [
      {'audio': 'http://a.mp3'},
      {'audio': 'http://b.mp3'},
    ];

    repository.reorderFromList(items);

    verify(mockLocalDataSource.reorderFromList(items)).called(1);
  });
}
