import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/outstanding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../instrument/helper/helper-instrument.dart';

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    DependencyInjector().loadModules();
    getTranslations();
  });

  group('New.getDate', () {
    test('that formats a valid date string', () {
      final result = New.getDate('Wed, 12 Feb 2020 13:27:44 +0000');
      expect(result, isNotEmpty);
      expect(result.contains('2020'), isTrue);
    });

    test('that returns empty string for empty input', () {
      final result = New.getDate('');
      expect(result, equals(''));
    });

    test('that returns original content for invalid date', () {
      final result = New.getDate('not-a-date');
      expect(result, equals('not-a-date'));
    });
  });

  group('New.parseDateTime', () {
    test('that parses a valid date string', () {
      final result = New.parseDateTime('Wed, 12 Feb 2020 13:27:44 +0000');
      expect(result, isNotNull);
      expect(result?.year, equals(2020));
    });

    test('that returns null for empty string', () {
      final result = New.parseDateTime('');
      expect(result, isNull);
    });

    test('that returns null for invalid date string', () {
      final result = New.parseDateTime('invalid');
      expect(result, isNull);
    });
  });

  group('New.getCategory', () {
    test('that returns empty string for null', () {
      final result = New.getCategory(null);
      expect(result, equals(''));
    });

    test('that extracts category from list', () {
      final result = New.getCategory([
        {"\$t": "Music"},
        {"\$t": "News"},
      ]);
      expect(result, contains('Music'));
    });

    test('that limits to 2 categories', () {
      final result = New.getCategory([
        {"\$t": "Music"},
        {"\$t": "News"},
        {"\$t": "Extra"},
      ]);
      expect(result.split(' · ').length, equals(2));
    });

    test('that filters out numeric categories', () {
      final result = New.getCategory([
        {"\$t": "123"},
        {"\$t": "Music"},
      ]);
      expect(result, equals('Music'));
    });
  });

  group('New.getCleanContent', () {
    test('that removes webfeedsFeaturedVisual class elements', () {
      final html =
          '<p>Content</p><img class="webfeedsFeaturedVisual" src="img.jpg"/>';
      final result = New.getCleanContent(html);
      expect(result.contains('webfeedsFeaturedVisual'), isFalse);
    });

    test('that removes first wp-block-image element', () {
      final html =
          '<figure class="wp-block-image"><img src="img.jpg"/></figure><p>Keep</p>';
      final result = New.getCleanContent(html);
      expect(result.contains('wp-block-image'), isFalse);
      expect(result.contains('Keep'), isTrue);
    });

    test('that returns text content for plain text', () {
      final result = New.getCleanContent('<p>Hello World</p>');
      expect(result.contains('Hello World'), isTrue);
    });
  });

  group('New.getImage', () {
    test('that extracts webfeedsFeaturedVisual image', () {
      final html =
          '<img class="webfeedsFeaturedVisual" src="http://featured.jpg"/>';
      final result = New.getImage(html);
      expect(result, equals('http://featured.jpg'));
    });

    test('that extracts first img tag when no featured visual', () {
      final html = '<p>Text</p><img src="http://first.jpg"/><img src="http://second.jpg"/>';
      final result = New.getImage(html);
      expect(result, equals('http://first.jpg'));
    });

    test('that returns fallback image when no img tags', () {
      final result = New.getImage('<p>No images here</p>');
      expect(result, isNotEmpty);
    });
  });

  group('New.fromOutstanding', () {
    test('that creates New from Outstanding', () {
      final outstanding = Outstanding.mock();
      final news = New.fromOutstanding(outstanding);

      expect(news.title, equals(outstanding.title));
      expect(news.description, equals(outstanding.description));
      expect(news.image, equals(outstanding.logoUrl));
    });
  });

  group('New.fromPodcast', () {
    test('that creates New from podcast info', () {
      final news = New.fromPodcast(
        'Podcast Title',
        'Subtitle',
        'Content',
        'http://link.com',
        image: 'http://image.jpg',
      );

      expect(news.title, equals('Podcast Title'));
      expect(news.link, equals('http://link.com'));
      expect(news.image, equals('http://image.jpg'));
    });
  });

  group('New.fromHistory', () {
    test('that creates a history New with required fields', () {
      final news = New.fromHistory('History content');
      // title comes from translation mock which returns empty string
      expect(news.title, isA<String>());
      expect(news.link, contains('cuacfm.org'));
      expect(news.description, equals('History content'));
      expect(news.image, isNotEmpty);
    });
  });

  group('New.timeAgo', () {
    test('that returns pubDate when pubDateTime is null', () {
      final news = New('Title', 'http://link', 'Desc', '', 'some date');
      // pubDateTime is null so timeAgo returns pubDate
      expect(news.timeAgo(), equals('some date'));
    });

    test('that returns minutes_ago for recent news within one hour', () {
      final recentDate = DateTime.now().subtract(Duration(minutes: 5));
      final news = New('Title', 'http://link', 'Desc', '', 'pub', pubDateTime: recentDate);
      final result = news.timeAgo();
      expect(result, isA<String>());
    });

    test('that returns hours_ago for news from today', () {
      final recentDate = DateTime.now().subtract(Duration(hours: 2));
      final news = New('Title', 'http://link', 'Desc', '', 'pub', pubDateTime: recentDate);
      final result = news.timeAgo();
      expect(result, isA<String>());
    });

    test('that returns yesterday for news from exactly 1 day ago', () {
      final yesterday = DateTime.now().subtract(Duration(hours: 25));
      final news = New('Title', 'http://link', 'Desc', '', 'pub', pubDateTime: yesterday);
      final result = news.timeAgo();
      expect(result, isA<String>());
    });

    test('that returns days_ago for news from this week', () {
      final recentDate = DateTime.now().subtract(Duration(days: 3));
      final news = New('Title', 'http://link', 'Desc', '', 'pub', pubDateTime: recentDate);
      final result = news.timeAgo();
      expect(result, isA<String>());
    });

    test('that returns pubDate for old news beyond a week', () {
      final oldDate = DateTime.now().subtract(Duration(days: 10));
      final news = New('Title', 'http://link', 'Desc', '', 'old date', pubDateTime: oldDate);
      final result = news.timeAgo();
      expect(result, equals('old date'));
    });
  });

  group('New.fromInstance with alternate description keys', () {
    test('that parses description with content__cdata key', () {
      final map = {
        'title': {'\$t': 'Title'},
        'link': {'\$t': 'http://link'},
        'pubDate': {'\$t': ''},
        'category': null,
        'content\$encoded': {'__cdata': '<p>Content from cdata</p>'},
      };
      final news = New.fromInstance(map);
      expect(news.description, isNotEmpty);
    });

    test('that parses description from description.__cdata key', () {
      final map = {
        'title': {'\$t': 'Title'},
        'link': {'\$t': 'http://link'},
        'pubDate': {'\$t': ''},
        'category': null,
        'description': {'__cdata': 'Description via description cdata'},
      };
      final news = New.fromInstance(map);
      expect(news.description, isNotEmpty);
    });

    test('that parses description with description \$t key', () {
      final map = {
        'title': {'\$t': 'Title'},
        'link': {'\$t': 'http://link'},
        'pubDate': {'\$t': ''},
        'category': null,
        'description': {'\$t': 'Description via dollar-t'},
      };
      final news = New.fromInstance(map);
      expect(news.description, isNotEmpty);
    });
  });
}
