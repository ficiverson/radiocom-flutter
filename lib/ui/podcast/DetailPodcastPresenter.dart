import 'dart:convert';

import 'package:audioplayer/audioplayer.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/repository/CuacRepository.dart';
import 'package:cuacfm/ui/home/homePresenter.dart';
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
  AudioPlayer audioPlayer;
  var _playerState;

  DetailPodcastPresenter(this._view, [CuacRepository repository]) {
    audioPlayer = new AudioPlayer();
    _repository = _repository != null ? repository : new CuacRepository();
  }

  loadEpisodes(String feedProgram) async {
    List newsObj = [];
    var xml2json = new Xml2Json();
    var httpClient = createHttpClient();

    var response = await httpClient.get(feedProgram);
    xml2json.parse(response.body);

    Map news = JSON.decode(xml2json.toGData());

    if (news.containsKey("rss")) {
      newsObj = news["rss"]["channel"]["item"];
      if(newsObj != null) {
        List<Episode> newsList = newsObj
            .map((n) => new Episode.fromInstance(n))
            .toList();
        _view.onLoadEpidoses(newsList);
      }
    }
  }
  play(String url) async {
    if (_playerState != PlayerState.play) {
      final result = await audioPlayer.play(
          url, isLocal: false);
      if (result == 1) _playerState = PlayerState.play;
      _view.onPlayerReady();
    } else {
      final result = await audioPlayer.stop();
      if (result == 1) _playerState = PlayerState.stop;
      _view.onPlayerStopped();
    }
  }

}