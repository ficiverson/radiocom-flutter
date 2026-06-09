import 'package:cuacfm/models/alert_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('that AlertRecord toMap serializes all fields', () {
    final date = DateTime(2024, 6, 15, 10, 30);
    final record = AlertRecord(
      programName: 'Spoiler',
      programLogoUrl: 'http://logo.png',
      rssUrl: 'http://rss.url',
      episodeTitle: 'Episode 1',
      episodeId: 'ep-001',
      receivedAt: date,
    );

    final map = record.toMap();

    expect(map['programName'], equals('Spoiler'));
    expect(map['programLogoUrl'], equals('http://logo.png'));
    expect(map['rssUrl'], equals('http://rss.url'));
    expect(map['episodeTitle'], equals('Episode 1'));
    expect(map['episodeId'], equals('ep-001'));
    expect(map['receivedAt'], equals(date.toIso8601String()));
  });

  test('that AlertRecord fromMap deserializes all fields', () {
    final date = DateTime(2024, 6, 15, 10, 30);
    final map = {
      'programName': 'Spoiler',
      'programLogoUrl': 'http://logo.png',
      'rssUrl': 'http://rss.url',
      'episodeTitle': 'Episode 1',
      'episodeId': 'ep-001',
      'receivedAt': date.toIso8601String(),
    };

    final record = AlertRecord.fromMap(map);

    expect(record.programName, equals('Spoiler'));
    expect(record.programLogoUrl, equals('http://logo.png'));
    expect(record.rssUrl, equals('http://rss.url'));
    expect(record.episodeTitle, equals('Episode 1'));
    expect(record.episodeId, equals('ep-001'));
    expect(record.receivedAt, equals(date));
  });

  test('that AlertRecord fromMap handles missing fields gracefully', () {
    final record = AlertRecord.fromMap({});

    expect(record.programName, equals(''));
    expect(record.programLogoUrl, equals(''));
    expect(record.rssUrl, equals(''));
    expect(record.episodeTitle, equals(''));
    expect(record.episodeId, equals(''));
    expect(record.receivedAt, isNotNull);
  });

  test('that AlertRecord fromMap handles invalid date with DateTime.now fallback',
      () {
    final map = {
      'receivedAt': 'not-a-date',
    };

    final record = AlertRecord.fromMap(map);

    expect(record.receivedAt, isNotNull);
  });

  test('that toMap and fromMap are inverse operations', () {
    final original = AlertRecord(
      programName: 'Test Program',
      programLogoUrl: 'http://logo.png',
      rssUrl: 'http://rss.test',
      episodeTitle: 'Test Episode',
      episodeId: 'test-ep-001',
      receivedAt: DateTime(2024, 3, 20, 12, 0, 0),
    );

    final restored = AlertRecord.fromMap(original.toMap());

    expect(restored.programName, equals(original.programName));
    expect(restored.programLogoUrl, equals(original.programLogoUrl));
    expect(restored.rssUrl, equals(original.rssUrl));
    expect(restored.episodeTitle, equals(original.episodeTitle));
    expect(restored.episodeId, equals(original.episodeId));
    expect(restored.receivedAt, equals(original.receivedAt));
  });
}
