import 'package:cuacfm/data/favorites_repository.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../instrument/data/local_datasource_mock.dart';
import '../instrument/helper/helper-instrument.dart';
import '../instrument/model/program_instrument.dart';

void main() {
  late FavoritesRepository repository;
  MockFavoritesLocalDataSource mockFavoritesLocalDataSource =
      MockFavoritesLocalDataSource();
  MockWrappedLocalDataSource mockWrappedLocalDataSource =
      MockWrappedLocalDataSource();

  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    DependencyInjector().loadModules();
    getTranslations();
    repository = FavoritesRepository(
      localDataSource: mockFavoritesLocalDataSource,
      wrappedDataSource: mockWrappedLocalDataSource,
    );
  });

  test('that addProgram delegates to local data source and records wrapped event',
      () {
    final program = ProgramInstrument.givenAProgram().toMap();

    repository.addProgram(program);

    verify(mockFavoritesLocalDataSource.addProgram(program)).called(1);
    verify(mockWrappedLocalDataSource.recordFavoriteChange(
            program['name'], true))
        .called(1);
  });

  test('that removeProgram delegates to local data source and records wrapped event',
      () {
    final program = ProgramInstrument.givenAProgram().toMap();
    when(mockFavoritesLocalDataSource.getFavorites())
        .thenReturn([program]);

    repository.removeProgram(program['rssUrl']);

    verify(mockFavoritesLocalDataSource.removeProgram(program['rssUrl']))
        .called(1);
    verify(mockWrappedLocalDataSource.recordFavoriteChange(
            program['name'] ?? '', false))
        .called(1);
  });

  test('that removeProgram does not record wrapped event when program not found',
      () {
    when(mockFavoritesLocalDataSource.getFavorites()).thenReturn([]);
    clearInteractions(mockWrappedLocalDataSource);

    repository.removeProgram('http://unknown.rss');

    verify(mockFavoritesLocalDataSource.removeProgram('http://unknown.rss'))
        .called(1);
    verifyZeroInteractions(mockWrappedLocalDataSource);
  });

  test('that getFavorites returns list from local data source', () {
    when(mockFavoritesLocalDataSource.getFavorites())
        .thenReturn(MockFavoritesLocalDataSource.favorites());

    final result = repository.getFavorites();

    expect(result.length, equals(1));
  });

  test('that getFavorites returns empty list', () {
    when(mockFavoritesLocalDataSource.getFavorites())
        .thenReturn(MockFavoritesLocalDataSource.favorites(isEmpty: true));

    final result = repository.getFavorites();

    expect(result.length, equals(0));
  });

  test('that isFavorite returns true when program is in favorites', () {
    when(mockFavoritesLocalDataSource.isFavorite('http://rss.url'))
        .thenReturn(true);

    final result = repository.isFavorite('http://rss.url');

    expect(result, equals(true));
  });

  test('that isFavorite returns false when program is not in favorites', () {
    when(mockFavoritesLocalDataSource.isFavorite('http://rss.url'))
        .thenReturn(false);

    final result = repository.isFavorite('http://rss.url');

    expect(result, equals(false));
  });
}
