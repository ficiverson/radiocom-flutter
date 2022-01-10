import 'dart:math';

import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';

class New {
  String title;
  String link;
  String description;
  String image;
  String pubDate;

  New(this.title, this.link, this.description, this.image, this.pubDate);

  New.fromInstance(Map<String, dynamic> map)
      : title = map["title"]["\$t"],
        link = map["link"]["\$t"],
        pubDate = getDate(map["pubDate"]["\$t"]),
        image = getImage(map["description"]["__cdata"]),
        description = getCleanContent(map["content\$encoded"]["__cdata"]);

  static String getCleanContent(String content) {
    var document = parse(content);
    if ((document.body?.getElementsByClassName("wp-block-image").length ?? 0) >
        0) {
      document.body?.getElementsByClassName("wp-block-image")[0].remove();
      return document.outerHtml.toString();
    } else {
      return content;
    }
  }

  static String getDate(String content) {
    return new DateFormat("EEE, dd MMM yyyy hh:mm:ss zzzz")
        .parse(content)
        .toString()
        .split(" ")[0];
  }

  static String getImage(String content) {
    var document = parse(content);
    if ((document.body
                ?.getElementsByClassName("webfeedsFeaturedVisual")
                .length ??
            0) >
        0) {
      return document.body
              ?.getElementsByClassName("webfeedsFeaturedVisual")[0]
              .attributes["src"] ??
          "";
    } else if ((document.body?.getElementsByTagName("img").length ?? 0) > 0) {
      return document.body?.getElementsByTagName("img")[0].attributes["src"] ??
          "";
    } else {
      String baseImage =
          "https://cuacfm.org/wp-content/uploads/2015/04/cousomicros1.jpg";
      switch (Random().nextInt(5)) {
        case 0:
          baseImage =
              "https://i1.wp.com/cuacfm.org/wp-content/uploads/2014/05/parrulo-violeta.jpg?ssl=1";
          break;
        case 1:
          baseImage =
              "https://i1.wp.com/cuacfm.org/wp-content/uploads/2014/05/parrulo-amarillo.jpg?ssl=1";
          break;
        case 2:
          baseImage =
              "https://i1.wp.com/cuacfm.org/wp-content/uploads/2014/05/parrulo-azul.jpg?ssl=1";
          break;
        case 3:
          baseImage =
              "https://i1.wp.com/cuacfm.org/wp-content/uploads/2014/05/parrulo-naranja.jpg?ssl=1";
          break;
        case 4:
          baseImage =
              "https://cuacfm.org/wp-content/uploads/2015/04/cousomicros1.jpg";
          break;
      }
      return baseImage;
    }
  }

  static New fromHistory(String content) {
    return New(
        "Historia de CUAC FM",
        "https://cuacfm.org/asociacion-cuac/cuacfm/",
        content,
        "",
        getDate("Wed, 20 Mar 1996 12:00:00 +0000"));
  }

  static New fromPodcast(
      String title, String subtitle, String content, String link) {
    return New(title, link, content, "", subtitle);
  }
}
