import 'package:cuacfm/models/license.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('License', () {
    test('that constructor sets name and description', () {
      final license = License('my-lib', 'MIT License');
      expect(license.name, equals('my-lib'));
      expect(license.description, equals('MIT License'));
    });
  });

  group('License.getAll', () {
    test('that returns a non-empty list', () {
      final licenses = License.getAll();
      expect(licenses, isNotEmpty);
    });

    test('that each license has a name and description', () {
      for (final license in License.getAll()) {
        expect(license.name, isNotEmpty);
        expect(license.description, isNotEmpty);
      }
    });

    test('that injector is in the list', () {
      final names = License.getAll().map((l) => l.name).toList();
      expect(names, contains('injector'));
    });
  });
}
