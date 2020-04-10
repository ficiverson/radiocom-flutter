import 'package:cuacfm/models/radiostation.dart';

class RadioStationInstrument {
  static RadioStation givenARadioStation({String feed}) {
    return RadioStation.fromInstance({
      "station_name": "CUAC FM INSTRUMENT",
      "icon_url": "assets/graphics/cuac-logo.png",
      "big_icon_url": "assets/graphics/cuac-logo.png",
      "station_photos": [
        "assets/graphics/cuac-logo.png",
        "assets/graphics/cuac-logo.png",
        "assets/graphics/cuac-logo.png"
      ],
      "history": "history",
      "latitude": 43.327552,
      "longitude": -8.4090277,
      "news_rss": feed != null ? feed : "http://feed",
      "stream_url": "http://streaming.cuacfm.org/cuacfm.mp3",
      "facebook_url": "http://facebook",
      "twitter_url": "http://facebook",
    });
  }
}
