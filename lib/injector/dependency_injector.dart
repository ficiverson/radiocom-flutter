import 'package:audioplayers/audioplayers.dart';
import 'package:cuacfm/data/datasource/radioco_remote_datasource.dart';
import 'package:cuacfm/domain/usecase/get_all_podcast_use_case.dart';
import 'package:cuacfm/domain/usecase/get_episodes_use_case.dart';
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
import 'package:cuacfm/ui/new-detail/new_detail_router.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/player/current_timer.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_presenter.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_router.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_view.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls_presenter.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_presenter.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_router.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_view.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail_router.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_presenter_detail.dart';
import 'package:cuacfm/ui/settings/settings.dart';
import 'package:cuacfm/ui/settings/settings_presenter.dart';
import 'package:cuacfm/ui/settings/settings_router.dart';
import 'package:cuacfm/ui/timetable/time_table_presenter.dart';
import 'package:cuacfm/ui/timetable/time_table_router.dart';
import 'package:cuacfm/ui/timetable/time_table_view.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:cuacfm/utils/cuac_client.dart';
import 'package:cuacfm/utils/radiocom_colors.dart';
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
    } else if (view is SettingsState) {
      injector.registerDependency<SettingsView>((Injector injector) => view);
    } else if (view is SettingsDetailState) {
      injector
          .registerDependency<SettingsDetailView>((Injector injector) => view);
    } else if (view is DetailPodcastState) {
      injector
          .registerDependency<DetailPodcastView>((Injector injector) => view);
    } else if (view is PodcastControlsState) {
      injector
          .registerDependency<PodcastControlsView>((Injector injector) => view);
    }
  }

  loadPlayerModules() {
    injector.registerSingleton<CurrentTimerContract>((Injector injector) {
      return CurrentTimer();
    });
    injector.registerSingleton<CurrentPlayerContract>((Injector injector) {
      return CurrentPlayer();
    });
    injector.registerSingleton<AudioPlayer>((Injector injector) {
      AudioPlayer.logEnabled = false;
      return AudioPlayer();
    });
  }

  loadPresentationModules() {
    injector.registerDependency<ConnectionContract>((_) {
      return Connection();
    });

    injector.registerSingleton<RadiocomColorsConract>((Injector injector) {
      return RadiocomColorsLight();
    });
    injector.registerSingleton<Invoker>((Injector injector) {
      return Invoker();
    });

    injector.registerDependency<HomeRouterContract>((Injector injector) {
      return HomeRouter();
    });

    injector.registerDependency<SettingsRouterContract>((Injector injector) {
      return SettingsRouter();
    });

    injector.registerDependency<AllPodcastRouterContract>((Injector injector) {
      return AllPodcastRouter();
    });

    injector
        .registerDependency<DetailPodcastRouterContract>((Injector injector) {
      return DetailPodcastRouter();
    });

    injector.registerDependency<NewDetailRouterContract>((Injector injector) {
      return NewDetailRouter();
    });

    injector
        .registerDependency<SettingsDetailRouterContract>((Injector injector) {
      return SettingsDetailRouter();
    });

    injector.registerDependency<TimeTableRouterContract>((Injector injector) {
      return TimeTableRouter();
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
      return new TimeTablePresenter(injector.getDependency<TimeTableView>(),
          invoker: injector.getDependency<Invoker>(),
          router: injector.getDependency<TimeTableRouterContract>(),
          getLiveDataUseCase: injector.getDependency<GetLiveProgramUseCase>());
    });

    injector.registerDependency<AllPodcastPresenter>((Injector injector) {
      return new AllPodcastPresenter(injector.getDependency<AllPodcastView>(),
          invoker: injector.getDependency<Invoker>(),
          router: injector.getDependency<AllPodcastRouterContract>(),
          getLiveDataUseCase: injector.getDependency<GetLiveProgramUseCase>());
    });
    injector.registerDependency<NewDetailPresenter>((Injector injector) {
      return new NewDetailPresenter(
        injector.getDependency<NewDetailView>(),
        router: injector.getDependency<NewDetailRouterContract>(),
        invoker: injector.getDependency<Invoker>(),
        getLiveDataUseCase: injector.getDependency<GetLiveProgramUseCase>(),
      );
    });
    injector.registerDependency<SettingsPresenter>((Injector injector) {
      return new SettingsPresenter(injector.getDependency<SettingsView>(),
          invoker: injector.getDependency<Invoker>(),
          router: injector.getDependency<SettingsRouterContract>(),
          getLiveDataUseCase: injector.getDependency<GetLiveProgramUseCase>());
    });
    injector.registerDependency<SettingsDetailPresenter>((Injector injector) {
      return new SettingsDetailPresenter(
          injector.getDependency<SettingsDetailView>(),
          invoker: injector.getDependency<Invoker>(),
          router: injector.getDependency<SettingsDetailRouterContract>(),
          getLiveDataUseCase: injector.getDependency<GetLiveProgramUseCase>());
    });

    injector.registerDependency<DetailPodcastPresenter>((Injector injector) {
      return new DetailPodcastPresenter(
          injector.getDependency<DetailPodcastView>(),
          invoker: injector.getDependency<Invoker>(),
          router: injector.getDependency<DetailPodcastRouterContract>(),
          getEpisodesUseCase: injector.getDependency<GetEpisodesUseCase>(),
          getLiveDataUseCase: injector.getDependency<GetLiveProgramUseCase>());
    });

    injector.registerDependency<PodcastControlsPresenter>((Injector injector) {
      return new PodcastControlsPresenter(
          injector.getDependency<PodcastControlsView>(),
          invoker: injector.getDependency<Invoker>(),
          getLiveDataUseCase: injector.getDependency<GetLiveProgramUseCase>());
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

    injector.registerDependency<GetEpisodesUseCase>((Injector injector) {
      var radiocoRepository = injector.getDependency<CuacRepositoryContract>();
      return GetEpisodesUseCase(radiocoRepository: radiocoRepository);
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
