import 'package:verbal_expressions/verbal_expressions.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class Episode {
  String title;
  String link;
  String description;
  String audio;

  Episode.fromInstance(Map<String, dynamic> map)
      :
        title = map["title"]["\$t"],
        link = map["link"]["\$t"],
        audio = map["enclosure"]["url"],
        description = map["description"]["\$t"];
}