import 'dart:async';

import 'package:cuacfm/data/datasource/radioco_remote_datasource.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/outstanding.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/remote-data-source/network/radioco_api.dart';
import 'package:cuacfm/utils/cuac_client.dart';
import 'package:cuacfm/utils/simple_client.dart';
import 'package:injector/injector.dart';

class RadiocoRemoteDataSource implements RadiocoRemoteDataSourceContract {
  final CUACClient client = Injector.appInstance.get<CUACClient>();
  RadiocoAPIContract radiocoAPI =
      Injector.appInstance.get<RadiocoAPIContract>();
  final String publishState = "publish";

  Future<RadioStation> getRadioStationData() async {
    Uri url = Uri.parse(radiocoAPI.baseUrl + radiocoAPI.radioStation);
    try {
      var res = await this.client.get(url);
      return RadioStation.fromInstance(res);
    } catch (exception) {
      return RadioStation.base();
    }
  }

  Future<Now?> getLiveBroadcast() async {
    Uri url = Uri.parse(radiocoAPI.baseUrl + radiocoAPI.live);
    try {
      var res = await this.client.get(url);
      return Now.fromInstance(res);
    } catch (exception) {
      return null;
    }
  }

  Future<List<TimeTable>> getTimetableData(String after, String before) async {
    Uri url = Uri.parse(
      radiocoAPI.baseUrl +
          radiocoAPI.timetable +
          radiocoAPI.timetableAfter +
          after +
          radiocoAPI.timetableBefore +
          before,
    );
    try {
      List<dynamic> res = await this.client.get(url);
      List<TimeTable> programsTimeTable =
          res.map((g) => new TimeTable.fromInstance(g)).toList();
      return programsTimeTable;
    } catch (exception) {
      return [];
    }
  }

  Future<List<Program>> getAllPodcasts() async {
    Uri url = Uri.parse(radiocoAPI.baseUrl + radiocoAPI.podcast);
    try {
      List<dynamic> res = await this.client.get(url);

      List<Program> programs =
          res.map((g) => new Program.fromInstance(g)).toList();
      return programs;
    } catch (exception) {
      return [];
    }
  }

  @override
  Future<List<New>> getNews() async {
    try {
      RadioStation radioStation = Injector.appInstance.get<RadioStation>();

      List<dynamic> res = await this.client.get(
        Uri.parse(radioStation.newsRss),
        responseType: HTTPResponseType.XML,
      );
      List<New> newsList = res.map((n) => new New.fromInstance(n)).toList();
      return newsList;
    } catch (err) {
      return [];
    }
  }

  @override
  Future<List<Episode>> getEpisodes(String feedUrl) async {
    try {
      List<dynamic> res = await this.client.get(
        Uri.parse(feedUrl),
        responseType: HTTPResponseType.XML,
      );
      List<Episode> episodesList =
          res.map((n) => new Episode.fromInstance(n)).toList();
      return episodesList;
    } catch (err) {
      print(err);
      return [];
    }
  }

  @override
  Future<Outstanding?> getOutstanding() async {
    try {
      dynamic res = await this.client.get(
        Uri.parse(radiocoAPI.outstandingUrl),
        responseType: HTTPResponseType.JSON,
      );
      if (res["status"] == publishState) {
        Outstanding outstandingTemp = Outstanding.fromInstance(res);
        dynamic resPicture = await this.client.get(
          Uri.parse(outstandingTemp.logoUrl),
          responseType: HTTPResponseType.JSON,
        );
        outstandingTemp.updatePicture(resPicture["source_url"]);
        return outstandingTemp;
      } else {
        return null;
      }
    } catch (err) {
      print(err);
      return null;
    }
  }
}
