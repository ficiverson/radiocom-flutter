import 'dart:convert';

import 'package:cuacfm/repository/network_utils.dart';
import 'package:intl/intl.dart';
import 'package:cuacfm/injector/dependecy_injector.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/repository/radiocom-repository.dart';
import 'package:xml2json/xml2json.dart';
import 'package:flutter/services.dart';

abstract class HomeView {
  void onLoadRadioStation(RadioStation station);

  void onRadioStationError(dynamic error);

  void onLoadNews(List<New> news);

  void onNewsError(dynamic error);

  void onLoadLiveData(Now now);

  void onLiveDataError(dynamic error);

  void onLoadPodcasts(List<Program> podcasts);

  void onPodcastError(dynamic error);

  void onLoadTimetable(List<TimeTable> programsTimeTable);

  void onTimetableError(dynamic error);

  void onPlayerReady();

  void onPlayerStopped();

  void playerDuration(int durationMS);

  void playerPosition(int positionMS);
}


class HomePresenter {

  HomeView _homeView;
  CuacRepository _repository;
  RadioStation _station;

  HomePresenter(this._homeView, [CuacRepository repository]) {
    _station = new RadioStation.base();
    _repository = _repository != null ? repository : new CuacRepository();
  }

  setStation(RadioStation station) {
    _station = station;
  }

  getNews() async {
    try {
      List newsObj = [];
      var xml2json = new Xml2Json();
      var httpClient = createHttpClient();

      var response = await httpClient.get(_station.news_rss);
      xml2json.parse(response.body);
      Map news = JSON.decode(xml2json.toGData());

      if (news.containsKey("rss")) {
        newsObj = news["rss"]["channel"]["item"];
        List<New> newsList = newsObj
            .map((n) => new New.fromInstance(n))
            .toList();
        if (newsList != null) {
          _homeView.onLoadNews(newsList);
        }
      }
    } catch (err) {
      _homeView.onNewsError(err);
    }
  }

  getRadioStationData() {
    _repository.getRadioStationData()
        .catchError((err) {
      _homeView.onRadioStationError(err);
    })
        .then((station) {
      if (station != null) {
        _homeView.onLoadRadioStation(station);
      }
    });
  }

  getLiveProgram() {
    _repository.getLiveBroadcast()
        .catchError((err) {
      _homeView.onLiveDataError(err);
    })
        .then((now) {
      if (now != null) {
        _homeView.onLoadLiveData(now);
      }
    });
  }

  getTimetable() {
    DateTime nowDate = new DateTime.now();
    var formatter = new DateFormat('dd/MM/yyyy');
    String now = formatter.format(nowDate);
    String tomorrow = formatter.format(
        nowDate.toUtc().add(new Duration(days: 1)));
    _repository.getTimetableData(now, tomorrow)
        .catchError((err) {
      _homeView.onTimetableError(err);
    })
        .then((programsTimetable) {
      if (programsTimetable != null) {
        _homeView.onLoadTimetable(programsTimetable);
      }
    });
  }

  getAllPodcasts() {
    _repository.getAllPodcasts()
        .catchError((err) {
      _homeView.onPodcastError(err);
    })
        .then((podcasts) {
      if (podcasts != null) {
        _homeView.onLoadPodcasts(podcasts);
      }
    });
  }


  play(String url) async {
    if (Injector.playerState != PlayerState.play) {
      final result = await Injector.player.play(
          url, isLocal: false);
      if (result == 1) Injector.playerState = PlayerState.play;
      _homeView.onPlayerReady();
    }
  }

  stopAndPlay(String url) async {
    if (Injector.playerState == PlayerState.play ||
        Injector.playerState == PlayerState.pause) {
      final result = await Injector.player.stop();
      if (result == 1) Injector.playerState = PlayerState.stop;
      Injector.resetPlayer();
      final playResult = await Injector.player.play(
          url, isLocal: false);
      if (playResult == 1) Injector.playerState = PlayerState.play;
      _homeView.onPlayerReady();
    }
  }

  stop() async {
    if (Injector.playerState == PlayerState.play ||
        Injector.playerState == PlayerState.pause) {
      final result = await Injector.player.stop();
      if (result == 1) Injector.playerState = PlayerState.stop;
      _homeView.onPlayerStopped();
      Injector.resetPlayer();
    }
  }

  bool isPlaying() {
    return Injector.playerState == PlayerState.play;
  }

  seekTo(double position) async {
    final result = await Injector.player.seek(position);
    if (result == 1) Injector.playerState = PlayerState.play;
  }


  setHandlers() {
    Injector.player.setDurationHandler((duration) {
      _homeView.playerDuration(duration.inMilliseconds);
    });
    Injector.player.setPositionHandler((position) {
      _homeView.playerPosition(position.inMilliseconds);
    });
  }

}