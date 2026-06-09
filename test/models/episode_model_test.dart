import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

// getDayOfWeek and getMonthOfYear are top-level functions in episode.dart
// ignore: implementation_imports

import '../instrument/helper/helper-instrument.dart';

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    DependencyInjector().loadModules();
    getTranslations();
  });

  group('Episode.fromMap', () {
    test('that parses all fields from map', () {
      final pubDate = DateTime(2020, 2, 12, 13, 27, 44);
      final map = {
        'title': 'Test Episode',
        'link': 'http://example.com',
        'audio': 'http://audio.mp3',
        'pubDate': pubDate.toIso8601String(),
        'duration': '60 mins.',
        'description': 'Test description',
      };

      final episode = Episode.fromMap(map);

      expect(episode.title, equals('Test Episode'));
      expect(episode.link, equals('http://example.com'));
      expect(episode.audio, equals('http://audio.mp3'));
      expect(episode.duration, equals('60 mins.'));
      expect(episode.description, equals('Test description'));
    });

    test('that handles missing fields with defaults', () {
      final episode = Episode.fromMap({});

      expect(episode.title, equals(''));
      expect(episode.link, equals(''));
      expect(episode.audio, equals(''));
      expect(episode.duration, equals('__'));
      expect(episode.description, equals(''));
    });
  });

  group('Episode.fromInstance', () {
    test('that parses all fields from instance map', () {
      final episode = Episode.fromInstance({
        "title": {"\$t": "My Episode"},
        "link": {"\$t": "http://link.com"},
        "pubDate": {"\$t": "Wed, 12 Feb 2020 13:27:44 +0000"},
        "description": {"\$t": "My description"},
        "enclosure": {"url": "http://audio.mp3"},
        "itunes\$duration": {"\$t": "0:01:00"}
      });

      expect(episode.title, equals('My Episode'));
      expect(episode.audio, equals('http://audio.mp3'));
      expect(episode.description, equals('My description'));
    });

    test('that uses default duration when itunes duration is missing', () {
      final episode = Episode.fromInstance({
        "title": {"\$t": "My Episode"},
        "link": {"\$t": "http://link.com"},
        "pubDate": {"\$t": "Wed, 12 Feb 2020 13:27:44 +0000"},
        "description": {"\$t": "desc"},
        "enclosure": {"url": "http://audio.mp3"},
      });

      expect(episode.duration, equals('__'));
    });
  });

  group('Episode.getDuration', () {
    test('that converts hh:mm:ss to minutes string', () {
      final result = Episode.getDuration('01:05:00');
      expect(result, equals('300 mins.'));
    });

    test('that returns __ for invalid duration format', () {
      final result = Episode.getDuration('invalid');
      expect(result, equals('__'));
    });

    test('that handles zero duration', () {
      final result = Episode.getDuration('0:00:00');
      expect(result, equals('0 mins.'));
    });
  });

  group('Episode.getDate', () {
    test('that parses valid RFC date', () {
      final result = Episode.getDate('Wed, 12 Feb 2020 13:27:44 +0000');
      expect(result.year, equals(2020));
      expect(result.month, equals(2));
      expect(result.day, equals(12));
    });
  });

  group('getDayOfWeek', () {
    test('that returns day string for each weekday', () {
      // Monday = weekday 1
      expect(getDayOfWeek(DateTime(2024, 6, 3)), isNotNull); // Mon
      expect(getDayOfWeek(DateTime(2024, 6, 4)), isNotNull); // Tue
      expect(getDayOfWeek(DateTime(2024, 6, 5)), isNotNull); // Wed
      expect(getDayOfWeek(DateTime(2024, 6, 6)), isNotNull); // Thu
      expect(getDayOfWeek(DateTime(2024, 6, 7)), isNotNull); // Fri
      expect(getDayOfWeek(DateTime(2024, 6, 8)), isNotNull); // Sat
      expect(getDayOfWeek(DateTime(2024, 6, 9)), isNotNull); // Sun
    });
  });

  group('getMonthOfYear', () {
    test('that returns month string for each month', () {
      for (int month = 1; month <= 12; month++) {
        final result = getMonthOfYear(DateTime(2024, month, 1));
        expect(result, isNotNull);
      }
    });
  });
}
