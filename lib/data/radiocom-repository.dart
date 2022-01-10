import 'dart:async';

import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'datasource/radioco_remote_datasource.dart';

class CuacRepository implements CuacRepositoryContract {
  RadiocoRemoteDataSourceContract remoteDataSource;
  CuacRepository({required this.remoteDataSource});

  Future<Result<RadioStation>> getRadioStationData() async {
    RadioStation station = await remoteDataSource.getRadioStationData();
    return Success(station, Status.ok);
  }

  Future<Result<Now>> getLiveBroadcast() async {
    Now? nowPlaying = await remoteDataSource.getLiveBroadcast();
    if (nowPlaying == null) {
      return Error(Now.mock(), Status.fail, "cannot connect");
    } else {
      return Success(nowPlaying, Status.ok);
    }
  }

  Future<Result<List<TimeTable>>> getTimetableData(
      String after, String before) async {
    List<TimeTable> timetables =
        await remoteDataSource.getTimetableData(after, before);
    if (timetables.isEmpty) {
      return Error([], Status.fail, "cannot connect");
    } else {
      return Success(timetables, Status.ok);
    }
  }

  Future<Result<List<Program>>> getAllPodcasts() async {
    List<Program> podcasts = await remoteDataSource.getAllPodcasts();
    if (podcasts.isEmpty) {
      return Error([], Status.fail, "cannot connect");
    } else {
      return Success(podcasts, Status.ok);
    }
  }

  @override
  Future<Result<List<New>>> getNews() async {
    List<New> news = await remoteDataSource.getNews();
    if (news.isEmpty) {
      return Error([], Status.fail, "cannot connect");
    } else {
      return Success(news, Status.ok);
    }
  }

  @override
  Future<Result<List<Episode>>> getEpisodes(String feedUrl) async {
    List<Episode> episodes = await remoteDataSource.getEpisodes(feedUrl);
    if (episodes.isEmpty) {
      return Error([], Status.fail, "cannot connect");
    } else {
      return Success(episodes, Status.ok);
    }
  }
}
