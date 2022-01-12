import 'dart:async';

import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_all_podcast_use_case.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/domain/usecase/get_news_use_case.dart';
import 'package:cuacfm/domain/usecase/get_outstanding_use_case.dart';
import 'package:cuacfm/domain/usecase/get_station_use_case.dart';
import 'package:cuacfm/domain/usecase/get_timetable_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/outstanding.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/player/current_timer.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void onDarkModeStatus(bool status);

  void onLoadOutstanding(Outstanding outstanding);
  void onLoadOutstandingError(dynamic error);
}

enum StatusPlayer { PLAYING, FAILED, STOP }

class HomePresenter {
  HomeView _homeView;
  Invoker invoker;
  GetAllPodcastUseCase getAllPodcastUseCase;
  GetStationUseCase getStationUseCase;
  GetLiveProgramUseCase getLiveDataUseCase;
  GetTimetableUseCase getTimetableUseCase;
  GetNewsUseCase getNewsUseCase;
  GetOutstandingUseCase getOutstandingUseCase;
  HomeRouterContract router;
  late ConnectionContract connection;
  late CurrentPlayerContract currentPlayer;
  late CurrentTimerContract currentTimer;
  Timer? _timer;
  bool isLoading = false;

  HomePresenter(this._homeView,
      {required this.invoker,
      required this.router,
      required this.getAllPodcastUseCase,
      required this.getStationUseCase,
      required this.getLiveDataUseCase,
      required this.getTimetableUseCase,
      required this.getNewsUseCase,
      required this.getOutstandingUseCase}) {
    currentTimer = Injector.appInstance.get<CurrentTimerContract>();
    connection = Injector.appInstance.get<ConnectionContract>();
    currentPlayer = Injector.appInstance.get<CurrentPlayerContract>();

  }

  init() async {
    _homeView.onDarkModeStatus(await _getDarkModeStatus());
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
      _homeView.onLoadOutstandingError("connectionerror");
    }
  }

  onHomeResumed() async {
    _homeView.onDarkModeStatus(await _getDarkModeStatus());
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
    router.goToSettings((){onHomeResumed();});
  }

  onPodcastClicked(Program podcast) {
    router.goToPodcastDetail(podcast);
  }

  onOutstandingClicked(Outstanding outstanding) {
    if(outstanding.isJoinForm){
      _launchURL(outstanding.description);
    } else {
      New itemNew = New.fromOutstanding(outstanding);
      router.goToNewDetail(itemNew);
    }
  }

  onPodcastControlsClicked(Episode? episode) {
    if(episode != null) {
      router.goToPodcastControls(episode);
    }
  }

  onLiveSelected(Now now) async {
    currentPlayer.isPodcast = false;
    currentPlayer.now = now;
    currentPlayer.currentImage = now.logoUrl;
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
    if(currentPlayer.playerState == AudioPlayerState.stop){
      await currentPlayer.play();
    } else {
      await currentPlayer.resume();
    }
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

  _launchURL(String url, {bool universalLink = true}) async {
    if (await canLaunch(url)) {
      await launch(url, universalLinksOnly: universalLink);
    } else {
      throw 'Could not launch $url';
    }
  }

  _getDarkModeStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result =  prefs.getBool('dark_mode_enabled');
    return result==null? false : result;
  }

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
        _timer?.cancel();
      }
      _timer = new Timer.periodic(new Duration(milliseconds: 100), (timer) {
        if (currentPlayer.isStreamingAudio()) {
          isLoading = false;
          _homeView.onNotifyUser(StatusPlayer.PLAYING);
          _timer?.cancel();
          _timer = null;
        } else if (timer.tick > 300) {
          currentPlayer.stop();
          isLoading = false;
          _homeView.onNotifyUser(StatusPlayer.FAILED);
          _timer?.cancel();
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
        _timer?.cancel();
      }
      _timer = new Timer.periodic(new Duration(milliseconds: 100), (timer) {
        if (currentPlayer.isStreamingAudio()) {
          isLoading = false;
          _homeView.onNotifyUser(StatusPlayer.PLAYING);
          _timer?.cancel();
          _timer = null;
        } else if (timer.tick > 300) {
          currentPlayer.stop();
          isLoading = false;
          _homeView.onNotifyUser(StatusPlayer.FAILED);
          _timer?.cancel();
          _timer = null;
        }
      });
    }
  }

  _stop() {
    currentPlayer.stop();
    _homeView.onNotifyUser(StatusPlayer.STOP);
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
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = result.data;
          currentPlayer.currentSong = result.data.name;
          currentPlayer.currentImage = result.data.logoUrl;
        }
        _homeView.onLoadLiveData(result.data);
      } else {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = Now.mock();
          currentPlayer.currentSong = Now
              .mock()
              .name;
          currentPlayer.currentImage = Now
              .mock()
              .logoUrl;
        }
        _homeView.onLiveDataError((result as Error).status);
      }
      _getRecentPodcast(refreshAll);

    });
  }

  _getOutstanding() {
    invoker.execute(getOutstandingUseCase).listen((result) {
      if (result is Success) {
        _homeView.onLoadOutstanding(result.data);
      } else {
        _homeView.onLoadOutstandingError((result as Error).status);
      }
      _getTimetable();
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
        _getOutstanding();
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
