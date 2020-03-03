import 'dart:convert';

import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_episodes_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:flutter/cupertino.dart';

import 'detail_podcast_router.dart';

abstract class DetailPodcastView {
  void onLoadEpidoses(List<Episode> episodes);
  onErrorLoadingEpisodes(String err);
}

class DetailPodcastPresenter {
  DetailPodcastView _view;
  Invoker invoker;
  DetailPodcastRouter router;
  GetEpisodesUseCase getEpisodesUseCase;

  DetailPodcastPresenter(this._view, {@required this.invoker, @required this.router, @required this.getEpisodesUseCase});

  loadEpisodes(String feedProgram) async {
    invoker.execute(getEpisodesUseCase.withParams(GetEpisodesUseCaseParams(feedProgram))).listen((result){
        if(result is Success){
          _view.onLoadEpidoses(result.data);
        } else {
          _view.onErrorLoadingEpisodes((result as Error).status.toString());
        }
    });
  }

  onShareClicked(Program podcast){

  }

  onDetailPodcast(String title, String subtitle, String content, String link) {
    router.goToNewDetail(New.fromPodcast(title, subtitle, content, link));
  }

  onDetailEpisode(String title, String subtitle, String content, String link) {
    router.goToNewDetail(New.fromPodcast(title, subtitle, content, link));
  }
}