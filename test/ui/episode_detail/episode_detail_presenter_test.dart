import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/ui/episode-detail/episode_detail_presenter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../instrument/data/local_repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/model/episode_instrument.dart';
import '../../instrument/ui/mock_episode_detail_view.dart';

void main() {
  MockPlaylistRepository mockPlaylistRepository = MockPlaylistRepository();
  MockEpisodeDetailView view = MockEpisodeDetailView();
  late EpisodeDetailPresenter presenter;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    DependencyInjector().loadModules();
    getTranslations();
    Injector.appInstance.registerDependency<PlaylistRepositoryContract>(
        () => mockPlaylistRepository,
        override: true);
    Injector.appInstance.registerDependency<EpisodeDetailView>(() => view, override: true);
    presenter = Injector.appInstance.get<EpisodeDetailPresenter>();
  });

  setUp(() async {
    presenter = Injector.appInstance.get<EpisodeDetailPresenter>();
  });

  tearDown(() async {
    view.viewState.clear();
    view.data.clear();
  });

  test('that checkPlaylistStatus calls onPlaylistStatusChanged(true) when in playlist', () async {
    when(mockPlaylistRepository.isInPlaylist('http://audio')).thenReturn(true);

    presenter.checkPlaylistStatus('http://audio');
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState[0], equals(EpisodeDetailState.onPlaylistStatusChanged));
    expect(view.data[0] as bool, equals(true));
  });

  test('that checkPlaylistStatus calls onPlaylistStatusChanged(false) when not in playlist', () async {
    when(mockPlaylistRepository.isInPlaylist('http://other')).thenReturn(false);

    presenter.checkPlaylistStatus('http://other');
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState[0], equals(EpisodeDetailState.onPlaylistStatusChanged));
    expect(view.data[0] as bool, equals(false));
  });

  test('that togglePlaylist adds episode when not currently in playlist', () async {
    final episode = EpisodeInstrument.givenAnEpisode();

    presenter.togglePlaylist(episode, 'Spoiler', 'assets/graphics/cuac-logo.png', false);
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState[0], equals(EpisodeDetailState.onPlaylistStatusChanged));
    expect(view.data[0] as bool, equals(true));
  });

  test('that togglePlaylist removes episode when currently in playlist', () async {
    final episode = EpisodeInstrument.givenAnEpisode();

    presenter.togglePlaylist(episode, 'Spoiler', 'assets/graphics/cuac-logo.png', true);
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState[0], equals(EpisodeDetailState.onPlaylistStatusChanged));
    expect(view.data[0] as bool, equals(false));
  });
}
