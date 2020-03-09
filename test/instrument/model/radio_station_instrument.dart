import 'package:cuacfm/models/radiostation.dart';

class RadioStationInstrument {
  static RadioStation givenARadioStation({String feed}) {
    return RadioStation.fromInstance({
      "station_name": "CUAC FM INSTRUMENT",
      "icon_url":"https://pbs.twimg.com/profile_images/1058369132004028416/KVRpQGQU_400x400.jpg",
      "big_icon_url": "https://pbs.twimg.com/profile_images/1058369132004028416/KVRpQGQU_400x400.jpg",
      "station_photos": ["https://pbs.twimg.com/profile_images/1058369132004028416/KVRpQGQU_400x400.jpg"],
      "history": "history",
      "latitude": 43.327552,
      "longitude": -8.4090277,
      "news_rss": feed!=null?feed:"http://feed",
      "stream_url": "http://streaming.cuacfm.org/cuacfm.mp3",
      "facebook_url": "http://facebook",
      "twitter_url": "http://facebook",
    });
  }
}