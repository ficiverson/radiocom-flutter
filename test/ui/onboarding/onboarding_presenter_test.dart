import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/repository/favorites_repository_contract.dart';
import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/domain/usecase/add_favorite_use_case.dart';
import 'package:cuacfm/domain/usecase/add_to_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/remove_favorite_use_case.dart';
import 'package:cuacfm/domain/usecase/remove_from_playlist_use_case.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/ui/onboarding/onboarding_presenter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../instrument/data/local_repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/model/episode_instrument.dart';
import '../../instrument/model/program_instrument.dart';

void main() {
  MockFavoritesRepository mockFavoritesRepository = MockFavoritesRepository();
  MockPlaylistRepository mockPlaylistRepository = MockPlaylistRepository();
  late OnboardingPresenter presenter;
  Invoker invoker = Invoker();

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    DependencyInjector().loadModules();
    getTranslations();
    Injector.appInstance.registerDependency<FavoritesRepositoryContract>(
        () => mockFavoritesRepository,
        override: true);
    Injector.appInstance.registerDependency<PlaylistRepositoryContract>(
        () => mockPlaylistRepository,
        override: true);
    presenter = OnboardingPresenter(
      invoker: invoker,
      addFavoriteUseCase: Injector.appInstance.get<AddFavoriteUseCase>(),
      removeFavoriteUseCase: Injector.appInstance.get<RemoveFavoriteUseCase>(),
      addToPlaylistUseCase: Injector.appInstance.get<AddToPlaylistUseCase>(),
      removeFromPlaylistUseCase:
          Injector.appInstance.get<RemoveFromPlaylistUseCase>(),
    );
  });

  test('that addFavorite delegates to the add favorite use case', () async {
    final program = ProgramInstrument.givenAProgram().toMap();

    presenter.addFavorite(program);
    await Future.delayed(Duration(milliseconds: 100));

    verify(mockFavoritesRepository.addProgram(program)).called(1);
  });

  test('that removeFavorite delegates to the remove favorite use case',
      () async {
    presenter.removeFavorite('http://rss.url');
    await Future.delayed(Duration(milliseconds: 100));

    verify(mockFavoritesRepository.removeProgram('http://rss.url')).called(1);
  });

  test('that addToPlaylist delegates to the add to playlist use case',
      () async {
    final episode = EpisodeInstrument.givenAnEpisode();

    presenter.addToPlaylist(episode, 'Spoiler', 'http://logo.png');
    await Future.delayed(Duration(milliseconds: 100));

    verify(mockPlaylistRepository.addEpisode(episode, 'Spoiler', 'http://logo.png'))
        .called(1);
  });

  test('that removeFromPlaylist delegates to the remove from playlist use case',
      () async {
    presenter.removeFromPlaylist('http://audio.mp3');
    await Future.delayed(Duration(milliseconds: 100));

    verify(mockPlaylistRepository.removeEpisode('http://audio.mp3')).called(1);
  });
}
