import 'dart:convert';

import 'package:cuacfm/injector/dependecy_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/repository/radiocom-repository.dart';
import 'package:xml2json/xml2json.dart';
import 'package:flutter/services.dart';

abstract class DetailPodcastContract {
  void onLoadEpidoses(List<Episode> episodes);

  onErrorLoadingEpisodes(String err);

  void onPlayerReady();

  void onPlayerStopped();
}

class DetailPodcastPresenter {
  DetailPodcastContract _view;
  CuacRepository _repository;

  DetailPodcastPresenter(this._view, [CuacRepository repository]) {
    _repository = _repository != null ? repository : new CuacRepository();
  }

  loadEpisodes(String feedProgram) async {
    List newsObj = [];
    var xml2json = new Xml2Json();
    var httpClient = createHttpClient();
    try {
      var response = await httpClient.get(feedProgram);
      xml2json.parse(response.body);

      Map news = JSON.decode(xml2json.toGData());

      if (news.containsKey("rss")) {
        newsObj = news["rss"]["channel"]["item"];
        if (newsObj != null) {
          List<Episode> newsList = newsObj
              .map((n) => new Episode.fromInstance(n))
              .toList();
          _view.onLoadEpidoses(newsList);
        } else {
          _view.onErrorLoadingEpisodes("Could not load");
        }
      } else {
        _view.onErrorLoadingEpisodes("Could not load");
      }
    } catch (err) {
      _view.onErrorLoadingEpisodes("Could not load");
    }
  }

  play(String url) async {
    if (Injector.playerState != PlayerState.play) {
      final result = await Injector.player.play(
          url, isLocal: false);
      if (result == 1) Injector.playerState = PlayerState.play;
      _view.onPlayerReady();
    }
  }

  stopAndPlay(String url) async {
    if (Injector.playerState == PlayerState.play ||
        Injector.playerState == PlayerState.pause) {
      final result = await Injector.player.stop();
      if (result == 1) Injector.playerState = PlayerState.stop;
      _view.onPlayerStopped();
      Injector.resetPlayer();
      final playResult = await Injector.player.play(
          url, isLocal: false);
      if (playResult == 1) Injector.playerState = PlayerState.play;
      _view.onPlayerReady();
    }
  }

  stop() async {
    if (Injector.playerState == PlayerState.play ||
        Injector.playerState == PlayerState.pause) {
      final result = await Injector.player.stop();
      if (result == 1) Injector.playerState = PlayerState.stop;
      _view.onPlayerStopped();
      Injector.resetPlayer();
    }
  }

  bool isPlaying() {
    return Injector.playerState == PlayerState.play;
  }

}