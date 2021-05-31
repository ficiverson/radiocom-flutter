import 'dart:ui';

import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/ui/home/home_router.dart';

enum HomeState {
  noConnection,
  onNewData,
  connectionSuccess,
  liveDataError,
  liveDataLoaded,
  loadNews,
  newsError,
  loadPodcast,
  podcastError,
  loadStation,
  stationError,
  loadRecent,
  recenterror,
  loadTimetable,
  timetableError,
  notifyUser,
  onDarkMode,
  goToAllPodcast,
  goToNewDetail,
  goToEpisode,
  goToPodcast,
  goToSettings,
  goToTimeTable
}

class MockHomeView implements HomeView {
  List<HomeState> viewState = [];
  List<dynamic> data = [];

  @override
  onConnectionError() {
    viewState.add(HomeState.noConnection);
  }

  onNewData() {
    viewState.add(HomeState.onNewData);
  }

  @override
  void onConnectionSuccess() {
    viewState.add(HomeState.connectionSuccess);
  }

  @override
  void onLiveDataError(error) {
    viewState.add(HomeState.liveDataError);
    data.add(error);
  }

  @override
  void onLoadLiveData(Now now) {
    viewState.add(HomeState.liveDataLoaded);
    data.add(now);
  }

  @override
  void onLoadNews(List<New> news) {
    viewState.add(HomeState.loadNews);
    data.add(news);
  }

  @override
  void onLoadPodcasts(List<Program> podcasts) {
    viewState.add(HomeState.loadPodcast);
    data.add(podcasts);
  }

  @override
  void onLoadRadioStation(RadioStation station) {
    viewState.add(HomeState.loadStation);
    data.add(station);
  }

  @override
  void onLoadRecents(List<TimeTable> programsTimeTable) {
    viewState.add(HomeState.loadRecent);
    data.add(programsTimeTable);
  }

  @override
  void onLoadRecentsError(error) {
    viewState.add(HomeState.recenterror);
    data.add(error);
  }

  @override
  void onLoadTimetable(List<TimeTable> programsTimeTable) {
    viewState.add(HomeState.loadTimetable);
    data.add(programsTimeTable);
  }

  @override
  void onNewsError(error) {
    viewState.add(HomeState.newsError);
    data.add(error);
  }

  @override
  void onNotifyUser(StatusPlayer status) {
    viewState.add(HomeState.notifyUser);
    data.add(status);
  }

  @override
  void onPodcastError(error) {
    viewState.add(HomeState.podcastError);
    data.add(error);
  }

  @override
  void onRadioStationError(error) {
    viewState.add(HomeState.stationError);
    data.add(error);
  }

  @override
  void onTimetableError(error) {
    viewState.add(HomeState.timetableError);
    data.add(error);
  }

  @override
  void onDarkModeStatus(bool status) {
    viewState.add(HomeState.onDarkMode);
    data.add(status);
  }
}

class MockHomeRouter implements HomeRouterContract {
  List<HomeState> viewState = [];
  List<dynamic> data = [];

  @override
  goToAllPodcast(List<Program> podcasts, {String category}) {
    viewState.add(HomeState.goToAllPodcast);
    data.add(category!=null?category:podcasts);
  }

  @override
  goToNewDetail(New itemNew) {
    viewState.add(HomeState.goToNewDetail);
    data.add(itemNew);
  }

  @override
  goToPodcastControls(Episode episode) {
    viewState.add(HomeState.goToEpisode);
    data.add(episode);
  }

  @override
  goToPodcastDetail(Program podcast) {
    viewState.add(HomeState.goToPodcast);
    data.add(podcast);
  }

  @override
  goToSettings(VoidCallback invokeResult) {
    viewState.add(HomeState.goToSettings);
  }

  @override
  goToTimeTable(List<TimeTable> timeTables) {
    viewState.add(HomeState.goToTimeTable);
    data.add(timeTables);
  }
}
