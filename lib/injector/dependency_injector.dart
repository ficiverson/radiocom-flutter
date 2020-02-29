import 'package:cuacfm/data/datasource/radioco_remote_datasource.dart';
import 'package:cuacfm/domain/usecase/get_all_podcast_use_case.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/domain/usecase/get_news_use_case.dart';
import 'package:cuacfm/domain/usecase/get_station_use_case.dart';
import 'package:cuacfm/domain/usecase/get_timetable_use_case.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/remote-data-source/network/radioco_api.dart';
import 'package:cuacfm/data/radiocom-repository.dart';
import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/remote-data-source/radioco/radiocom_remote_datasource.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/ui/home/home_router.dart';
import 'package:cuacfm/ui/home/home_view.dart';
import 'package:cuacfm/ui/new-detail/new_detail.dart';
import 'package:cuacfm/ui/new-detail/new_detail_presenter.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_presenter.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_view.dart';
import 'package:cuacfm/ui/timetable/time_table_presenter.dart';
import 'package:cuacfm/ui/timetable/time_table_view.dart';
import 'package:cuacfm/utils/cuac_client.dart';
import 'package:flutter/widgets.dart';
import 'package:injector/injector.dart';

enum Flavor { MOCK, PROD, STAGE }

class DependencyInjector {
  get injector {
    return Injector.appInstance;
  }

  loadModules() {
    loadPlayerModules();
    loadPresentationModules();
    loadDomainModules();
    loadDataModules();
    loadRemoteDatasourceModules();
  }

  injectByView(dynamic view) {
    if (view is MyHomePageState) {
      Injector.appInstance
          .registerSingleton<BuildContext>((_) => view.context, override: true);
      injector.registerDependency<HomeView>((Injector injector) => view);
    } else if (view is TimetableState) {
      injector.registerDependency<TimeTableView>((Injector injector) => view);
    } else if (view is AllPodcastState) {
      injector.registerDependency<AllPodcastView>((Injector injector) => view);
    } else if (view is NewDetailState) {
      injector.registerDependency<NewDetailView>((Injector injector) => view);
    }
  }

  loadPlayerModules() {
//    injector.registerSingleton<CurrentPlayerContract>((Injector injector) {
//      return CurrentPlayer();
//    });
//    injector.registerSingleton<AudioPlayer>((Injector injector) {
//      AudioPlayer.logEnabled = false;
//      return AudioPlayer();
//    });
  }

  loadPresentationModules() {
    injector.registerSingleton<Invoker>((Injector injector) {
      return Invoker();
    });

    injector.registerDependency<HomeRouterContract>((Injector injector) {
      return HomeRouter();
    });

    injector.registerDependency<HomePresenter>((Injector injector) {
      return new HomePresenter(injector.getDependency<HomeView>(),
          invoker: injector.getDependency<Invoker>(),
          router: injector.getDependency<HomeRouterContract>(),
          getAllPodcastUseCase: injector.getDependency<GetAllPodcastUseCase>(),
          getStationUseCase: injector.getDependency<GetStationUseCase>(),
          getLiveDataUseCase: injector.getDependency<GetLiveProgramUseCase>(),
          getTimetableUseCase: injector.getDependency<GetTimetableUseCase>(),
          getNewsUseCase: injector.getDependency<GetNewsUseCase>());
    });

    injector.registerDependency<TimeTablePresenter>((Injector injector) {
      return new TimeTablePresenter();
    });

    injector.registerDependency<AllPodcastPresenter>((Injector injector) {
      return new AllPodcastPresenter();
    });
    injector.registerDependency<NewDetailPresenter>((Injector injector) {
      return new NewDetailPresenter();
    });
  }

  loadDomainModules() {
    injector.registerSingleton<RadioStation>((Injector injector) {
      return RadioStation.base();
    });
    injector.registerDependency<GetAllPodcastUseCase>((Injector injector) {
      var radiocoRepository = injector.getDependency<CuacRepositoryContract>();
      return GetAllPodcastUseCase(radiocoRepository: radiocoRepository);
    });

    injector.registerDependency<GetStationUseCase>((Injector injector) {
      var radiocoRepository = injector.getDependency<CuacRepositoryContract>();
      return GetStationUseCase(radiocoRepository: radiocoRepository);
    });

    injector.registerDependency<GetLiveProgramUseCase>((Injector injector) {
      var radiocoRepository = injector.getDependency<CuacRepositoryContract>();
      return GetLiveProgramUseCase(radiocoRepository: radiocoRepository);
    });

    injector.registerDependency<GetTimetableUseCase>((Injector injector) {
      var radiocoRepository = injector.getDependency<CuacRepositoryContract>();
      return GetTimetableUseCase(radiocoRepository: radiocoRepository);
    });

    injector.registerDependency<GetNewsUseCase>((Injector injector) {
      var radiocoRepository = injector.getDependency<CuacRepositoryContract>();
      return GetNewsUseCase(radiocoRepository: radiocoRepository);
    });
  }

  loadDataModules() {
    injector.registerDependency<CuacRepositoryContract>((Injector injector) {
      var remoteDataSource =
          injector.getDependency<RadiocoRemoteDataSourceContract>();
      return CuacRepository(remoteDataSource: remoteDataSource);
    });
  }

  loadRemoteDatasourceModules() {
    injector.registerDependency<CUACClient>((_) => CUACClient(),
        override: true);
    injector.registerDependency<RadiocoAPIContract>((_) => RadiocoAPI());
    injector.registerDependency<RadiocoRemoteDataSourceContract>(
        (Injector injector) {
      return new RadiocoRemoteDataSource();
    });
  }
}
