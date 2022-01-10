import 'package:cuacfm/data/datasource/radioco_remote_datasource.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:mockito/mockito.dart';

import '../model/episode_instrument.dart';
import '../model/news_instrument.dart';
import '../model/now_instrument.dart';
import '../model/program_instrument.dart';
import '../model/radio_station_instrument.dart';
import '../model/timetable_instrument.dart';

class MockRemoteDataSource extends Mock
    implements RadiocoRemoteDataSourceContract {
  static Future<RadioStation> radioStation(bool isEmpty) {
    if (isEmpty) {
      return Future.value(RadioStation.base());
    } else {
      return Future.value(RadioStationInstrument.givenARadioStation());
    }
  }

  static Future<Now?> now(bool isEmpty) {
    if (isEmpty) {
      return Future.value(null);
    } else {
      return Future.value(NowInstrument.givenANow());
    }
  }

  static Future<List<TimeTable>> timetable(bool isEmpty) {
    if (isEmpty) {
      return Future.value([]);
    } else {
      return Future.value([TimeTableInstrument.givenATimeTable()]);
    }
  }

  static Future<List<Program>> podcasts(bool isEmpty) {
    if (isEmpty) {
      return Future.value([]);
    } else {
      return Future.value([ProgramInstrument.givenAProgram()]);
    }
  }

  static Future<List<New>> news(bool isEmpty) {
    if (isEmpty) {
      return Future.value([]);
    } else {
      return Future.value([NewInstrument.givenANew()]);
    }
  }

  static Future<List<Episode>> episodes(bool isEmpty) {
    if (isEmpty) {
      return Future.value([]);
    } else {
      return Future.value([EpisodeInstrument.givenAnEpisode()]);
    }
  }
}
