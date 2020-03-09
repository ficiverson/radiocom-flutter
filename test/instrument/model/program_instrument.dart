import 'package:cuacfm/models/program.dart';

class ProgramInstrument {
  static Program givenAProgram() {
    return Program.fromInstance({
      "name": "Spoiler",
      "synopsis":"desc",
      "photo_url": "https://pbs.twimg.com/profile_images/1058369132004028416/KVRpQGQU_400x400.jpg",
      "runtime": "02:00:00",
      "language": "es",
      "rss_url": "http://feed",
      "category" : "TV & Film"
    });
  }
}