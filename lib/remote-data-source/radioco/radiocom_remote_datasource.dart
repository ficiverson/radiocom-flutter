import 'dart:async';
import 'dart:convert';

import 'package:cuacfm/data/datasource/radioco_remote_datasource.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/remote-data-source/network/radioco_api.dart';
import 'package:cuacfm/utils/cuac_client.dart';
import 'package:cuacfm/utils/simple_client.dart';
import 'package:injector/injector.dart';

class RadiocoRemoteDataSource implements RadiocoRemoteDataSourceContract {
  final CUACClient client = Injector.appInstance.getDependency<CUACClient>();
  RadiocoAPIContract radiocoAPI;
  RadiocoRemoteDataSource() {
    radiocoAPI = Injector.appInstance.getDependency<RadiocoAPIContract>();
  }

  Future<RadioStation> getRadioStationData() async {
    Uri url;
    try {
      Uri.parse(radiocoAPI.baseUrl + radiocoAPI.radioStation);
      var res = await this.client.get(url);
      return new RadioStation.fromInstance(res);
    } catch (Exception) {
      return RadioStation.base();
    }
  }

  Future<Now> getLiveBroadcast() async {
    Uri url = Uri.parse(radiocoAPI.baseUrl + radiocoAPI.live);
    try {
      var res = await this.client.get(url);
      return new Now.fromInstance(res);
    } catch (Exception) {
      return null;
    }
  }

  Future<List<TimeTable>> getTimetableData(String after, String before) async {
    Uri url = Uri.parse(radiocoAPI.baseUrl +
        radiocoAPI.timetable +
        radiocoAPI.timetableAfter +
        after +
        radiocoAPI.timetableBefore +
        before);
    try {
      List<dynamic> res = await this.client.get(url);
      List<TimeTable> programsTimeTable =
          res.map((g) => new TimeTable.fromInstance(g)).toList();
      return programsTimeTable;
    } catch (Exception) {
      return [];
    }
  }

  Future<List<Program>> getAllPodcasts() async {
    Uri url = Uri.parse(radiocoAPI.baseUrl + radiocoAPI.podcast);
    try {
      List<dynamic> res = await this.client.get(url);

      List<Program> programs = res.map((g) => new Program.fromInstance(g)).toList();
      return programs;
    } catch (Exception) {
      return [];
    }
  }

  @override
  Future<List<New>> getNews() async {
    try {
      RadioStation radioStation =
          Injector.appInstance.getDependency<RadioStation>();

      List<dynamic> res = await this.client.get(Uri.parse(radioStation.news_rss), responseType : HTTPResponseType.XML);
      List<New> newsList = res.map((n) => new New.fromInstance(n)).toList();
      return newsList;
    } catch (err) {
      return [];
    }
  }
}
