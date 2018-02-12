import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:cuacfm/injector/dependecy_injector.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/repository/RadiocomRepository.dart';
import 'package:xml2json/xml2json.dart';
import 'package:flutter/services.dart';

abstract class HomeView {
  void onLoadRadioStation(RadioStation station);

  void onLoadNews(List<New> news);

  void onLoadLiveData(Now now);

  void onLoadPodcasts(List<Program> podcasts);

  void onLoadTimetable(List<TimeTable> programsTimeTable);

  void onPlayerReady();

  void onPlayerStopped();

  void playerDuration(int durationMS);

  void playerPosition(int positionMS);
}


class HomePresenter {

  HomeView _homeView;
  CuacRepository _repository;

  HomePresenter(this._homeView, [CuacRepository repository]) {
    _repository = _repository != null ? repository : new CuacRepository();
  }

  getNews() async {
    try {
      List newsObj = [];
      var xml2json = new Xml2Json();
      var httpClient = createHttpClient();

      var response = await httpClient.get("https://cuacfm.org/feed/");
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

    }
  }

  getRadioStationData() {
    _repository.getRadioStationData()
        .catchError((err) {
      //todo use error
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
      //todo use error
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
    String tomorrow =  formatter.format(nowDate.toUtc().add(new Duration(days: 1)));
    _repository.getTimetableData(now,tomorrow)
        .catchError((err) {
      //todo use error
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
      //todo use error
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