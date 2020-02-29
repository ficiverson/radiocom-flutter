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