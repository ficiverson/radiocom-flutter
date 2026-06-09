import 'package:cuacfm/domain/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('that getStatus returns the status', () {
      final result = Result<String>(Status.ok, 'data');
      expect(result.getStatus(), equals(Status.ok));
    });

    test('that getStatus returns fail status', () {
      final result = Result<String>(Status.fail, null);
      expect(result.getStatus(), equals(Status.fail));
    });

    test('that getData returns the data', () {
      final result = Result<String>(Status.ok, 'data');
      expect(result.getData(), equals('data'));
    });
  });

  group('Success', () {
    test('that Success has ok status', () {
      final result = Success<String>('value', Status.ok);
      expect(result.status, equals(Status.ok));
      expect(result.getData(), equals('value'));
    });
  });

  group('Error', () {
    test('that Error has fail status', () {
      final result = Error<String>('', Status.fail, 'Something went wrong');
      expect(result.status, equals(Status.fail));
    });
  });
}
