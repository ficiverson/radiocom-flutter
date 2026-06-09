import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../instrument/helper/helper-instrument.dart';

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    DependencyInjector().loadModules();
    getTranslations();
  });

  group('TimeTable.fromInstance', () {
    test('that parses all fields correctly', () {
      final map = {
        'name': 'Morning Show',
        'description': 'The best morning show',
        'start': '2024-06-10T08:00:00Z',
        'end': '2024-06-10T10:00:00Z',
        'type': 'live',
        'logo_url': 'http://logo.jpg',
        'rss_url': 'http://rss.xml',
      };

      final timetable = TimeTable.fromInstance(map);

      expect(timetable.name, equals('Morning Show'));
      expect(timetable.description, equals('The best morning show'));
      expect(timetable.type, equals('live'));
      expect(timetable.logoUrl, equals('http://logo.jpg'));
      expect(timetable.rssUrl, equals('http://rss.xml'));
    });

    test('that calculates duration in minutes', () {
      final map = {
        'name': 'Show',
        'description': '',
        'start': '2024-06-10T08:00:00Z',
        'end': '2024-06-10T09:30:00Z',
        'type': 'live',
        'logo_url': '',
        'rss_url': '',
      };

      final timetable = TimeTable.fromInstance(map);

      expect(timetable.duration, equals('90'));
    });
  });

  group('TimeTable.getDuration', () {
    test('that computes duration between two times', () {
      final start = DateTime(2024, 6, 10, 8, 0);
      final end = DateTime(2024, 6, 10, 10, 0);
      final result = TimeTable.getDuration(start, end);

      expect(result, equals('120'));
    });

    test('that returns 0 for same start and end', () {
      final time = DateTime(2024, 6, 10, 8, 0);
      final result = TimeTable.getDuration(time, time);

      expect(result, equals('0'));
    });
  });

  group('TimeTable.toMap', () {
    test('that serializes to map correctly', () {
      final map = {
        'name': 'Show',
        'description': 'Desc',
        'start': '2024-06-10T08:00:00Z',
        'end': '2024-06-10T09:00:00Z',
        'type': 'live',
        'logo_url': 'http://logo.jpg',
        'rss_url': 'http://rss.xml',
      };

      final timetable = TimeTable.fromInstance(map);
      final result = timetable.toMap();

      expect(result['name'], equals('Show'));
      expect(result['description'], equals('Desc'));
      expect(result['logo_url'], equals('http://logo.jpg'));
      expect(result['rss_url'], equals('http://rss.xml'));
    });
  });
}
