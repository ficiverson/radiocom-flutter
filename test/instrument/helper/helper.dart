import 'dart:io';

class Helper{
  // Steps to generate tests by command line
  // To run tests test flutter test --coverage
  // to Extract report  genhtml coverage/lcov.info -o coverage

  static String readFile(String path) {
    if (Directory.current.path.endsWith('/test')) {
      Directory.current = Directory.current.parent;
    }
    final file = new File(path);
    return file.readAsStringSync();
  }
}