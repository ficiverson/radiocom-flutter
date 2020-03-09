import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/ui/home/home_router.dart';
import 'package:cuacfm/ui/new-detail/new_detail_presenter.dart';
import 'package:cuacfm/ui/new-detail/new_detail_router.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_presenter.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_router.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail_router.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_presenter_detail.dart';

enum HomeState {
  noConnection,
  onNewData,
  connectionSuccess,
  liveDataError,
  liveDataLoaded
}

class MockHomelView implements HomeView {
  List<HomeState> viewState = List();
  List<dynamic> data = List();

  @override
  onConnectionError() {
    viewState.add(HomeState.noConnection);
  }

  @override
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
    // TODO: implement onLoadLiveData
  }

  @override
  void onLoadNews(List<New> news) {
    // TODO: implement onLoadNews
  }

  @override
  void onLoadPodcasts(List<Program> podcasts) {
    // TODO: implement onLoadPodcasts
  }

  @override
  void onLoadRadioStation(RadioStation station) {
    // TODO: implement onLoadRadioStation
  }

  @override
  void onLoadRecents(List<TimeTable> programsTimeTable) {
    // TODO: implement onLoadRecents
  }

  @override
  void onLoadRecentsError(error) {
    // TODO: implement onLoadRecentsError
  }

  @override
  void onLoadTimetable(List<TimeTable> programsTimeTable) {
    // TODO: implement onLoadTimetable
  }

  @override
  void onNewsError(error) {
    // TODO: implement onNewsError
  }

  @override
  void onNotifyUser(StatusPlayer status) {
    // TODO: implement onNotifyUser
  }

  @override
  void onPodcastError(error) {
    // TODO: implement onPodcastError
  }

  @override
  void onRadioStationError(error) {
    // TODO: implement onRadioStationError
  }

  @override
  void onTimetableError(error) {
    // TODO: implement onTimetableError
  }
}

class MockHomeRouter implements HomeRouterContract {
  List<HomeState> viewState = List();
  List<dynamic> data = List();

  @override
  goToAllPodcast(List<Program> podcasts, {String category}) {
    // TODO: implement goToAllPodcast
    return null;
  }

  @override
  goToNewDetail(New itemNew) {
    // TODO: implement goToNewDetail
    return null;
  }

  @override
  goToPodcastControls(Episode episode) {
    // TODO: implement goToPodcastControls
    return null;
  }

  @override
  goToPodcastDetail(Program podcast) {
    // TODO: implement goToPodcastDetail
    return null;
  }

  @override
  goToSettings() {
    // TODO: implement goToSettings
    return null;
  }

  @override
  goToTimeTable(List<TimeTable> timeTables) {
    // TODO: implement goToTimeTable
    return null;
  }

}