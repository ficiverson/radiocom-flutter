import 'dart:math';

import 'package:cuacfm/models/outstanding.dart';
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
      : title = map["title"]?["\$t"] ?? map["title"] ?? "",
        link = map["link"]?["\$t"] ?? map["link"] ?? "",
        pubDate = getDate(map["pubDate"]?["\$t"] ?? map["pubDate"] ?? ""),
        image = getImage(map["content:encoded"]?["\$t"] ??
            map["content\$encoded"]?["__cdata"] ??
            map["description"]?["\$t"] ??
            map["description"]?["__cdata"] ??
            map["description"] ??
            ""),
        description = getCleanContent(map["content:encoded"]?["\$t"] ??
            map["content\$encoded"]?["__cdata"] ??
            map["description"]?["\$t"] ??
            map["description"]?["__cdata"] ??
            map["description"] ??
            "");

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
    if (content == null || content.isEmpty) return "";
    try {
      return DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US")
          .parse(content)
          .toString()
          .split(" ")[0];
    } catch (e) {
      return content;
    }
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
              "https://cuacfm.org/wp-content/uploads/2025/05/parrulo-violeta.jpg?ssl=1";
          break;
        case 1:
          baseImage =
              "https://cuacfm.org/wp-content/uploads/2025/05/parrulo-amarillo.jpg?ssl=1";
          break;
        case 2:
          baseImage =
              "https://cuacfm.org/wp-content/uploads/2025/05/parrulo-azul.jpg?ssl=1";
          break;
        case 3:
          baseImage =
              "https://cuacfm.org/wp-content/uploads/2025/05/parrulo-naranja.jpg?ssl=1";
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

  static New fromOutstanding(Outstanding outstanding) {
    return New(
        outstanding.title,
        "https://cuacfm.org/avisos-movil/",
        outstanding.description,
        outstanding.logoUrl,
        DateFormat("dd MMM yyyy").format(DateTime.now()));
  }

  static New fromPodcast(
      String title, String subtitle, String content, String link) {
    return New(title, link, content, "", subtitle);
  }
}
