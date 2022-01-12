import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_presenter.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_view.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../instrument/data/repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/model/program_instrument.dart';
import '../../instrument/model/radio_station_instrument.dart';

void main() {
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  MockConnection mockConnection = MockConnection();
  MockPlayer mockPlayer = MockPlayer();

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    DependencyInjector().loadModules();
    mockTranslationsWithLocale();
    Injector.appInstance.registerDependency<CuacRepositoryContract>(
            () => mockRepository,
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
  });

  tearDown(() async {
    Injector.appInstance.removeByKey<DetailPodcastView>();
  });

  testWidgets('that can show podcast detail while playing an audio', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockRepository.getEpisodes(any)).thenAnswer(
            (_) => MockRadiocoRepository.episodes());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";


    await tester.pumpWidget(startWidget(DetailPodcastPage(program: ProgramInstrument.givenAProgram())));
    await tester.pumpAndSettle(Duration(milliseconds: 300));
    expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 1.0);
    expect(
        find.byKey(PageStorageKey<String>("podcasDetailList"),skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that can show podcast detail while not playing an audio', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockRepository.getEpisodes(any)).thenAnswer(
            (_) => MockRadiocoRepository.episodes());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";


    await tester.pumpWidget(startWidget(DetailPodcastPage(program: ProgramInstrument.givenAProgram())));
    expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 0.0);
    expect(
        find.byKey(PageStorageKey<String>("podcasDetailList"),skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that can show podcast detail whithou any episode', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockRepository.getEpisodes(any)).thenAnswer(
            (_) => MockRadiocoRepository.episodes(isEmpty: true));
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";


    await tester.pumpWidget(startWidget(DetailPodcastPage(program: ProgramInstrument.givenAProgram())));
    await tester.pumpAndSettle(Duration(milliseconds: 300));
    expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 1.0);
    expect(
        find.byKey(PageStorageKey<String>("podcasDetailList"),skipOffstage: true),
        findsOneWidget);
    expect(
        find.byKey(PageStorageKey<String>("emptyState"),skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that in detail podcast view can handle no connection while playing music', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockRepository.getEpisodes(any)).thenAnswer(
            (_) => MockRadiocoRepository.episodes(isEmpty: true));
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";
    when(mockPlayer.onConnection).thenReturn((isError){
      tester.allStates.forEach((state){
        if( state is DetailPodcastState){
          state.onConnectionError();
        }
      });
    });

    await tester.pumpWidget(startWidget(DetailPodcastPage(program: ProgramInstrument.givenAProgram())));
    mockPlayer.onConnection!(true);
    await tester.pumpAndSettle();

    expect(
        find.byKey(Key("connection_snackbar"),skipOffstage: true),
        findsOneWidget);
  });

}
