import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/player/current_timer.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:injector/injector.dart';
import 'package:share/share.dart';

abstract class PodcastControlsView {
  onNewData();
}

class PodcastControlsPresenter {
  PodcastControlsView _view;
  Invoker invoker;
  CurrentTimerContract currentTimer;
  CurrentPlayerContract currentPlayer;
  ConnectionContract connection;
  GetLiveProgramUseCase getLiveDataUseCase;

  PodcastControlsPresenter(this._view,
      {@required this.invoker, @required this.getLiveDataUseCase}) {
    currentTimer = Injector.appInstance.getDependency<CurrentTimerContract>();
    connection = Injector.appInstance.getDependency<ConnectionContract>();
    currentPlayer = Injector.appInstance.getDependency<CurrentPlayerContract>();
  }

  onViewResumed() async {
    if (await connection.isConnectionAvailable()) {
      getLiveProgram();
    }
  }

  onTimerStart(Duration minutes, int index) {
    if (currentPlayer.isPlaying()) {
      if (currentTimer.isTimerRunning()) {
        currentTimer.stopTimer();
      }
      currentTimer.currentTime = index;
      currentTimer.startTimer(minutes);
    }
  }

  getLiveProgram() {
    invoker.execute(getLiveDataUseCase).listen((result) {
      if (result is Success) {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = result.data;
          currentPlayer.currentSong = result.data.name;
          currentPlayer.currentImage = result.data.logo_url;
          _view.onNewData();
        }
      } else {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = Now.mock();
          currentPlayer.currentSong = Now.mock().name;
          currentPlayer.currentImage = Now.mock().logo_url;
          _view.onNewData();
        }
      }
    });
  }

  onShareClicked() {
    String link = "https://cuacfm.org";
    if (currentPlayer.isPodcast) {
      link = currentPlayer.episode.link;
    }
    Share.share(currentPlayer.currentSong + " via " + link);
  }

  onPlayPause() async {
    if (currentPlayer.isPlaying()) {
      await currentPlayer.pause();
    } else if(currentPlayer.playerState == PlayerState.stop) {
      await currentPlayer.play();
    } else {
      await currentPlayer.resume();
    }
    _view.onNewData();
  }

  onSeek(int timeSeek) async {
    if (currentPlayer.isPodcast) {
      await currentPlayer
          .seek(Duration(seconds: currentPlayer.position.inSeconds + timeSeek));
      _view.onNewData();
    }
  }
}
