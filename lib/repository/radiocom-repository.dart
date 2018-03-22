import 'dart:async';

import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/repository/network_utils.dart';
import 'package:cuacfm/utils/cuac_client.dart';

class CuacRepository {

  final CuacClient client = new CuacClient();

  CuacRepository({client});

  Future<RadioStation> getRadioStationData() {
    Uri url = Uri.parse(NetworkUtils.baseUrl + NetworkUtils.radioStation);
    return this.client.get(url)
        .then((res) {
      return new RadioStation.fromInstance(res);
    });
  }

  Future<Now> getLiveBroadcast() {
    Uri url = Uri.parse(NetworkUtils.baseUrl + NetworkUtils.live);
    return this.client.get(url)
        .then((res) {
      return new Now.fromInstance(res);
    });
  }

  Future<List<TimeTable>> getTimetableData(String after, String before) {
    Uri url = Uri.parse(NetworkUtils.baseUrl + NetworkUtils.timetable +
        NetworkUtils.timetableAfter + after + NetworkUtils.timetableBefore + before);
    return this.client.get(url)
        .then((res) {
      List<Map<String, dynamic>> items = res;
      List<TimeTable> programsTimeTable = items
          .map((g) => new TimeTable.fromInstance(g))
          .toList();
      return programsTimeTable;
    });
  }

  Future<List<Program>> getAllPodcasts() {
    Uri url = Uri.parse(NetworkUtils.baseUrl + NetworkUtils.podcast);
    return this.client.get(url)
        .then((res) {
      List<Map<String, dynamic>> items = res;
      List<Program> programs = items
          .map((g) => new Program.fromInstance(g))
          .toList();
      return programs;
    });
  }
}