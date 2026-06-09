import 'package:just_audio/just_audio.dart';
import 'package:cuacfm/data/alerts_repository.dart';
import 'package:cuacfm/data/datasource/alerts_local_datasource_contract.dart';
import 'package:cuacfm/data/datasource/favorites_local_datasource_contract.dart';
import 'package:cuacfm/data/datasource/playlist_local_datasource_contract.dart';
import 'package:cuacfm/data/datasource/radioco_remote_datasource.dart';
import 'package:cuacfm/data/datasource/wrapped_local_datasource_contract.dart';
import 'package:cuacfm/data/favorites_repository.dart';
import 'package:cuacfm/data/playlist_repository.dart';
import 'package:cuacfm/data/wrapped_repository.dart';
import 'package:cuacfm/domain/repository/alerts_repository_contract.dart';
import 'package:cuacfm/domain/repository/favorites_repository_contract.dart';
import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/domain/repository/wrapped_repository_contract.dart';
import 'package:cuacfm/domain/usecase/add_favorite_use_case.dart';
import 'package:cuacfm/domain/usecase/add_to_playlist_start_use_case.dart';
import 'package:cuacfm/domain/usecase/add_to_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/clear_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/end_session_use_case.dart';
import 'package:cuacfm/domain/usecase/get_alerts_unread_count_use_case.dart';
import 'package:cuacfm/domain/usecase/get_alerts_use_case.dart';
import 'package:cuacfm/domain/usecase/get_all_podcast_use_case.dart';
import 'package:cuacfm/domain/usecase/get_episodes_use_case.dart';
import 'package:cuacfm/domain/usecase/get_favorites_use_case.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/domain/usecase/get_news_use_case.dart';
import 'package:cuacfm/domain/usecase/get_outstanding2_use_case.dart';
import 'package:cuacfm/domain/usecase/get_outstanding_use_case.dart';
import 'package:cuacfm/domain/usecase/get_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/get_station_use_case.dart';
import 'package:cuacfm/domain/usecase/get_timetable_use_case.dart';
import 'package:cuacfm/domain/usecase/is_favorite_use_case.dart';
import 'package:cuacfm/domain/usecase/is_in_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/mark_alerts_read_use_case.dart';
import 'package:cuacfm/domain/usecase/remove_favorite_use_case.dart';
import 'package:cuacfm/domain/usecase/remove_from_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/reorder_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/save_alert_use_case.dart';
import 'package:cuacfm/domain/usecase/start_session_use_case.dart';
import 'package:cuacfm/local-data-source/alerts_local_datasource.dart';
import 'package:cuacfm/local-data-source/favorites_local_datasource.dart';
import 'package:cuacfm/local-data-source/playlist_local_datasource.dart';
import 'package:cuacfm/local-data-source/wrapped_local_datasource.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/remote-data-source/network/radioco_api.dart';
import 'package:cuacfm/data/radiocom-repository.dart';
import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/remote-data-source/radioco/radiocom_remote_datasource.dart';
import 'package:cuacfm/ui/alerts/alerts_presenter.dart';
import 'package:cuacfm/ui/episode-detail/episode_detail_presenter.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/ui/home/home_router.dart';
import 'package:cuacfm/ui/home/home_view.dart';
import 'package:cuacfm/ui/new-detail/new_detail.dart';
import 'package:cuacfm/ui/new-detail/new_detail_presenter.dart';
import 'package:cuacfm/ui/new-detail/new_detail_router.dart';
import 'package:cuacfm/ui/onboarding/onboarding_presenter.dart';
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
import 'package:cuacfm/ui/alerts/alerts_router.dart';
import 'package:cuacfm/ui/alerts/alerts_view.dart';
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
    loadLocalDatasourceModules();
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
    } else if (view is EpisodeDetailView) {
      injector.registerDependency<EpisodeDetailView>(() => view, override: true);
    } else if (view is AlertsView) {
      injector.registerDependency<AlertsView>(() => view, override: true);
    }
  }

  loadLocalDatasourceModules() {
    injector.registerSingleton<WrappedLocalDataSourceContract>(() {
      return WrappedLocalDataSource();
    });
    injector.registerDependency<FavoritesLocalDataSourceContract>(() {
      return FavoritesLocalDataSource();
    });
    injector.registerDependency<PlaylistLocalDataSourceContract>(() {
      return PlaylistLocalDataSource();
    });
    injector.registerDependency<AlertsLocalDataSourceContract>(() {
      return AlertsLocalDataSource();
    });
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

    injector.registerDependency<AlertsRouterContract>(() {
      return AlertsRouter();
    });

    injector.registerDependency<TimeTableRouterContract>(() {
      return TimeTableRouter();
    });

    injector.registerDependency<HomePresenter>(() {
      return HomePresenter(injector.get<HomeView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<HomeRouterContract>(),
          getAllPodcastUseCase: injector.get<GetAllPodcastUseCase>(),
          getStationUseCase: injector.get<GetStationUseCase>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>(),
          getTimetableUseCase: injector.get<GetTimetableUseCase>(),
          getNewsUseCase: injector.get<GetNewsUseCase>(),
          getOutstandingUseCase: injector.get<GetOutstandingUseCase>(),
          getOutstanding2UseCase: injector.get<GetOutstanding2UseCase>(),
          getFavoritesUseCase: injector.get<GetFavoritesUseCase>(),
          removeFavoriteUseCase: injector.get<RemoveFavoriteUseCase>());
    });

    injector.registerDependency<TimeTablePresenter>(() {
      return TimeTablePresenter(injector.get<TimeTableView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<TimeTableRouterContract>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>(),
          getTimetableUseCase: injector.get<GetTimetableUseCase>());
    });

    injector.registerDependency<AllPodcastPresenter>(() {
      return AllPodcastPresenter(injector.get<AllPodcastView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<AllPodcastRouterContract>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>());
    });

    injector.registerDependency<NewDetailPresenter>(() {
      return NewDetailPresenter(
        injector.get<NewDetailView>(),
        router: injector.get<NewDetailRouterContract>(),
        invoker: injector.get<Invoker>(),
        getLiveDataUseCase: injector.get<GetLiveProgramUseCase>(),
      );
    });

    injector.registerDependency<SettingsPresenter>(() {
      return SettingsPresenter(injector.get<SettingsView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<SettingsRouterContract>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>(),
          getAlertsUnreadCountUseCase: injector.get<GetAlertsUnreadCountUseCase>());
    });

    injector.registerDependency<SettingsDetailPresenter>(() {
      return SettingsDetailPresenter(injector.get<SettingsDetailView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<SettingsDetailRouterContract>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>());
    });

    injector.registerDependency<DetailPodcastPresenter>(() {
      return DetailPodcastPresenter(injector.get<DetailPodcastView>(),
          invoker: injector.get<Invoker>(),
          router: injector.get<DetailPodcastRouterContract>(),
          getEpisodesUseCase: injector.get<GetEpisodesUseCase>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>());
    });

    injector.registerDependency<PodcastControlsPresenter>(() {
      return PodcastControlsPresenter(injector.get<PodcastControlsView>(),
          invoker: injector.get<Invoker>(),
          getLiveDataUseCase: injector.get<GetLiveProgramUseCase>());
    });

    injector.registerDependency<AlertsPresenter>(() {
      return AlertsPresenter(injector.get<AlertsView>(),
          invoker: injector.get<Invoker>(),
          getAlertsUseCase: injector.get<GetAlertsUseCase>(),
          markAlertsReadUseCase: injector.get<MarkAlertsReadUseCase>());
    });

    injector.registerDependency<EpisodeDetailPresenter>(() {
      return EpisodeDetailPresenter(injector.get<EpisodeDetailView>(),
          invoker: injector.get<Invoker>(),
          isInPlaylistUseCase: injector.get<IsInPlaylistUseCase>(),
          addToPlaylistUseCase: injector.get<AddToPlaylistUseCase>(),
          removeFromPlaylistUseCase: injector.get<RemoveFromPlaylistUseCase>());
    });

    injector.registerDependency<OnboardingPresenter>(() {
      return OnboardingPresenter(
        invoker: injector.get<Invoker>(),
        addFavoriteUseCase: injector.get<AddFavoriteUseCase>(),
        removeFavoriteUseCase: injector.get<RemoveFavoriteUseCase>(),
        addToPlaylistUseCase: injector.get<AddToPlaylistUseCase>(),
        removeFromPlaylistUseCase: injector.get<RemoveFromPlaylistUseCase>(),
      );
    });
  }

  loadDomainModules() {
    injector.registerSingleton<RadioStation>(() {
      return RadioStation.base();
    });

    // Remote use cases
    injector.registerDependency<GetAllPodcastUseCase>(() {
      return GetAllPodcastUseCase(radiocoRepository: injector.get<CuacRepositoryContract>());
    });
    injector.registerDependency<GetOutstandingUseCase>(() {
      return GetOutstandingUseCase(radiocoRepository: injector.get<CuacRepositoryContract>());
    });
    injector.registerDependency<GetOutstanding2UseCase>(() {
      return GetOutstanding2UseCase(radiocoRepository: injector.get<CuacRepositoryContract>());
    });
    injector.registerDependency<GetStationUseCase>(() {
      return GetStationUseCase(radiocoRepository: injector.get<CuacRepositoryContract>());
    });
    injector.registerDependency<GetLiveProgramUseCase>(() {
      return GetLiveProgramUseCase(radiocoRepository: injector.get<CuacRepositoryContract>());
    });
    injector.registerDependency<GetTimetableUseCase>(() {
      return GetTimetableUseCase(radiocoRepository: injector.get<CuacRepositoryContract>());
    });
    injector.registerDependency<GetNewsUseCase>(() {
      return GetNewsUseCase(radiocoRepository: injector.get<CuacRepositoryContract>());
    });
    injector.registerDependency<GetEpisodesUseCase>(() {
      return GetEpisodesUseCase(radiocoRepository: injector.get<CuacRepositoryContract>());
    });

    // Favorites use cases
    injector.registerDependency<GetFavoritesUseCase>(() {
      return GetFavoritesUseCase(repository: injector.get<FavoritesRepositoryContract>());
    });
    injector.registerDependency<AddFavoriteUseCase>(() {
      return AddFavoriteUseCase(repository: injector.get<FavoritesRepositoryContract>());
    });
    injector.registerDependency<RemoveFavoriteUseCase>(() {
      return RemoveFavoriteUseCase(repository: injector.get<FavoritesRepositoryContract>());
    });
    injector.registerDependency<IsFavoriteUseCase>(() {
      return IsFavoriteUseCase(repository: injector.get<FavoritesRepositoryContract>());
    });

    // Playlist use cases
    injector.registerDependency<GetPlaylistUseCase>(() {
      return GetPlaylistUseCase(repository: injector.get<PlaylistRepositoryContract>());
    });
    injector.registerDependency<AddToPlaylistUseCase>(() {
      return AddToPlaylistUseCase(repository: injector.get<PlaylistRepositoryContract>());
    });
    injector.registerDependency<AddToPlaylistStartUseCase>(() {
      return AddToPlaylistStartUseCase(repository: injector.get<PlaylistRepositoryContract>());
    });
    injector.registerDependency<RemoveFromPlaylistUseCase>(() {
      return RemoveFromPlaylistUseCase(repository: injector.get<PlaylistRepositoryContract>());
    });
    injector.registerDependency<IsInPlaylistUseCase>(() {
      return IsInPlaylistUseCase(repository: injector.get<PlaylistRepositoryContract>());
    });
    injector.registerDependency<ClearPlaylistUseCase>(() {
      return ClearPlaylistUseCase(repository: injector.get<PlaylistRepositoryContract>());
    });
    injector.registerDependency<ReorderPlaylistUseCase>(() {
      return ReorderPlaylistUseCase(repository: injector.get<PlaylistRepositoryContract>());
    });

    // Alerts use cases
    injector.registerDependency<GetAlertsUseCase>(() {
      return GetAlertsUseCase(repository: injector.get<AlertsRepositoryContract>());
    });
    injector.registerDependency<MarkAlertsReadUseCase>(() {
      return MarkAlertsReadUseCase(repository: injector.get<AlertsRepositoryContract>());
    });
    injector.registerDependency<GetAlertsUnreadCountUseCase>(() {
      return GetAlertsUnreadCountUseCase(repository: injector.get<AlertsRepositoryContract>());
    });
    injector.registerDependency<SaveAlertUseCase>(() {
      return SaveAlertUseCase(repository: injector.get<AlertsRepositoryContract>());
    });

    // Wrapped use cases
    injector.registerDependency<StartSessionUseCase>(() {
      return StartSessionUseCase(repository: injector.get<WrappedRepositoryContract>());
    });
    injector.registerDependency<EndSessionUseCase>(() {
      return EndSessionUseCase(repository: injector.get<WrappedRepositoryContract>());
    });
  }

  loadDataModules() {
    injector.registerDependency<CuacRepositoryContract>(() {
      return CuacRepository(remoteDataSource: injector.get<RadiocoRemoteDataSourceContract>());
    });

    injector.registerDependency<FavoritesRepositoryContract>(() {
      return FavoritesRepository(
        localDataSource: injector.get<FavoritesLocalDataSourceContract>(),
        wrappedDataSource: injector.get<WrappedLocalDataSourceContract>(),
      );
    });

    injector.registerDependency<PlaylistRepositoryContract>(() {
      return PlaylistRepository(
          localDataSource: injector.get<PlaylistLocalDataSourceContract>());
    });

    injector.registerDependency<AlertsRepositoryContract>(() {
      return AlertsRepository(
          localDataSource: injector.get<AlertsLocalDataSourceContract>());
    });

    injector.registerSingleton<WrappedRepositoryContract>(() {
      return WrappedRepository(
          localDataSource: injector.get<WrappedLocalDataSourceContract>());
    });
  }

  loadRemoteDatasourceModules() {
    injector.registerDependency<CUACClient>(() => CUACClient(), override: true);
    injector.registerDependency<RadiocoAPIContract>(() => RadiocoAPI());
    injector.registerDependency<RadiocoRemoteDataSourceContract>(() {
      return RadiocoRemoteDataSource();
    });
  }
}
