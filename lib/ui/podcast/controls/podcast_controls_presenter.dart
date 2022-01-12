import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/player/current_timer.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:injector/injector.dart';
import 'package:share/share.dart';

abstract class PodcastControlsView {
  onNewData();
  setupInitialRate(int index);
}

class PodcastControlsPresenter {
  PodcastControlsView _view;
  Invoker invoker;
  late CurrentTimerContract currentTimer;
  late CurrentPlayerContract currentPlayer;
  late ConnectionContract connection;
  GetLiveProgramUseCase getLiveDataUseCase;

  PodcastControlsPresenter(this._view,
      {required this.invoker, required this.getLiveDataUseCase}) {
    currentTimer = Injector.appInstance.get<CurrentTimerContract>();
    connection = Injector.appInstance.get<ConnectionContract>();
    currentPlayer = Injector.appInstance.get<CurrentPlayerContract>();
    _view.setupInitialRate(_getRateIndex(currentPlayer.getPlaybackRate()));
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

  onSpeedSelected(double speed) {
    if (currentPlayer.isPlaying()) {
      currentPlayer.setPlaybackRate(speed);
    }
  }

  getLiveProgram() {
    invoker.execute(getLiveDataUseCase).listen((result) {
      if (result is Success) {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = result.data;
          currentPlayer.currentSong = result.data.name;
          currentPlayer.currentImage = result.data.logoUrl;
          _view.onNewData();
        }
      } else {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = Now.mock();
          currentPlayer.currentSong = Now.mock().name;
          currentPlayer.currentImage = Now.mock().logoUrl;
          _view.onNewData();
        }
      }
    });
  }

  onShareClicked() {
    String link = "https://cuacfm.org";
    if (currentPlayer.isPodcast) {
      link = currentPlayer.episode?.link ?? "https://cuacfm.org";
    }
    Share.share(currentPlayer.currentSong + " via " + link);
  }

  onPlayPause() async {
    if (currentPlayer.isPlaying()) {
      await currentPlayer.pause();
    } else if(currentPlayer.playerState == AudioPlayerState.stop) {
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

  int _getRateIndex(double speed){
    int index = 1;
    if(speed == 0.8){
      index = 0;
    } else if(speed ==1.0) {
      index = 1;
    } else if(speed == 1.2){
      index = 2;
    } else if(speed ==1.5){
      index = 3;
    } else if(speed ==2.0){
      index = 4;
    }
    return index;
  }
}
