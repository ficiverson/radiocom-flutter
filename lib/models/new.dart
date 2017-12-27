import 'package:verbal_expressions/verbal_expressions.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class New {
  String title;
  String link;
  String description;
  String image;

  New.fromInstance(Map<String, dynamic> map)
      :
        title = map["title"]["\$t"],
        link = map["link"]["\$t"],
        image = getImage(map["description"]["__cdata"]),
        description = map["description"]["__cdata"];


  static String getImage(String content) {
    var document = parse(content);
    if (document.body
        .getElementsByClassName("webfeedsFeaturedVisual")
        .length > 0) {
      return document.body.getElementsByClassName("webfeedsFeaturedVisual")[0]
          .attributes["src"];
    } else {
      return "https://cuacfm.org/radioco/media/photos/cuac.png";
    }
  }
}