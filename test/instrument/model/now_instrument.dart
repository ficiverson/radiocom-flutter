
import 'package:cuacfm/models/now.dart';

class NowInstrument {
  static Now givenANow() {
    return Now.fromInstance({
      "name": "Spoiler",
      "description":"Best program now",
      "programme_url": "https://url/program",
      "logo_url": "assets/graphics/cuac-logo.png",
      "rss_url": "http://image"
    });
  }
}