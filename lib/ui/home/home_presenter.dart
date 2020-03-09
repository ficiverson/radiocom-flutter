import 'dart:async';

import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_all_podcast_use_case.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/domain/usecase/get_news_use_case.dart';
import 'package:cuacfm/domain/usecase/get_station_use_case.dart';
import 'package:cuacfm/domain/usecase/get_timetable_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';

import 'home_router.dart';

abstract class HomeView {
  void onLoadRadioStation(RadioStation station);
  void onRadioStationError(dynamic error);

  void onLoadNews(List<New> news);
  void onNewsError(dynamic error);

  void onLoadLiveData(Now now);
  void onLiveDataError(dynamic error);

  void onLoadPodcasts(List<Program> podcasts);
  void onPodcastError(dynamic error);

  void onLoadTimetable(List<TimeTable> programsTimeTable);
  void onTimetableError(dynamic error);

  void onLoadRecents(List<TimeTable> programsTimeTable);
  void onLoadRecentsError(dynamic error);

  void onConnectionError();
  void onConnectionSuccess();

  void onNotifyUser(StatusPlayer status);
}

enum StatusPlayer { PLAYING, FAILED, STOP }

class HomePresenter {
  Now _liveData;
  HomeView _homeView;
  Invoker invoker;
  GetAllPodcastUseCase getAllPodcastUseCase;
  GetStationUseCase getStationUseCase;
  GetLiveProgramUseCase getLiveDataUseCase;
  GetTimetableUseCase getTimetableUseCase;
  GetNewsUseCase getNewsUseCase;
  HomeRouterContract router;
  ConnectionContract connection;
  CurrentPlayerContract currentPlayer;
  Timer _timer;
  bool isLoading = false;

  HomePresenter(this._homeView,
      {@required this.invoker,
      @required this.router,
      @required this.getAllPodcastUseCase,
      @required this.getStationUseCase,
      @required this.getLiveDataUseCase,
      @required this.getTimetableUseCase,
      @required this.getNewsUseCase}) {
    connection = Injector.appInstance.getDependency<ConnectionContract>();
    currentPlayer = Injector.appInstance.getDependency<CurrentPlayerContract>();
  }

  init() async {
    bool isConnectionAvailable = await connection.isConnectionAvailable();
    if (isConnectionAvailable) {
      _homeView.onConnectionSuccess();
      _getRadioStationData();
      _getLiveProgram(true);
    } else {
      _homeView.onConnectionError();
      _homeView.onLoadRecentsError("connectionerror");
      _homeView.onNewsError("connectionerror");
      _homeView.onPodcastError("connectionerror");
      _homeView.onTimetableError("connectionerror");
    }
  }

  onHomeResumed() async {
    if (await connection.isConnectionAvailable()) {
      _getLiveProgram(false);
    }
  }

  onSeeAllPodcast(List<Program> podcasts) {
    router.goToAllPodcast(podcasts);
  }

  onSeeCategory(List<Program> podcasts, String category) {
    router.goToAllPodcast(podcasts, category: category);
  }

  nowPlayingClicked(List<TimeTable> timeTables) {
    router.goToTimeTable(timeTables);
  }

  onNewClicked(New newItem) {
    router.goToNewDetail(newItem);
  }

  onMenuClicked() {
    router.goToSettings();
  }

  onPodcastClicked(Program podcast) {
    router.goToPodcastDetail(podcast);
  }

  onPodcastControlsClicked(Episode episode) {
    router.goToPodcastControls(episode);
  }

  onLiveSelected(Now now) async {
    currentPlayer.isPodcast = false;
    currentPlayer.now = now;
    currentPlayer.currentImage = now.logo_url;
    currentPlayer.currentSong = now.name;
    if (currentPlayer.isPlaying()) {
      _stopAndPlay();
    } else {
      _play();
    }
    if (await connection.isConnectionAvailable()) {
      _getLiveProgram(false);
    }
  }

  onSelectedEpisode() async {
    await currentPlayer.resume();
    _homeView.onNotifyUser(StatusPlayer.PLAYING);
  }

  onPausePlayer() async {
    if (currentPlayer.isPodcast) {
      await currentPlayer.pause();
      _homeView.onNotifyUser(StatusPlayer.STOP);
    } else {
      _stop();
    }
  }

  //private methods
  _play() async {
    isLoading = true;
    var success = await currentPlayer.play();
    bool isConnectionAvailable = await connection.isConnectionAvailable();
    if (!isConnectionAvailable || !success) {
      currentPlayer.stop();
      isLoading = false;
      _homeView.onNotifyUser(StatusPlayer.FAILED);
    } else {
      if (_timer != null) {
        _timer.cancel();
      }
      _timer = new Timer.periodic(new Duration(milliseconds: 100), (timer) {
        if (currentPlayer.isStreamingAudio()) {
          isLoading = false;
          _homeView.onNotifyUser(StatusPlayer.PLAYING);
          _timer.cancel();
          _timer = null;
        } else if (timer.tick > 300) {
          currentPlayer.stop();
          isLoading = false;
          _homeView.onNotifyUser(StatusPlayer.FAILED);
          _timer.cancel();
          _timer = null;
        }
      });
    }
  }

  _stopAndPlay() async {
    isLoading = true;
    var success = await currentPlayer.stopAndPlay();
    bool isConnectionAvailable = await connection.isConnectionAvailable();
    if (!isConnectionAvailable || !success) {
      currentPlayer.stop();
      isLoading = false;
      _homeView.onNotifyUser(StatusPlayer.FAILED);
    } else {
      if (_timer != null) {
        _timer.cancel();
      }
      _timer = new Timer.periodic(new Duration(milliseconds: 100), (timer) {
        if (currentPlayer.isStreamingAudio()) {
          isLoading = false;
          _homeView.onNotifyUser(StatusPlayer.PLAYING);
          _timer.cancel();
          _timer = null;
        } else if (timer.tick > 300) {
          currentPlayer.stop();
          isLoading = false;
          _homeView.onNotifyUser(StatusPlayer.FAILED);
          _timer.cancel();
          _timer = null;
        }
      });
    }
  }

  _stop() {
    currentPlayer.stop();
    _homeView.onNotifyUser(StatusPlayer.STOP);
  }

  _release() {
    currentPlayer.release();
  }

  _getNews() {
    invoker.execute(getNewsUseCase).listen((result) {
      if (result is Success) {
        _homeView.onLoadNews(result.data);
      } else {
        _homeView.onNewsError((result as Error).status);
      }
    });
  }

  _getRadioStationData() {
    invoker.execute(getStationUseCase).listen((result) {
      if (result is Success) {
        _homeView.onLoadRadioStation(result.data);
      } else {
        _homeView.onRadioStationError((result as Error).status);
      }
    });
  }

  _getLiveProgram(bool refreshAll) {
    invoker.execute(getLiveDataUseCase).listen((result) {
      if (result is Success) {
        _liveData = result.data;
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = result.data;
          currentPlayer.currentSong = result.data.name;
          currentPlayer.currentImage = result.data.logo_url;
        }
        _homeView.onLoadLiveData(result.data);
      } else {
        if (!currentPlayer.isPodcast) {
          _liveData = Now.mock();
          currentPlayer.now = Now.mock();
          currentPlayer.currentSong = Now
              .mock()
              .name;
          currentPlayer.currentImage = Now
              .mock()
              .logo_url;
        }
        _homeView.onLiveDataError((result as Error).status);
      }
      _getRecentPodcast(refreshAll);
    });
  }

  _getTimetable() {
    DateTime nowDate = new DateTime.now();
    var formatter = new DateFormat('dd/MM/yyyy');
    String now = formatter.format(nowDate);
    invoker
        .execute(
        getTimetableUseCase.withParams(GetTimetableUseCaseParams(now, now)))
        .listen((result) {
      if (result is Success) {
        _homeView.onLoadTimetable(result.data);
      } else {
        _homeView.onTimetableError((result as Error).status);
      }
      _getAllPodcasts();
    });
  }

  _getRecentPodcast(bool refreshAll) {
    DateTime nowDate = new DateTime.now();
    var formatter = new DateFormat('dd/MM/yyyy');
    String now = formatter.format(nowDate);
    String yesterday =
    formatter.format(nowDate.toUtc().subtract(new Duration(days: 1)));
    invoker
        .execute(getTimetableUseCase
        .withParams(GetTimetableUseCaseParams(yesterday, now)))
        .listen((result) {
      if (result is Success) {
        _homeView.onLoadRecents(result.data);
      } else {
        _homeView.onLoadRecentsError((result as Error).status);
      }
      if(refreshAll) {
        _getTimetable();
      }
    });
  }

  _getAllPodcasts() {
    invoker
        .execute(getAllPodcastUseCase.withParams(DataPolicy.network))
        .listen((onResult) {
      if (onResult is Success) {
        _homeView.onLoadPodcasts(onResult.data);
      } else {
        _homeView
            .onPodcastError("Imposible recuperar los podcast en este momento");
      }
      _getNews();
    });
  }
}
