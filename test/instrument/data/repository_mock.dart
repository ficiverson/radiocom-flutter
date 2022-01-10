import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
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

class MockRadiocoRepository extends Mock implements CuacRepositoryContract {
  @override Future<Result<List<TimeTable>>> getTimetableData(String? after, String? before) =>
      super.noSuchMethod(Invocation.method(#getTimetableData, [after, before]));
  @override Future<Result<List<Episode>>> getEpisodes(String? feedUrl) =>
      super.noSuchMethod(Invocation.method(#getEpisodes, [feedUrl]));

  static Future<Result<RadioStation>> radioStation({bool isEmpty = false}) {
    return Future.value(isEmpty
        ? Error(
            RadioStation.base(), Status.fail, "error")
        : Success(RadioStationInstrument.givenARadioStation(), Status.ok));
  }

  static Future<Result<Now>> now({bool isEmpty = false}) {
    return Future.value(isEmpty
        ? Error(Now.mock(), Status.fail, "error")
        : Success(NowInstrument.givenANow(), Status.ok));
  }

  static Future<Result<List<TimeTable>>> timetables({bool isEmpty = false}) {
    return Future.value(isEmpty
        ? Error([], Status.fail, "error")
        : Success([TimeTableInstrument.givenATimeTable()], Status.ok));
  }

  static Future<Result<List<Program>>> podcasts({bool isEmpty = false}) {
    return Future.value(isEmpty
        ? Error([], Status.fail, "error")
        : Success([ProgramInstrument.givenAProgram()], Status.ok));
  }

  static Future<Result<List<New>>> news({bool isEmpty = false}) {
    return Future.value(isEmpty
        ? Error([], Status.fail, "error")
        : Success([NewInstrument.givenANew()], Status.ok));
  }

  static Future<Result<List<Episode>>> episodes({bool isEmpty = false}) {
    return Future.value(isEmpty
        ? Error([], Status.fail, "error")
        : Success([EpisodeInstrument.givenAnEpisode()], Status.ok));
  }
}
