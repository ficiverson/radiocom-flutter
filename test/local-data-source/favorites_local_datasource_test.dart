import 'dart:io';

import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/local-data-source/favorites_local_datasource.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../instrument/helper/helper-instrument.dart';
import '../instrument/model/program_instrument.dart';

void main() {
  late FavoritesLocalDataSource dataSource;
  late Directory tempDir;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    DependencyInjector().loadModules();
    getTranslations();
    tempDir = await Directory.systemTemp.createTemp('hive_favorites_test');
    Hive.init(tempDir.path);
    await Hive.openBox('favourites');
    dataSource = FavoritesLocalDataSource();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() {
    Hive.box('favourites').clear();
  });

  test('that addProgram stores the program in hive', () {
    final program = ProgramInstrument.givenAProgram().toMap();

    dataSource.addProgram(program);

    final favorites = dataSource.getFavorites();
    expect(favorites.length, equals(1));
  });

  test('that addProgram stores multiple programs', () {
    final program1 = ProgramInstrument.givenAProgram().toMap();
    final program2 = {
      ...ProgramInstrument.givenAProgram().toMap(),
      'rssUrl': 'http://other.rss',
      'name': 'Other Program',
    };

    dataSource.addProgram(program1);
    dataSource.addProgram(program2);

    final favorites = dataSource.getFavorites();
    expect(favorites.length, equals(2));
  });

  test('that removeProgram removes the correct program', () {
    final program = ProgramInstrument.givenAProgram().toMap();
    dataSource.addProgram(program);

    dataSource.removeProgram(program['rssUrl']);

    final favorites = dataSource.getFavorites();
    expect(favorites.length, equals(0));
  });

  test('that removeProgram only removes the specified program', () {
    final program1 = ProgramInstrument.givenAProgram().toMap();
    final program2 = {
      ...ProgramInstrument.givenAProgram().toMap(),
      'rssUrl': 'http://other.rss',
      'name': 'Other Program',
    };
    dataSource.addProgram(program1);
    dataSource.addProgram(program2);

    dataSource.removeProgram(program1['rssUrl']);

    final favorites = dataSource.getFavorites();
    expect(favorites.length, equals(1));
  });

  test('that getFavorites returns empty list when no favorites', () {
    final favorites = dataSource.getFavorites();
    expect(favorites.length, equals(0));
  });

  test('that isFavorite returns true when program is stored', () {
    final program = ProgramInstrument.givenAProgram().toMap();
    dataSource.addProgram(program);

    final result = dataSource.isFavorite(program['rssUrl']);

    expect(result, isTrue);
  });

  test('that isFavorite returns false when program is not stored', () {
    final result = dataSource.isFavorite('http://not-stored.rss');

    expect(result, isFalse);
  });

  test('that adding same program twice updates the existing entry', () {
    final program = ProgramInstrument.givenAProgram().toMap();
    dataSource.addProgram(program);
    dataSource.addProgram(program);

    final favorites = dataSource.getFavorites();
    expect(favorites.length, equals(1));
  });
}
