import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/outstanding.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';

import '../instrument/helper/helper-instrument.dart';
import '../instrument/model/radio_station_instrument.dart';

void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    DependencyInjector().loadModules();
    getTranslations();
    Injector.appInstance.registerDependency<RadioStation>(
        () => RadioStationInstrument.givenARadioStation(),
        override: true);
  });

  group('Outstanding.fromInstance', () {
    test('that parses all fields from map', () {
      final map = {
        'title': {'rendered': 'My Outstanding [avisos-mobil test]'},
        'content': {'rendered': '<p>Description</p>'},
        '_links': {
          'wp:featuredmedia': [
            {'href': 'http://media.url'}
          ]
        },
        'modified': '2024-06-10T10:00:00',
      };

      final outstanding = Outstanding.fromInstance(map);

      expect(outstanding.title, equals('My Outstanding'));
      expect(outstanding.description, equals('<p>Description</p>'));
      expect(outstanding.logoUrl, equals('http://media.url'));
    });

    test('that cleans avisos-movil from title', () {
      final map = {
        'title': {'rendered': 'Title [avisos-movil class="x"]'},
        'content': {'rendered': ''},
        '_links': {
          'wp:featuredmedia': [
            {'href': ''}
          ]
        },
        'modified': '',
      };

      final outstanding = Outstanding.fromInstance(map);
      expect(outstanding.title, equals('Title'));
    });
  });

  group('Outstanding.mock', () {
    test('that creates a mock outstanding with expected values', () {
      final outstanding = Outstanding.mock();
      expect(outstanding.title, contains('Nada'));
      expect(outstanding.logoUrl, isNotEmpty);
    });
  });

  group('Outstanding.joinUS', () {
    test('that creates joinUS outstanding', () {
      final outstanding = Outstanding.joinUS();
      expect(outstanding.isJoinForm, isTrue);
      expect(outstanding.description, contains('cuacfm.org'));
    });
  });

  group('Outstanding.updatePicture', () {
    test('that updates the logo url', () {
      final outstanding = Outstanding.mock();
      outstanding.updatePicture('http://new-logo.jpg');
      expect(outstanding.logoUrl, equals('http://new-logo.jpg'));
    });
  });
}
