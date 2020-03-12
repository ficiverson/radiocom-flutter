import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:injector/injector.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'new_detail_router.dart';

abstract class NewDetailView {
  onNewData();
  onConnectionError();
}

class NewDetailPresenter {
  NewDetailView view;
  Invoker invoker;
  GetLiveProgramUseCase getLiveDataUseCase;
  ConnectionContract connection;
  CurrentPlayerContract currentPlayer;
  NewDetailRouterContract router;

  NewDetailPresenter(
    this.view, {
    @required this.invoker,
    @required this.router,
    @required this.getLiveDataUseCase,
  }) {
    connection = Injector.appInstance.getDependency<ConnectionContract>();
    currentPlayer = Injector.appInstance.getDependency<CurrentPlayerContract>();
  }

  onViewResumed() async {
    if (await connection.isConnectionAvailable()) {
      getLiveProgram();
    }
  }

  getLiveProgram() {
    invoker.execute(getLiveDataUseCase).listen((result) {
      if (result is Success) {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = result.data;
          currentPlayer.currentSong = result.data.name;
          currentPlayer.currentImage = result.data.logo_url;
          view.onNewData();
        }
      } else {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = Now.mock();
          currentPlayer.currentSong = Now.mock().name;
          currentPlayer.currentImage = Now.mock().logo_url;
          view.onNewData();
        }
      }
    });
  }

  onPodcastControlsClicked(Episode episode) {
    router.goToPodcastControls(episode);
  }

  onResume() async {
    if(currentPlayer.playerState == PlayerState.stop){
      await currentPlayer.play();
    } else {
      await currentPlayer.resume();
    }
  }

  onPause() async {
    await currentPlayer.pause();
  }

  onShareClicked(New item) {
    Share.share(item.title + " via " + item.link);
  }

  onLinkClicked(String url) {
    _launchURL(url);
  }

  _launchURL(String url, {bool universalLink = true}) async {
    if (await canLaunch(url)) {
      await launch(url, universalLinksOnly: universalLink);
    } else {
      throw 'Could not launch $url';
    }
  }
}