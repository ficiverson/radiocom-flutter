import 'package:audioplayers/audioplayers.dart';
import 'package:cuacfm/data/datasource/radioco_remote_datasource.dart';
import 'package:cuacfm/domain/usecase/get_all_podcast_use_case.dart';
import 'package:cuacfm/domain/usecase/get_episodes_use_case.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/domain/usecase/get_news_use_case.dart';
import 'package:cuacfm/domain/usecase/get_outstanding_use_case.dart';
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
import 'package:cuacfm/utils/notification_subscription_contract.dart';
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
          .registerSingleton<BuildContext>(() => view.context, override: true);
      injector.registerDependency<HomeView>(() => view);
    } else if (view is TimetableState) {
      injector.registerDependency<TimeTableView>(() => view);
    } else if (view is AllPodcastState) {
      injector.registerDependency<AllPodcastView>(() => view);
    } else if (view is NewDetailState) {
      injector.registerDependency<NewDetailView>(() => view);
    } else if (view is SettingsState) {
      injector.registerDependency<SettingsView>(() => view);
    } else if (view is SettingsDetailState) {
      injector.registerDependency<SettingsDetailView>(() => view);
    } else if (view is DetailPodcastState) {
      injector.registerDependency<DetailPodcastView>(() => view);
    } else if (view is PodcastControlsState) {
      injector.registerDependency<PodcastControlsView>(() => view);
    }
  }

  loadPlayerModules() {
    injector.registerSingleton<CurrentTimerContract>(() {
      return CurrentTimer();
    });
    injector.registerSingleton<CurrentPlayerContract>(() {
      return CurrentPlayer();
    });
    injector.registerSingleton<AudioPlayer>(() {
      return AudioPlayer();
    });
  }

  loadPresentationModules() {
    injector.registerDependency<ConnectionContract>(() {
      return Connection();
    });

    injector.registerDependency<NotificationSubscriptionContract>(() {
      return NotificationSubscription();
    });

    injector.registerSingleton<RadiocomColorsConract>(() {
      return RadiocomColorsLight();
    });
    injector.registerSingleton<Invoker>(() {
      return Invoker();
    });

    injector.registerDependency<HomeRouterContract>(() {
      return HomeRouter();
    });

    injector.registerDependency<SettingsRouterContract>(() {
      return SettingsRouter();
    });

    injector.registerDependency<AllPodcastRouterContract>(() {
      return AllPodcastRouter();
    });

    injector.registerDependency<DetailPodcastRouterContract>(() {
      return DetailPodcastRouter();
    });

    injector.registerDependency<NewDetailRouterContract>(() {
      return NewDetailRouter();
    });

    injector.registerDependency<SettingsDetailRouterContract>(() {
      return SettingsDetailRouter();
    });

    injector.registerDependency<TimeTableRouterContract>(() {
      return TimeTableRouter();
    });

    injector.registerDependency<HomePresenter>(() {
      return new HomePresenter(injector.get<HomeView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<HomeRouterContract>(),
          getAllPodcastUseCase: injector.get<GetAllPodcastUseCase>(),
          getStationUseCase: injector.get<GetStationUseCase>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>(),
          getTimetableUseCase: injector.get<GetTimetableUseCase>(),
          getNewsUseCase: injector.get<GetNewsUseCase>(),
          getOutstandingUseCase: injector.get<GetOutstandingUseCase>());
    });

    injector.registerDependency<TimeTablePresenter>(() {
      return new TimeTablePresenter(injector.get<TimeTableView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<TimeTableRouterContract>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>());
    });

    injector.registerDependency<AllPodcastPresenter>(() {
      return new AllPodcastPresenter(injector.get<AllPodcastView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<AllPodcastRouterContract>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>());
    });
    injector.registerDependency<NewDetailPresenter>(() {
      return new NewDetailPresenter(
        injector.get<NewDetailView>(),
        router: injector.get<NewDetailRouterContract>(),
        invoker: injector.get<Invoker>(),
        getLiveDataUseCase: injector.get<GetLiveProgramUseCase>(),
      );
    });
    injector.registerDependency<SettingsPresenter>(() {
      return new SettingsPresenter(injector.get<SettingsView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<SettingsRouterContract>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>());
    });
    injector.registerDependency<SettingsDetailPresenter>(() {
      return new SettingsDetailPresenter(injector.get<SettingsDetailView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<SettingsDetailRouterContract>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>());
    });

    injector.registerDependency<DetailPodcastPresenter>(() {
      return new DetailPodcastPresenter(injector.get<DetailPodcastView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<DetailPodcastRouterContract>(),
          getEpisodesUseCase: injector.get<GetEpisodesUseCase>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>());
    });

    injector.registerDependency<PodcastControlsPresenter>(() {
      return new PodcastControlsPresenter(injector.get<PodcastControlsView>(),
          invoker: injector.get<Invoker>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>());
    });
  }

  loadDomainModules() {
    injector.registerSingleton<RadioStation>(() {
      return RadioStation.base();
    });
    injector.registerDependency<GetAllPodcastUseCase>(() {
      var radiocoRepository = injector.get<CuacRepositoryContract>();
      return GetAllPodcastUseCase(radiocoRepository: radiocoRepository);
    });

    injector.registerDependency<GetOutstandingUseCase>(() {
      var radiocoRepository = injector.get<CuacRepositoryContract>();
      return GetOutstandingUseCase(radiocoRepository: radiocoRepository);
    });

    injector.registerDependency<GetStationUseCase>(() {
      var radiocoRepository = injector.get<CuacRepositoryContract>();
      return GetStationUseCase(radiocoRepository: radiocoRepository);
    });

    injector.registerDependency<GetLiveProgramUseCase>(() {
      var radiocoRepository = injector.get<CuacRepositoryContract>();
      return GetLiveProgramUseCase(radiocoRepository: radiocoRepository);
    });

    injector.registerDependency<GetTimetableUseCase>(() {
      var radiocoRepository = injector.get<CuacRepositoryContract>();
      return GetTimetableUseCase(radiocoRepository: radiocoRepository);
    });

    injector.registerDependency<GetNewsUseCase>(() {
      var radiocoRepository = injector.get<CuacRepositoryContract>();
      return GetNewsUseCase(radiocoRepository: radiocoRepository);
    });

    injector.registerDependency<GetEpisodesUseCase>(() {
      var radiocoRepository = injector.get<CuacRepositoryContract>();
      return GetEpisodesUseCase(radiocoRepository: radiocoRepository);
    });
  }

  loadDataModules() {
    injector.registerDependency<CuacRepositoryContract>(() {
      var remoteDataSource = injector.get<RadiocoRemoteDataSourceContract>();
      return CuacRepository(remoteDataSource: remoteDataSource);
    });
  }

  loadRemoteDatasourceModules() {
    injector.registerDependency<CUACClient>(() => CUACClient(), override: true);
    injector.registerDependency<RadiocoAPIContract>(() => RadiocoAPI());
    injector.registerDependency<RadiocoRemoteDataSourceContract>(() {
      return new RadiocoRemoteDataSource();
    });
  }
}
