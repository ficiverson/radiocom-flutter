import 'package:cuacfm/domain/repository/favorites_repository_contract.dart';
import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_presenter.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_router.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../instrument/data/local_repository_mock.dart';
import '../../instrument/data/repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/model/episode_instrument.dart';
import '../../instrument/ui/mock_podcast_detail_view.dart';

void main() {
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  MockFavoritesRepository mockFavoritesRepository = MockFavoritesRepository();
  MockPlaylistRepository mockPlaylistRepository = MockPlaylistRepository();
  MockPodcastDetailView view = MockPodcastDetailView();
  MockPodcastDetailRouter router = MockPodcastDetailRouter();
  MockConnection mockConnection = MockConnection();
  MockPlayer mockPlayer = MockPlayer();
  late DetailPodcastPresenter presenter;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    DependencyInjector().loadModules();
    getTranslations();
    Injector.appInstance.registerDependency<CuacRepositoryContract>(
        () => mockRepository,
        override: true);
    Injector.appInstance.registerDependency<FavoritesRepositoryContract>(
        () => mockFavoritesRepository,
        override: true);
    Injector.appInstance.registerDependency<PlaylistRepositoryContract>(
        () => mockPlaylistRepository,
        override: true);
    Injector.appInstance.registerDependency<DetailPodcastView>(() => view, override: true);
    Injector.appInstance.registerDependency<DetailPodcastRouterContract>(() => router, override: true);
    Injector.appInstance.registerDependency<ConnectionContract>(
        () => mockConnection,
        override: true);
    Injector.appInstance.registerDependency<CurrentPlayerContract>(
        () => mockPlayer,
        override: true);
    presenter = Injector.appInstance.get<DetailPodcastPresenter>();
  });

  setUp(() async {
    mockPlayer = MockPlayer();
    presenter = Injector.appInstance.get<DetailPodcastPresenter>();
  });

  tearDown(() async {
    view.viewState.clear();
    view.data.clear();
    router.viewState.clear();
    router.data.clear();
  });

  test('that checkIsFavorite calls callback with true when program is a favorite', () async {
    when(mockFavoritesRepository.isFavorite('http://feed')).thenReturn(true);

    bool? callbackResult;
    presenter.checkIsFavorite('http://feed', (isFav) { callbackResult = isFav; });
    await Future.delayed(Duration(milliseconds: 200));

    expect(callbackResult, equals(true));
  });

  test('that checkIsFavorite calls callback with false when program is not a favorite', () async {
    when(mockFavoritesRepository.isFavorite('http://other')).thenReturn(false);

    bool? callbackResult;
    presenter.checkIsFavorite('http://other', (isFav) { callbackResult = isFav; });
    await Future.delayed(Duration(milliseconds: 200));

    expect(callbackResult, equals(false));
  });

  test('that addToPlaylistIfNew calls callback(false) when episode is already in playlist', () async {
    final episode = EpisodeInstrument.givenAnEpisode();
    when(mockPlaylistRepository.isInPlaylist(episode.audio)).thenReturn(true);

    bool? callbackResult;
    presenter.addToPlaylistIfNew(episode, 'Spoiler', 'assets/graphics/cuac-logo.png', (added) {
      callbackResult = added;
    });
    await Future.delayed(Duration(milliseconds: 200));

    expect(callbackResult, equals(false));
  });

  test('that addToPlaylistIfNew calls callback(true) when episode is not in playlist and adds it', () async {
    final episode = EpisodeInstrument.givenAnEpisode();
    when(mockPlaylistRepository.isInPlaylist(episode.audio)).thenReturn(false);

    bool? callbackResult;
    presenter.addToPlaylistIfNew(episode, 'Spoiler', 'assets/graphics/cuac-logo.png', (added) {
      callbackResult = added;
    });
    await Future.delayed(Duration(milliseconds: 200));

    expect(callbackResult, equals(true));
    verify(mockPlaylistRepository.addEpisode(episode, 'Spoiler', 'assets/graphics/cuac-logo.png')).called(1);
  });
}
