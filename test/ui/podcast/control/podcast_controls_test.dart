import 'dart:io';

import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/player/current_timer.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls_presenter.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Slider, BottomSheet;
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../instrument/data/repository_mock.dart';
import '../../../instrument/helper/helper-instrument.dart';
import '../../../instrument/model/episode_instrument.dart';
import '../../../instrument/model/radio_station_instrument.dart';

void main() {
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  MockConnection mockConnection = MockConnection();
  MockCurrentTimerContract mockCurrentTimerContract =
      MockCurrentTimerContract();
  MockPlayer mockPlayer = MockPlayer();
  late Directory hiveTempDir;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    hiveTempDir = await setupHiveForTest();
    SharedPreferences.setMockInitialValues({});
    DependencyInjector().loadModules();
    mockTranslationsWithLocale();
    Injector.appInstance.registerDependency<CuacRepositoryContract>(
        () => mockRepository,
        override: true);
    Injector.appInstance.registerDependency<CurrentTimerContract>(
        () => mockCurrentTimerContract,
        override: true);
    Injector.appInstance.registerDependency<ConnectionContract>(
        () => mockConnection,
        override: true);
    Injector.appInstance.registerDependency<CurrentPlayerContract>(
        () => mockPlayer,
        override: true);
    Injector.appInstance.registerDependency<RadioStation>(
        () => RadioStationInstrument.givenARadioStation(),
        override: true);
  });

  setUp(() async {
    mockPlayer = MockPlayer();
    when(mockPlayer.getPlaybackRate()).thenReturn(0.0);
  });

  tearDown(() async {
    Injector.appInstance.removeByKey<PodcastControlsView>();
  });

  tearDownAll(() async {
    await teardownHiveForTest(hiveTempDir).timeout(
      const Duration(seconds: 5),
      onTimeout: () {},
    );
  });

  testWidgets('that in podcast controls can show info while playing live audio',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";
    mockCurrentTimerContract.currentTime = 0;

    await tester.pumpWidget(startWidget(
        PodcastControls(episode: EpisodeInstrument.givenAnEpisode())));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text("En directo", skipOffstage: false), findsOneWidget);
  });

  testWidgets(
      'that in podcast controls can show info while playing podcast audio',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = true;
    mockPlayer.currentSong = "mocklive";
    mockPlayer.duration = Duration(seconds: 220);
    mockPlayer.position = Duration(seconds: 110);
    mockPlayer.currentSong = "mocklive";
    mockCurrentTimerContract.currentTime = 0;

    await tester.pumpWidget(startWidget(
        PodcastControls(episode: EpisodeInstrument.givenAnEpisode())));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(Slider, skipOffstage: false), findsOneWidget);

    // Flush the timeout timer scheduled internally by
    // PaletteGenerator.fromImageProvider so it doesn't leak past the test.
    await tester.pump(const Duration(seconds: 16));
  });

  testWidgets('that in podcast controls can put a timer properly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = true;
    mockPlayer.currentSong = "mocklive";
    mockPlayer.duration = Duration(seconds: 220);
    mockPlayer.position = Duration(seconds: 110);
    mockPlayer.currentSong = "mocklive";
    mockCurrentTimerContract.currentTime = 110;

    await tester.pumpWidget(startWidget(
        PodcastControls(episode: EpisodeInstrument.givenAnEpisode())));
    await tester.tap(find.byIcon(Icons.timer));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text("15 min"), findsOneWidget);

    await tester.tap(find.text("15 min"));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('that in podcast controls can put playback rate for faster',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));

    mockPlayer.isPodcast = true;
    mockPlayer.currentSong = "mocklive";
    mockPlayer.duration = Duration(seconds: 220);
    mockPlayer.position = Duration(seconds: 110);
    mockPlayer.currentSong = "mocklive";
    mockCurrentTimerContract.currentTime = 110;
    when(mockPlayer.getPlaybackRate()).thenReturn(1.5);

    await tester.pumpWidget(startWidget(
        PodcastControls(episode: EpisodeInstrument.givenAnEpisode())));
    await tester.tap(find.byIcon(Icons.speed));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(BottomSheet), matching: find.text("1.5x")),
        findsOneWidget);

    await tester.tap(find.descendant(
        of: find.byType(BottomSheet), matching: find.text("1.5x")));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets(
      'that in podcast controls can handle error on connection while playing',
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        when(mockRepository.getLiveBroadcast())
            .thenAnswer((_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(false);
        when(mockPlayer.stop()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = false;
        mockPlayer.currentSong = "mocklive";
        mockCurrentTimerContract.currentTime = 0;

        when(mockPlayer.onConnection).thenReturn((isError) {
          tester.allStates.forEach((state) {
            if (state is PodcastControlsState) {
              state.onConnectionError();
            }
          });
        });

        await tester.pumpWidget(startWidget(
            PodcastControls(episode: EpisodeInstrument.givenAnEpisode())));
        mockPlayer.onConnection!(true);
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.byKey(Key("connection_snackbar"), skipOffstage: true),
            findsOneWidget);
      });
}
