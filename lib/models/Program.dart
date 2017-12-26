class Program {
  String name;
  String description;
  String logo_url;
  String rss_url;

  Program.fromInstance(Map<String, dynamic> map)
      :
        name = map["name"],
        description = map["description"],
        logo_url = map["logo_url"],
        rss_url = map["rss_url"];
}