import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail_router.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:injector/injector.dart';

abstract class SettingsDetailView {
  onNewData();
  onConnectionError();
}

class SettingsDetailPresenter {
  SettingsDetailView view;
  Invoker invoker;
  SettingsDetailRouterContract router;
  GetLiveProgramUseCase getLiveDataUseCase;
  ConnectionContract connection;
  CurrentPlayerContract currentPlayer;

  SettingsDetailPresenter(
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

  onPodcastControlsClicked(Episode episode) {
    router.goToPodcastControls(episode);
  }
}
