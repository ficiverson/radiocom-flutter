import 'dart:convert';

import 'package:audioplayer/audioplayer.dart';
import 'package:cuacfm/injector/dependecy_injector.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/repository/RadiocomRepository.dart';
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



class HomePresenter {

  HomeView _homeView;
  CuacRepository _repository;

  HomePresenter(this._homeView, [CuacRepository repository]) {
    _repository = _repository != null ? repository : new CuacRepository();
  }

  getNews() async {
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


  play(String url) async {
    if (Injector.playerState != PlayerState.play) {
      final result = await Injector.player.play(
          url, isLocal: false);
      if (result == 1) Injector.playerState = PlayerState.play;
      _homeView.onPlayerReady();
    }
  }

  stopAndPlay(String url) async {
    if (Injector.playerState == PlayerState.play || Injector.playerState == PlayerState.pause) {
      final result = await Injector.player.stop();
      if (result == 1) Injector.playerState = PlayerState.stop;
      final playResult = await Injector.player.play(
          url, isLocal: false);
      if (playResult == 1) Injector.playerState = PlayerState.play;
      _homeView.onPlayerReady();
    }
  }

  stop() async {
    if (Injector.playerState == PlayerState.play || Injector.playerState == PlayerState.pause) {
      final result = await Injector.player.stop();
      if (result == 1) Injector.playerState = PlayerState.stop;
      _homeView.onPlayerStopped();
    }
  }

  bool isPlaying() {
    return Injector.playerState == PlayerState.play;
  }

}