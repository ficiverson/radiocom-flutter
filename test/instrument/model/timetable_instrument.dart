import 'package:cuacfm/models/time_table.dart';

class TimeTableInstrument {
  static TimeTable givenATimeTable({bool isLive, int time}) {
    return TimeTable.fromInstance({
      "name": "Spoiler",
      "description": "desc",
      "start": time != null
          ? time < 10 ? "2020-02-25T0$time:00:00Z" : "2020-02-25T$time:00:00Z"
          : "2020-02-25T01:00:00Z",
      "end": time != null
          ? time + 1 < 10
              ? "2020-02-25T0${time + 1}:00:00Z"
              : "2020-02-25T${time + 1}:00:00Z"
          : "2020-02-25T05:00:00Z",
      "type": isLive != null ? "B" : "S",
      "logo_url": "assets/graphics/cuac-logo.png",
      "rss_url": "http://feed"
    });
  }
}
