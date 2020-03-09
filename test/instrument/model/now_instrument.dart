
import 'package:cuacfm/models/now.dart';

class NowInstrument {
  static Now givenANow() {
    return Now.fromInstance({
      "name": "Spoiler",
      "description":"Best program now",
      "programme_url": "https://url/program",
      "logo_url": "http://image",
      "rss_url": "http://image"
    });
  }
}