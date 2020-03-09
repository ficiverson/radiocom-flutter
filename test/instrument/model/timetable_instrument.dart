import 'package:cuacfm/models/time_table.dart';

class TimeTableInstrument{
  static TimeTable givenATimeTable({bool isLive}) {
    return TimeTable.fromInstance({
      "name": "Spoiler",
      "description":"desc",
      "start": "2020-02-25T01:00:00Z",
      "end": "2020-02-25T05:00:00Z",
      "type": isLive!=null?"B":"S",
      "logo_url": "https://pbs.twimg.com/profile_images/1058369132004028416/KVRpQGQU_400x400.jpg",
      "rss_url": "http://feed"
    });
  }
}