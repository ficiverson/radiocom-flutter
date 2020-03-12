import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/timetable/time_table_router.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:injector/injector.dart';

abstract class TimeTableView {
  onNewData();
  onConnectionError();
}

class TimeTablePresenter {
  TimeTableView view;
  Invoker invoker;
  TimeTableRouterContract router;
  GetLiveProgramUseCase getLiveDataUseCase;
  ConnectionContract connection;
  CurrentPlayerContract currentPlayer;

  TimeTablePresenter(
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
          currentPlayer.currentSong = Now
              .mock()
              .name;
          currentPlayer.currentImage = Now
              .mock()
              .logo_url;
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