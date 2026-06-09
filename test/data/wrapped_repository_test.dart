import 'package:cuacfm/data/wrapped_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_datasource_mock.dart';

void main() {
  late WrappedRepository repository;
  MockWrappedLocalDataSource mockLocalDataSource = MockWrappedLocalDataSource();

  setUpAll(() {
    repository = WrappedRepository(localDataSource: mockLocalDataSource);
  });

  test('that startSession delegates to local data source', () {
    repository.startSession(
      isPodcast: true,
      programName: 'Spoiler',
      category: 'Music',
      episodeTitle: 'Episode 1',
      episodeId: 'ep-001',
    );

    verify(mockLocalDataSource.startSession(
      isPodcast: true,
      programName: 'Spoiler',
      category: 'Music',
      episodeTitle: 'Episode 1',
      episodeId: 'ep-001',
    )).called(1);
  });

  test('that startSession for live radio delegates to local data source', () {
    repository.startSession(isPodcast: false);

    verify(mockLocalDataSource.startSession(
      isPodcast: false,
      programName: '',
      category: '',
      episodeTitle: '',
      episodeId: '',
    )).called(1);
  });

  test('that endSession delegates to local data source', () {
    repository.endSession();

    verify(mockLocalDataSource.endSession()).called(1);
  });

  test('that recordFavoriteChange add delegates to local data source', () {
    repository.recordFavoriteChange('Spoiler', true);

    verify(mockLocalDataSource.recordFavoriteChange('Spoiler', true)).called(1);
  });

  test('that recordFavoriteChange remove delegates to local data source', () {
    repository.recordFavoriteChange('Spoiler', false);

    verify(mockLocalDataSource.recordFavoriteChange('Spoiler', false))
        .called(1);
  });

  test('that getSessions returns list from local data source', () {
    final sessions = [
      {'type': 'live', 'durationSeconds': 120},
    ];
    when(mockLocalDataSource.getSessions()).thenReturn(sessions);

    final result = repository.getSessions();

    expect(result.length, equals(1));
    expect(result[0]['type'], equals('live'));
  });

  test('that getSessions returns empty list when no sessions', () {
    when(mockLocalDataSource.getSessions()).thenReturn([]);

    final result = repository.getSessions();

    expect(result.length, equals(0));
  });
}
