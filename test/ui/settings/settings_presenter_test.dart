import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail.dart';
import 'package:cuacfm/ui/settings/settings_presenter.dart';
import 'package:cuacfm/ui/settings/settings_router.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../instrument/data/repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/model/episode_instrument.dart';
import '../../instrument/ui/mock_settings_view.dart';

void main() {
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  MockSettingsView view = MockSettingsView();
  MockSettingsRouter router = MockSettingsRouter();
  MockConnection mockConnection = MockConnection();
  MockPlayer mockPlayer = MockPlayer();
  SettingsPresenter presenter;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    DependencyInjector().loadModules();
    Injector.appInstance.registerDependency<CuacRepositoryContract>(
        (_) => mockRepository,
        override: true);
    Injector.appInstance
        .registerDependency<SettingsView>((_) => view, override: true);
    Injector.appInstance.registerDependency<SettingsRouterContract>(
        (_) => router,
        override: true);
    Injector.appInstance.registerDependency<ConnectionContract>(
        (_) => mockConnection,
        override: true);
    Injector.appInstance.registerDependency<CurrentPlayerContract>(
        (_) => mockPlayer,
        override: true);
    presenter = Injector.appInstance.getDependency<SettingsPresenter>();
  });

  setUp(() async {
    mockPlayer = MockPlayer();
    presenter = Injector.appInstance.getDependency<SettingsPresenter>();
  });

  tearDown(() async {
    view.viewState.clear();
    view.data.clear();
    router.viewState.clear();
    router.data.clear();
    presenter = null;
  });

  test('that can init the presenter', () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);

    presenter.onViewResumed();
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState[0], equals(SettingsState.onNewData));
  });

  test('that can init the presenter then show dark mode state', () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);

    presenter.init();
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState[0], equals(SettingsState.onDarkMode));
    expect(view.viewState[1], equals(SettingsState.onLiveNotification));
  });

  test(
      'that can init the presenter, then resume the view and realod the data with error response reload the view with base now',
      () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now(isEmpty: true));
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);

    presenter.onViewResumed();
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState[0], equals(SettingsState.onNewData));
  });

  test(
      'that can init the presenter, then resume the view and connection error then nothing happens in the view',
      () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(false));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);

    presenter.onViewResumed();
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState.isEmpty, equals(true));
  });

  test(
      'that can init the presenter, then resume the view with a podcast then nothing happens in the view',
      () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(true);

    presenter.onViewResumed();
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState.isEmpty, equals(true));
  });

  test('that can navigate to podcast controls', () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(true);

    presenter.onPodcastControlsClicked(EpisodeInstrument.givenAnEpisode());
    await Future.delayed(Duration(milliseconds: 200));

    expect(router.viewState[0], equals(SettingsState.goToEpisode));
    expect((router.data[0] as Episode).title,
        equals(EpisodeInstrument.givenAnEpisode().title));
  });

  test('that can navigate to history', () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(true);

    presenter.onHistoryClicked("my content");
    await Future.delayed(Duration(milliseconds: 200));

    expect(router.viewState[0], equals(SettingsState.goToHistory));
    expect((router.data[0] as New).description, equals("my content"));
  });

  test('that can navigate to gallery', () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(true);

    presenter.onGalleryClicked();
    await Future.delayed(Duration(milliseconds: 200));

    expect(router.viewState[0], equals(SettingsState.goToLegal));
    expect((router.data[0] as LegalType), equals(LegalType.NONE));
  });

  test('that can navigate to terms', () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(true);

    presenter.onTermsClicked();
    await Future.delayed(Duration(milliseconds: 200));

    expect(router.viewState[0], equals(SettingsState.goToLegal));
    expect((router.data[0] as LegalType), equals(LegalType.TERMS));
  });

  test('that can navigate to privacy', () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(true);

    presenter.onPrivacyClicked();
    await Future.delayed(Duration(milliseconds: 200));

    expect(router.viewState[0], equals(SettingsState.goToLegal));
    expect((router.data[0] as LegalType), equals(LegalType.PRIVACY));
  });

  test('that can navigate to license', () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(true);

    presenter.onSoftwareLicenseClicked();
    await Future.delayed(Duration(milliseconds: 200));

    expect(router.viewState[0], equals(SettingsState.goToLegal));
    expect((router.data[0] as LegalType), equals(LegalType.LICENSE));
  });
}
