import 'dart:io';

class Helper{
  static String readFile(String path) {
    if (Directory.current.path.endsWith('/test')) {
      Directory.current = Directory.current.parent;
    }
    final file = new File(path);
    return file.readAsStringSync();
  }
}