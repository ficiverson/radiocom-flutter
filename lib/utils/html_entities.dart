import 'package:html/parser.dart' show parse;

class HtmlEntities {
  static String decode(String text) {
    if (!text.contains('&')) return text;
    return parse(text).body?.text ?? text;
  }
}
