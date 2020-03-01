class License {
  String name;
  String description;

  License(this.name, this.description);

  static List<License> getAll() {
    return [
      License("injector",
          "https://pub.dartlang.org/packages/injector \n\nApache License Version 2.0, January 2004 http://www.apache.org/licenses/"),
      License("carousel_slider",
          "https://pub.dartlang.org/packages/carousel_slider \n\nMIT License Copyright (c) 2017 serenader"),
      License("audioplayers",
          "https://pub.dartlang.org/packages/audioplayers \n\nMIT License Copyright (c) 2017 Luan Nico"),
      License("photo_view",
          "https://pub.dartlang.org/packages/photo_view \n\nMIT License Copyright 2018 Renan C. Araújo"),
      License("maps_launcher",
          "https://pub.dartlang.org/packages/maps_launcher \n\nMIT License Copyright Copyright (c) 2019 Julien Scholz"),
      License("phonecallstate",
          "https://pub.dartlang.org/packages/phonecallstate \n\nNot defined"),
      License("xml2json",
          "https://pub.dartlang.org/packages/xml2json \n\nBSD 3-Clause \"New\" or \"Revised\" License"),
      License("share",
          "https://pub.dartlang.org/packages/device_info \n\nBSD 3-Clause \"New\" or \"Revised\" License"),
      License("device_info",
          "https://pub.dartlang.org/packages/auto_size_text \n\nMIT License Copyright (c) 2018 Simon Leier"),
      License("flutter_html",
          "https://pub.dartlang.org/packages/flutter_html \n\nMIT License Copyright (c) 2019 Matthew Whitaker"),
      License("cached_network_image",
          "https://pub.dev/packages/cached_network_image \n\nThe MIT License (MIT) Copyright (c) 2018 Rene Floor"),
      License("font_awesome_flutter",
          "https://pub.dev/packages/font_awesome_flutter/versions/8.0.1 \n\nThe MIT License (MIT) Copyright (c) 2017 Brian Egan"),
      License("url_launcher",
          "https://pub.dev/packages/url_launcher \n\nBSD(3) Copyright 2017 The Chromium Authors. All rights reserved.")
    ];
  }
}