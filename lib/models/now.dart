class Now {
  String name;
  String description;
  String programme_url;
  String logo_url;
  String rss_url;

  Now.mock()
      :
        name = "CUAC",
        logo_url = "https://i2.wp.com/cuacfm.org/wp-content/uploads/2017/09/logo-escola-de-ver%C3%A1n.png?resize=500%2C500&ssl=1";

  Now.fromInstance(Map<String, dynamic> map)
      :
        name = map["name"],
        description = map["description"],
        programme_url = map["programme_url"],
        logo_url = map["logo_url"],
        rss_url = map["rss_url"];
}