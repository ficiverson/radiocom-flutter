class RadioStation {
  String station_name;
  String icon_url;
  String big_icon_url;
  List<String> station_photos;
  String history;
  double latitude;
  double longitude;
  String news_rss;
  String stream_url;
  String facebook_url;
  String twitter_url;

  RadioStation.base()
      :
        station_name = "CUAC FM",
        icon_url = "https:\/\/pbs.twimg.com\/profile_images\/2532032956\/i2da9drz65bguq6vdj43.jpeg",
        big_icon_url = "https:\/\/pbs.twimg.com\/profile_images\/2532032956\/i2da9drz65bguq6vdj43.jpeg",
        station_photos = new List<String>(),
        history = "",
        latitude = 43.327552,
        longitude = -8.4090277,
        news_rss = "https://cuacfm.org/feed/",
        stream_url = "http://streaming.cuacfm.org/cuacfm.mp3",
        facebook_url = "https://www.facebook.com/cuacfm/",
        twitter_url = "https://twitter.com/cuacfm/";

  RadioStation.fromInstance(Map<String, dynamic> map)
      :
        station_name = map["station_name"],
        icon_url = map["icon_url"],
        big_icon_url = map["big_icon_url"],
        station_photos = map["station_photos"],
        history = map["history"],
        latitude = map["latitude"],
        longitude = map["longitude"],
        news_rss = map["news_rss"],
        stream_url = map["stream_url"],
        facebook_url = map["facebook_url"],
        twitter_url = map["twitter_url"];
}