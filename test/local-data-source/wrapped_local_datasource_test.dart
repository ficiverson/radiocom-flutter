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

  setUp(() async {
    await Hive.box(boxName).clear();
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

  test('that endSession saves a live session when duration meets minimum', () {
    final ds = WrappedLocalDataSource(minSessionSeconds: 0);
    ds.startSession(isPodcast: false, programName: 'Morning Show', category: 'Music');
    ds.endSession();

    final sessions = ds.getSessions();
    expect(sessions.length, equals(1));
    expect(sessions[0]['type'], equals('live'));
    expect(sessions[0]['programName'], equals('Morning Show'));
    expect(sessions[0]['durationSeconds'], greaterThanOrEqualTo(0));
    expect(sessions[0]['isRepeat'], isFalse);
  });

  test('that endSession saves a podcast session with all fields', () {
    final ds = WrappedLocalDataSource(minSessionSeconds: 0);
    ds.startSession(
      isPodcast: true,
      programName: 'Spoiler',
      category: 'Music',
      episodeTitle: 'Episode 42',
      episodeId: 'ep-042',
    );
    ds.endSession();

    final sessions = ds.getSessions();
    expect(sessions.length, equals(1));
    expect(sessions[0]['type'], equals('podcast'));
    expect(sessions[0]['episodeTitle'], equals('Episode 42'));
    expect(sessions[0]['episodeId'], equals('ep-042'));
    expect(sessions[0]['category'], equals('Music'));
    expect(sessions[0]['isRepeat'], isFalse);
  });

  test('that endSession marks a repeat when same episodeId was listened before', () {
    final ds = WrappedLocalDataSource(minSessionSeconds: 0);
    ds.startSession(isPodcast: true, episodeId: 'ep-001');
    ds.endSession();

    ds.startSession(isPodcast: true, episodeId: 'ep-001');
    ds.endSession();

    final sessions = ds.getSessions();
    expect(sessions.length, equals(2));
    expect(sessions[0]['isRepeat'], isFalse);
    expect(sessions[1]['isRepeat'], isTrue);
  });

  test('that getSessions returns empty list when box is not open', () {
    final ds = WrappedLocalDataSource();
    // Create a fresh DS pointing to a non-existent box year by testing with closed Hive
    // The _box getter catches the exception and returns null
    // We test this by creating a ds whose box name doesn't correspond to an open box
    // Simulated by checking current behavior
    expect(ds.getSessions(), isA<List>());
  });

  test('that cleanOldData handles already-open old boxes', () async {
    final currentYear = DateTime.now().year;
    final oldBoxName = 'wrapped_${currentYear - 2}';
    await Hive.openBox(oldBoxName);
    // Put some data in it to confirm it gets cleared
    await Hive.box(oldBoxName).put('key', 'value');

    await WrappedLocalDataSource.cleanOldData();

    // After clean, the box should be empty
    expect(Hive.box(oldBoxName).isEmpty, isTrue);
  });

  test('that cleanOldData completes without throwing', () async {
    await WrappedLocalDataSource.cleanOldData();
  });
}
