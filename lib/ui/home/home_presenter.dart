import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_all_podcast_use_case.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/domain/usecase/get_news_use_case.dart';
import 'package:cuacfm/domain/usecase/get_station_use_case.dart';
import 'package:cuacfm/domain/usecase/get_timetable_use_case.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/models/time_table.dart';
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
}


class HomePresenter {

  HomeView _homeView;
  Invoker invoker;
  GetAllPodcastUseCase getAllPodcastUseCase;
  GetStationUseCase getStationUseCase;
  GetLiveProgramUseCase getLiveDataUseCase;
  GetTimetableUseCase getTimetableUseCase;
  GetNewsUseCase getNewsUseCase;
  HomeRouterContract router;
  HomePresenter(this._homeView, {@required this.invoker, @required this.router,@required this.getAllPodcastUseCase, @required this.getStationUseCase, @required this.getLiveDataUseCase,
  @required this.getTimetableUseCase, @required this.getNewsUseCase}) {
    getRadioStationData();
  }

  getNews() {
    invoker.execute(getNewsUseCase).listen((result) {
      if (result is Success) {
        _homeView.onLoadNews(result.data);
      } else {
        _homeView.onNewsError((result as Error).status);
      }
    });
  }

  getRadioStationData() {
    invoker.execute(getStationUseCase).listen((result){
      if(result is Success){
        Injector.appInstance.registerSingleton<RadioStation>((_) => result.data, override : true);
        _homeView.onLoadRadioStation(result.data);
      }else {
        _homeView.onRadioStationError((result as Error).status);
      }
      getRecentPodcast();
      getLiveProgram();
    });
  }

  getLiveProgram() {
    invoker.execute(getLiveDataUseCase).listen((result){
      if(result is Success){
        _homeView.onLoadLiveData(result.data);
      }else {
        _homeView.onLiveDataError((result as Error).status);
      }
    });
  }

  getTimetable() {
    DateTime nowDate = new DateTime.now();
    var formatter = new DateFormat('dd/MM/yyyy');
    String now = formatter.format(nowDate);
    invoker.execute(getTimetableUseCase.withParams(GetTimetableUseCaseParams(now, now))).listen((result){
      if(result is Success){
        _homeView.onLoadTimetable(result.data);
      }else {
        _homeView.onTimetableError((result as Error).status);
      }
    });
  }

  getRecentPodcast() {
    DateTime nowDate = new DateTime.now();
    var formatter = new DateFormat('dd/MM/yyyy');
    String now = formatter.format(nowDate);
    String yesterday = formatter.format(
        nowDate.toUtc().subtract(new Duration(days: 1)));
    invoker.execute(getTimetableUseCase.withParams(GetTimetableUseCaseParams(yesterday, now))).listen((result){
      if(result is Success){
        _homeView.onLoadRecents(result.data);
      }else {
        _homeView.onLoadRecentsError((result as Error).status);
      }
      getNews();
      getAllPodcasts();
      getTimetable();
    });
  }

  getAllPodcasts() {
    invoker.execute(getAllPodcastUseCase.withParams(DataPolicy.network)).listen((onResult){
        if(onResult is Success){
          _homeView.onLoadPodcasts(onResult.data);
        } else {
          _homeView.onPodcastError("Imposible recuperar los podcast en este momento");
        }
    });
  }

  onSeeAllPodcast(List<Program> podcasts){
    router.goToAllPodcast(podcasts);
  }

  onSeeCategory(List<Program> podcasts, String category){
    router.goToAllPodcast(podcasts,category: category);
  }

  nowPlayingClicked(List<TimeTable> timeTables){
    router.goToTimeTable(timeTables);
  }

  onNewClicked(New newItem){
    router.goToNewDetail(newItem);
  }


}