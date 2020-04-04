class TimeTable {
  String name;
  String description;
  DateTime start;
  DateTime end;
  String duration;
  String logoUrl;
  String rssUrl;
  String type;

  TimeTable.fromInstance(Map<String, dynamic> map)
      :
        name = map["name"],
        description = map["description"],
        start = DateTime.parse(map["start"]).toLocal(),
        end = DateTime.parse(map["end"]).toLocal(),
        type = map["type"],
        logoUrl = map["logo_url"],
        duration = getDuration(DateTime.parse(map["start"]),DateTime.parse(map["end"])),
        rssUrl = map["rss_url"];

  Map <String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
      "logo_url": logoUrl,
      "rss_url": rssUrl
    };
  }

  static String getDuration(DateTime start, DateTime end){
    return end.difference(start).inMinutes.toString();
  }

}