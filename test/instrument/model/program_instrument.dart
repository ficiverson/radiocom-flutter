import 'package:cuacfm/models/program.dart';

class ProgramInstrument {
  static Program givenAProgram() {
    return Program.fromInstance({
      "name": "Spoiler",
      "synopsis":"desc",
      "photo_url": "assets/graphics/cuac-logo.png",
      "runtime": "02:00:00",
      "language": "es",
      "rss_url": "http://feed",
      "category" : "TV & Film"
    });
  }
}