class TimeTable {
  String name;
  String description;
  DateTime start;
  DateTime end;
  String logo_url;
  String rss_url;
  String type;

  TimeTable.fromInstance(Map<String, dynamic> map)
      :
        name = map["name"],
        description = map["description"],
        start = DateTime.parse(map["start"]),
        end = DateTime.parse(map["end"]),
        type = map["type"],
        logo_url = map["logo_url"],
        rss_url = map["rss_url"];

  Map <String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
      "logo_url": logo_url,
      "rss_url": rss_url
    };
  }

}