import 'dart:convert';
import 'dart:io';

import 'package:cuacfm/local-data-source/alerts_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AlertsLocalDataSource dataSource;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_alerts_test');
    Hive.init(tempDir.path);
    await Hive.openBox('alerts');
    dataSource = AlertsLocalDataSource();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Hive.box('alerts').clear();
  });

  test('that saveFromForeground persists a record in hive', () {
    final now = DateTime.now();
    final data = {
      'programName': 'Spoiler',
      'programLogoUrl': 'http://logo.png',
      'rssUrl': 'http://rss',
      'episodeTitle': 'Ep 1',
      'episodeId': 'ep-001',
      'receivedAt': now.toIso8601String(),
    };

    dataSource.saveFromForeground(data);

    final alerts = dataSource.getAlerts();
    expect(alerts.length, equals(1));
    expect(alerts[0].programName, equals('Spoiler'));
  });

  test('that getAlerts returns empty list when no records', () {
    final alerts = dataSource.getAlerts();
    expect(alerts.length, equals(0));
  });

  test('that getUnreadCount returns 0 when no unread', () async {
    final count = await dataSource.getUnreadCount();
    expect(count, equals(0));
  });

  test('that markAllRead sets unread count to zero', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('alerts_unread_count', 5);

    await dataSource.markAllRead();

    final count = await dataSource.getUnreadCount();
    expect(count, equals(0));
  });

  test('that migratePending moves SharedPrefs alerts to hive', () async {
    final now = DateTime.now();
    final data = [
      {
        'programName': 'Migrated',
        'programLogoUrl': '',
        'rssUrl': 'http://migrated',
        'episodeTitle': 'Ep',
        'episodeId': 'ep-m',
        'receivedAt': now.toIso8601String(),
      }
    ];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_alerts', jsonEncode(data));

    await dataSource.migratePending();

    final alerts = dataSource.getAlerts();
    expect(alerts.any((a) => a.programName == 'Migrated'), isTrue);
    expect(prefs.getString('pending_alerts'), isNull);
  });

  test('that migratePending does nothing when no pending alerts', () async {
    await dataSource.migratePending();

    final alerts = dataSource.getAlerts();
    expect(alerts.length, equals(0));
  });

  test('that saveFromBackground adds to SharedPreferences and increments unread',
      () async {
    final now = DateTime.now();
    final data = {
      'programName': 'Background',
      'programLogoUrl': '',
      'rssUrl': 'http://bg',
      'episodeTitle': 'Ep',
      'episodeId': 'ep-bg',
      'receivedAt': now.toIso8601String(),
    };

    await AlertsLocalDataSource.saveFromBackground(data);

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('pending_alerts') ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    expect(list.any((m) => m['programName'] == 'Background'), isTrue);
    expect(prefs.getInt('alerts_unread_count'), equals(1));
  });
}
