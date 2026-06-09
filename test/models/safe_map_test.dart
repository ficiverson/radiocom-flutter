import 'package:cuacfm/utils/safe_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SafeMap.safe', () {
    test('that returns string value for a top-level string key', () {
      final map = {'key': 'value'};
      final result = SafeMap.safe(map, ['key']);
      expect(result, equals('value'));
    });

    test('that returns empty string for missing key', () {
      final result = SafeMap.safe({}, ['missing']);
      expect(result, equals(''));
    });

    test('that navigates nested maps with multiple keys', () {
      final map = {
        'outer': {'inner': 'nested_value'},
      };
      final result = SafeMap.safe(map, ['outer', 'inner']);
      expect(result, equals('nested_value'));
    });

    test('that returns empty string for null value', () {
      final map = {'key': null};
      final result = SafeMap.safe(map, ['key']);
      expect(result, equals(''));
    });

    test('that returns empty string when nested key is missing', () {
      final map = {'outer': <String, dynamic>{}};
      final result = SafeMap.safe(map, ['outer', 'inner']);
      expect(result, equals(''));
    });

    test('that handles exceptions gracefully and returns empty string', () {
      // Passing invalid types that might cause cast issues
      final map = {'key': 42};
      final result = SafeMap.safe(map, ['key']);
      expect(result, equals(''));
    });
  });
}
