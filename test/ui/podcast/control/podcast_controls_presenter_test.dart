import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/player/current_timer.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls_presenter.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';

import '../../../instrument/data/repository_mock.dart';
import '../../../instrument/helper/helper-instrument.dart';
import '../../../instrument/ui/mock_podcast_controls_view.dart';

void main() {
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  MockPodcastControlsView view = MockPodcastControlsView();
  MockConnection mockConnection = MockConnection();
  MockPlayer mockPlayer = MockPlayer();
  PodcastControlsPresenter presenter;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    DependencyInjector().loadModules();
    Injector.appInstance.registerDependency<CuacRepositoryContract>(
        () => mockRepository,
        override: true);
    Injector.appInstance
        .registerDependency<PodcastControlsView>(() => view, override: true);
    Injector.appInstance.registerDependency<ConnectionContract>(
        () => mockConnection,
        override: true);
    Injector.appInstance.registerDependency<CurrentPlayerContract>(
        () => mockPlayer,
        override: true);
    presenter = Injector.appInstance.get<PodcastControlsPresenter>();
  });

  setUp(() async {
    mockPlayer = MockPlayer();
    presenter = Injector.appInstance.get<PodcastControlsPresenter>();
  });

  tearDown(() async {
    view.viewState.clear();
    view.data.clear();
    presenter = null;
  });

  test('that can init the presenter, then resume the view and realod the data',
      () async {
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

    expect(view.viewState[0], equals(PodcastControlState.setupInitialRate));
  });

  test('that can init the presenter, then resume the view and realod the data with error response reload the view with base now',
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

        expect(view.viewState[0], equals(PodcastControlState.setupInitialRate));
      });

  test(
      'that can init the presenter, then resume the view and connection error then nothing happens in the view',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(false));
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.stop()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPodcast).thenReturn(false);

        presenter.onViewResumed();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState.isEmpty, equals(false));
        expect(view.viewState[0], equals(PodcastControlState.setupInitialRate));
      });

  test(
      'that can init the presenter, then resume the view with a podcast then nothing happens in the view',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPodcast).thenReturn(true);

        presenter.onViewResumed();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState.isEmpty, equals(false));
        expect(view.viewState[0], equals(PodcastControlState.setupInitialRate));

      });

  test(
      'that can seek the player and update the ui when it is a podcast',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPodcast).thenReturn(true);
        when(mockPlayer.position).thenReturn(Duration(seconds: 10));

        presenter.onSeek(200);
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(PodcastControlState.setupInitialRate));
        expect(view.viewState[1], equals(PodcastControlState.onNewData));
      });

  test(
      'that cannot seek the player and update the ui when it is not a podcast',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPodcast).thenReturn(false);
        when(mockPlayer.position).thenReturn(Duration(seconds: 10));

        presenter.onSeek(200);
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState.isEmpty, equals(false));
        expect(view.viewState[0], equals(PodcastControlState.setupInitialRate));
      });


  test(
      'that can resume if the audio is paused and update the view',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(false);
        when(mockPlayer.playerState).thenReturn(AudioPlayerState.stop);

        presenter.onPlayPause();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(PodcastControlState.setupInitialRate));
        expect(view.viewState[1], equals(PodcastControlState.onNewData));
      });

  test(
      'that can play if the audio is paused and update the view',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(false);

        presenter.onPlayPause();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(PodcastControlState.setupInitialRate));
        expect(view.viewState[1], equals(PodcastControlState.onNewData));
      });

  test(
      'that can pause if the audio is playing and update the view',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(true);

        presenter.onPlayPause();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(PodcastControlState.setupInitialRate));
        expect(view.viewState[1], equals(PodcastControlState.onNewData));
      });

  test(
      'that can set a timer when its not index to put to 0',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(true);

        presenter.onTimerStart(Duration(milliseconds: 200),1);

        CurrentTimerContract timer = Injector.appInstance.get<CurrentTimerContract>();
        expect(timer.isTimerRunning(), true);
      });

  test(
      'that can set a timer when its index  0',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(true);

        presenter.onTimerStart(Duration(milliseconds: 200),0);

        CurrentTimerContract timer = Injector.appInstance.get<CurrentTimerContract>();
        expect(timer.isTimerRunning(), false);
      });

  test(
      'that can set a timer when its not running',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(true);

        presenter.onTimerStart(Duration.zero,1);
        await Future.delayed(Duration(milliseconds: 200));

        CurrentTimerContract timer = Injector.appInstance.get<CurrentTimerContract>();
        expect(timer.isTimerRunning(), false);
      });

  test(
      'that can set speed in the player',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.getPlaybackRate()).thenReturn(2.5);
        when(mockPlayer.setPlaybackRate(any)).thenReturn({
          2.5
        });

        presenter.onSpeedSelected(2.5);

        expect(view.viewState[0], equals(PodcastControlState.setupInitialRate));
      });


}
