import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls_presenter.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../instrument/data/local_repository_mock.dart';
import '../../instrument/data/repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/ui/mock_podcast_controls_view.dart';

void main() {
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  MockPlaylistRepository mockPlaylistRepository = MockPlaylistRepository();
  MockPodcastControlsView view = MockPodcastControlsView();
  MockConnection mockConnection = MockConnection();
  MockPlayer mockPlayer = MockPlayer();
  late PodcastControlsPresenter presenter;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    DependencyInjector().loadModules();
    getTranslations();
    Injector.appInstance.registerDependency<CuacRepositoryContract>(
        () => mockRepository,
        override: true);
    Injector.appInstance.registerDependency<PlaylistRepositoryContract>(
        () => mockPlaylistRepository,
        override: true);
    Injector.appInstance.registerDependency<PodcastControlsView>(() => view, override: true);
    Injector.appInstance.registerDependency<ConnectionContract>(
        () => mockConnection,
        override: true);
    Injector.appInstance.registerDependency<CurrentPlayerContract>(
        () => mockPlayer,
        override: true);
    when(mockPlayer.getPlaybackRate()).thenReturn(1.0);
    presenter = Injector.appInstance.get<PodcastControlsPresenter>();
  });

  setUp(() async {
    when(mockPlayer.getPlaybackRate()).thenReturn(1.0);
    presenter = Injector.appInstance.get<PodcastControlsPresenter>();
  });

  tearDown(() async {
    view.viewState.clear();
    view.data.clear();
  });

  test('that loadPlaylist populates playlist and calls onLoaded callback', () async {
    when(mockPlaylistRepository.getRawItems())
        .thenReturn(MockPlaylistRepository.playlistItems());

    bool callbackInvoked = false;
    presenter.loadPlaylist(() { callbackInvoked = true; });
    await Future.delayed(Duration(milliseconds: 200));

    expect(callbackInvoked, equals(true));
    expect(presenter.playlist.length, equals(1));
  });

  test('that clearPlaylist clears playlist and calls onDone callback', () async {
    when(mockPlaylistRepository.getRawItems())
        .thenReturn(MockPlaylistRepository.playlistItems());
    // Load first so playlist is populated
    presenter.loadPlaylist(() {});
    await Future.delayed(Duration(milliseconds: 100));

    bool callbackInvoked = false;
    presenter.clearPlaylist(() { callbackInvoked = true; });
    await Future.delayed(Duration(milliseconds: 200));

    expect(callbackInvoked, equals(true));
    expect(presenter.playlist.isEmpty, equals(true));
  });

  test('that removeFromPlaylist removes item and calls onDone callback', () async {
    when(mockPlaylistRepository.getRawItems())
        .thenReturn(MockPlaylistRepository.playlistItems());
    // Load so playlist is populated with one item having audio 'http://audio'
    presenter.loadPlaylist(() {});
    await Future.delayed(Duration(milliseconds: 100));

    bool callbackInvoked = false;
    presenter.removeFromPlaylist('http://audio', () { callbackInvoked = true; });
    await Future.delayed(Duration(milliseconds: 200));

    expect(callbackInvoked, equals(true));
    expect(presenter.playlist.any((m) => m['audio'] == 'http://audio'), equals(false));
  });

  test('that isInPlaylist returns true when item is in cached playlist', () async {
    when(mockPlaylistRepository.getRawItems())
        .thenReturn(MockPlaylistRepository.playlistItems());
    presenter.loadPlaylist(() {});
    await Future.delayed(Duration(milliseconds: 100));

    expect(presenter.isInPlaylist('http://audio'), equals(true));
  });

  test('that isInPlaylist returns false when item is not in cached playlist', () async {
    when(mockPlaylistRepository.getRawItems())
        .thenReturn(MockPlaylistRepository.playlistItems(isEmpty: true));
    presenter.loadPlaylist(() {});
    await Future.delayed(Duration(milliseconds: 100));

    expect(presenter.isInPlaylist('http://audio'), equals(false));
  });
}
