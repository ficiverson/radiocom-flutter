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
  String category;
  DateTime? pubDateTime;

  New(this.title, this.link, this.description, this.image, this.pubDate, {this.pubDateTime, this.category = ""});

  New.fromInstance(Map<String, dynamic> map)
      : title = map["title"]?["\$t"] ?? map["title"] ?? "",
        link = map["link"]?["\$t"] ?? map["link"] ?? "",
        pubDate = getDate(map["pubDate"]?["\$t"] ?? map["pubDate"] ?? ""),
        pubDateTime = parseDateTime(map["pubDate"]?["\$t"] ?? map["pubDate"] ?? ""),
        category = getCategory(map["category"]),
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

  static String getCategory(dynamic raw) {
    if (raw == null) return "";
    final List items = raw is List ? raw : [raw];
    final excluded = RegExp(r'^\d+$');
    final results = <String>[];
    for (final item in items) {
      final value = item?["\$t"] ?? item?["__cdata"] ?? item?.toString() ?? "";
      if (value.isNotEmpty && !excluded.hasMatch(value)) results.add(value);
      if (results.length == 2) break;
    }
    return results.join(' · ');
  }

  static String getCleanContent(String content) {
    var document = parse(content);
    // Remove featured image (webfeedsFeaturedVisual)
    for (final el in document.body?.getElementsByClassName("webfeedsFeaturedVisual") ?? []) {
      el.remove();
    }
    // Remove wp-block-image (WordPress featured image wrapper)
    final wpImages = document.body?.getElementsByClassName("wp-block-image") ?? [];
    if (wpImages.isNotEmpty) {
      wpImages[0].remove();
    }
    return document.body?.innerHtml ?? content;
  }

  static DateTime? parseDateTime(String content) {
    if (content.isEmpty) return null;
    try {
      return DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US").parse(content);
    } catch (_) {
      return null;
    }
  }

  static String getDate(String content) {
    if (content.isEmpty) return "";
    try {
      final date = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US").parse(content);
      const months = ["ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (e) {
      return content;
    }
  }

  String timeAgo() {
    if (pubDateTime == null) return pubDate;
    final diff = DateTime.now().difference(pubDateTime!);
    if (diff.inMinutes < 60) {
      return "Hai ${diff.inMinutes} min";
    } else if (diff.inHours < 24) {
      return "Hai ${diff.inHours} h";
    } else if (diff.inDays == 1) {
      return "Onte";
    } else if (diff.inDays < 7) {
      return "Hai ${diff.inDays} días";
    } else {
      return pubDate;
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
        "https://cuacfm.org/wp-content/uploads/2015/04/cousomicros1.jpg",
        getDate("Wed, 20 Mar 1996 12:00:00 +0000"));
  }

  static New fromOutstanding(Outstanding outstanding) {
    return New(
        outstanding.title,
        "https://cuacfm.org/avisos-movil/",
        outstanding.description,
        outstanding.logoUrl,
        "");
  }

  static New fromPodcast(
      String title, String subtitle, String content, String link, {String image = ""}) {
    return New(title, link, content, image, subtitle);
  }
}
