import 'dart:convert';

import 'package:audioplayer/audioplayer.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/repository/CuacRepository.dart';
import 'package:xml2json/xml2json.dart';
import 'package:flutter/services.dart';

abstract class HomeView {
  void onLoadRadioStation(RadioStation station);

  void onLoadNews(List<New> news);

  void onLoadLiveData(Now now);

  void onLoadPodcasts(List<Program> podcasts);

  void onPlayerReady();

  void onPlayerStopped();
}

enum PlayerState {
  play,
  stop,
  pause
}

class HomePresenter {

  HomeView _homeView;
  AudioPlayer audioPlayer;
  var _playerState;
  CuacRepository _repository;

  HomePresenter(this._homeView, [CuacRepository repository]) {
    audioPlayer = new AudioPlayer();
    _repository = _repository != null ? repository : new CuacRepository();
  }

  getNews() async {
    List newsObj = [];
    var xml2json = new Xml2Json();
    var httpClient = createHttpClient();

    var response = await httpClient.get("https://cuacfm.org/feed/");
    xml2json.parse(response.body);
    xml2json.toBadgerfish();
    xml2json.toParker();
    xml2json.xmlParserResult.findAllElements("img");

    Map news = JSON.decode(xml2json.toGData());

    if (news.containsKey("rss")) {
      newsObj = news["rss"]["channel"]["item"];
      List<New> newsList = newsObj
          .map((n) => new New.fromInstance(n))
          .toList();
      _homeView.onLoadNews(newsList);
    }
  }

  getRadioStationData() {
    _repository.getRadioStationData()
        .catchError((err) {
      //todo use error
    })
        .then((station) {
      _homeView.onLoadRadioStation(station);
    });
  }

  getLiveProgram() {
    _repository.getLiveBroadcast()
        .catchError((err) {
      //todo use error
    })
        .then((now) {
      _homeView.onLoadLiveData(now);
    });
  }

  getAllPodcasts() {
    _repository.getAllPodcasts()
        .catchError((err) {
      //todo use error
    })
        .then((podcasts) {
      _homeView.onLoadPodcasts(podcasts);
    });
  }

  play() async {
    if (_playerState != PlayerState.play) {
      final result = await audioPlayer.play(
          "https://streaming.cuacfm.org/cuacfm.mp3", isLocal: false);
      if (result == 1) _playerState = PlayerState.play;
      _homeView.onPlayerReady();
    } else {
      final result = await audioPlayer.stop();
      if (result == 1) _playerState = PlayerState.stop;
      _homeView.onPlayerStopped();
    }
  }

}