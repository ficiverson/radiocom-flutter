import 'dart:convert';

import 'package:audioplayer/audioplayer.dart';
import 'package:xml2json/xml2json.dart';
import 'package:flutter/services.dart';

abstract class HomeView {
  void onLoadNews(List newsObj);

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

  HomePresenter(this._homeView) {
    audioPlayer = new AudioPlayer();
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
      _homeView.onLoadNews(newsObj);
    }
  }

  play() async {
    if (_playerState != PlayerState.play) {
      final result = await audioPlayer.play(
          "https://streaming.cuacfm.org/cuacfm.aac", isLocal: false);
      if (result == 1) _playerState = PlayerState.play;
      _homeView.onPlayerReady();
    } else {
      final result = await audioPlayer.stop();
      if (result == 1) _playerState = PlayerState.stop;
      _homeView.onPlayerStopped();
    }
  }

}