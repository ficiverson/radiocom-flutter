class Now {
  String name;
  String description;
  String programme_url;
  String logo_url;
  String rss_url;

  Now.mock()
      :
        name = "CUAC",
        logo_url = "https://cuacfm.org/radioco/media/photos/cuac.png";

  Now.fromInstance(Map<String, dynamic> map)
      :
        name = map["name"],
        description = map["description"],
        programme_url = map["programme_url"],
        logo_url = map["logo_url"],
        rss_url = map["rss_url"];
}