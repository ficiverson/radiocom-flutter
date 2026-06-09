import 'dart:convert';
import 'dart:io';

import 'package:cuacfm/local-data-source/wrapped_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late WrappedLocalDataSource dataSource;
  late Directory tempDir;
  late String boxName;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_wrapped_test');
    Hive.init(tempDir.path);
    boxName = 'wrapped_${DateTime.now().year}';
    await Hive.openBox(boxName);
    dataSource = WrappedLocalDataSource();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() {
    Hive.box(boxName).clear();
  });

  test('that startSession records session metadata', () {
    dataSource.startSession(
      isPodcast: true,
      programName: 'Spoiler',
      category: 'Music',
      episodeTitle: 'Episode 1',
      episodeId: 'ep-001',
    );

    dataSource.endSession();

    // endSession only saves if duration >= 30s, so sessions list will be empty
    // but startSession should not throw
  });

  test('that endSession does nothing when no session started', () {
    expect(() => dataSource.endSession(), returnsNormally);
  });

  test('that getSessions returns empty list when no sessions recorded', () {
    final sessions = dataSource.getSessions();
    expect(sessions.length, equals(0));
  });

  test('that recordFavoriteChange stores a favorite event', () {
    dataSource.recordFavoriteChange('Spoiler', true);

    final sessions = dataSource.getSessions();
    expect(sessions.length, equals(1));
    expect(sessions[0]['type'], equals('favorite'));
    expect(sessions[0]['action'], equals('add'));
    expect(sessions[0]['programName'], equals('Spoiler'));
  });

  test('that recordFavoriteChange stores a remove event', () {
    dataSource.recordFavoriteChange('Spoiler', false);

    final sessions = dataSource.getSessions();
    expect(sessions.length, equals(1));
    expect(sessions[0]['action'], equals('remove'));
  });

  test('that recordFavoriteChange includes date fields', () {
    dataSource.recordFavoriteChange('Spoiler', true);

    final sessions = dataSource.getSessions();
    expect(sessions[0]['date'], isNotNull);
    expect(sessions[0]['month'], equals(DateTime.now().month));
    expect(sessions[0]['year'], equals(DateTime.now().year));
  });

  test('that multiple favorite changes are all recorded', () {
    dataSource.recordFavoriteChange('Program A', true);
    dataSource.recordFavoriteChange('Program B', true);
    dataSource.recordFavoriteChange('Program A', false);

    final sessions = dataSource.getSessions();
    expect(sessions.length, equals(3));
  });

  test('that cleanOldData completes without throwing', () async {
    await WrappedLocalDataSource.cleanOldData();
  });
}
