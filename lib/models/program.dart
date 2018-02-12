class Program {
  String name;
  String description;
  String logo_url;
  String rss_url;
  String type;

  Program.fromInstance(Map<String, dynamic> map)
      :
        name = map["name"],
        description = map["description"],
        logo_url = map["logo_url"],
        type = map["type"],
        rss_url = map["rss_url"];
}