import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helper-instrument.dart';

void main() {
  late Directory hiveTempDir;

  setUpAll(() async {
    hiveTempDir = await setupHiveForTest();
  });

  tearDownAll(() async {
    print('TEARDOWN_START');
    await teardownHiveForTest(hiveTempDir);
    print('TEARDOWN_END');
  });

  test('dummy hive test', () {
    expect(1, 1);
  });
}
