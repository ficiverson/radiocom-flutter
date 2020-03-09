import 'package:cuacfm/models/episode.dart';

class EpisodeInstrument {
  static Episode givenAnEpisode({String audioUrl}) {
    return Episode.fromInstance({
      "title": {"\$t": "title"},
      "link": {"\$t": "http://social"},
      "pubDate": {"\$t": "Wed, 12 Feb 2020 13:27:44 +0000"},
      "description": {"\$t": "desc"},
      "enclosure": {"url": audioUrl != null ? audioUrl : "http://audio"},
      "itunes\$duration": {"\$t": "0:01:00"}
    });
  }
}
