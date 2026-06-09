import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/program.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../instrument/helper/helper-instrument.dart';

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    DependencyInjector().loadModules();
    getTranslations();
  });

  final baseMap = {
    'name': 'Test Show',
    'synopsis': 'A great show',
    'photo_url': 'http://photo.jpg',
    'runtime': '60',
    'rss_url': 'http://rss.xml',
    'language': 'gl',
    'category': 'Music',
  };

  group('Program.fromInstance', () {
    test('that parses Galician language correctly', () {
      final program = Program.fromInstance(baseMap);
      expect(program.language, equals('Galego'));
    });

    test('that parses Spanish language correctly', () {
      final map = {...baseMap, 'language': 'es'};
      final program = Program.fromInstance(map);
      expect(program.language, equals('Español'));
    });

    test('that parses all basic fields', () {
      final program = Program.fromInstance(baseMap);
      expect(program.name, equals('Test Show'));
      expect(program.description, equals('A great show'));
      expect(program.logoUrl, equals('http://photo.jpg'));
      expect(program.duration, equals('60'));
      expect(program.rssUrl, equals('http://rss.xml'));
    });

    test('that handles null category', () {
      final map = {...baseMap, 'category': null};
      final program = Program.fromInstance(map);
      expect(program.categoryType, equals(ProgramCategories.TV));
    });
  });

  group('Program.mapCategoryType', () {
    final categories = {
      'TV & Film': ProgramCategories.TV,
      'News & Politics': ProgramCategories.NEWS,
      'Sports & Recreation': ProgramCategories.SPORTS,
      'Society & Culture': ProgramCategories.SOCIETY,
      'Education': ProgramCategories.EDUCATION,
      'Comedy': ProgramCategories.COMEDY,
      'Music': ProgramCategories.MUSIC,
      'Science & Medicine': ProgramCategories.SCIENCE,
      'Arts': ProgramCategories.ARTS,
      'Government & Organizations': ProgramCategories.GOVERNMENT,
      'Health': ProgramCategories.HEALTH,
      'Technology': ProgramCategories.TECH,
    };

    for (final entry in categories.entries) {
      test('that maps ${entry.key} category', () {
        final result = Program.mapCategoryType(entry.key);
        expect(result, equals(entry.value));
      });
    }

    test('that defaults to TV for unknown category', () {
      final result = Program.mapCategoryType('Unknown');
      expect(result, equals(ProgramCategories.TV));
    });
  });

  group('Program.getImages', () {
    test('that returns image path for each category', () {
      for (final category in ProgramCategories.values) {
        final result = Program.getImages(category);
        expect(result, isNotEmpty);
      }
    });
  });

  group('Program.fromFavorite', () {
    test('that creates Program from favorite map', () {
      final map = {
        'name': 'Favorite Show',
        'description': 'Description',
        'logoUrl': 'http://logo.jpg',
        'duration': '30',
        'rssUrl': 'http://rss.xml',
        'language': 'gl',
        'category': 'Music',
      };

      final program = Program.fromFavorite(map);

      expect(program.name, equals('Favorite Show'));
      expect(program.rssUrl, equals('http://rss.xml'));
    });
  });

  group('Program.toMap', () {
    test('that serializes all fields', () {
      final program = Program.fromInstance(baseMap);
      final map = program.toMap();

      expect(map['name'], equals('Test Show'));
      expect(map['rssUrl'], equals('http://rss.xml'));
      expect(map['logoUrl'], equals('http://photo.jpg'));
    });
  });

  group('Program.mapCategory', () {
    final categoryMappings = [
      'TV & Film',
      'News & Politics',
      'Sports & Recreation',
      'Society & Culture',
      'Education',
      'Comedy',
      'Music',
      'Science & Medicine',
      'Arts',
      'Government & Organizations',
      'Health',
      'Technology',
    ];

    for (final category in categoryMappings) {
      test('that maps $category to a localized string', () {
        // Returns empty string via mock translations, but should not throw
        expect(() => Program.mapCategory(category), returnsNormally);
      });
    }

    test('that returns default for unknown category', () {
      expect(() => Program.mapCategory('Unknown Category'), returnsNormally);
    });
  });

  group('Program.getCategory', () {
    test('that returns localized string for each category enum value', () {
      for (final category in ProgramCategories.values) {
        // Returns empty string via mock translations, but should not throw
        expect(() => Program.getCategory(category), returnsNormally);
      }
    });
  });
}
