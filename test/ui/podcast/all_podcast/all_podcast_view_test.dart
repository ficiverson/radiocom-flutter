import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_presenter.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_view.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../instrument/data/repository_mock.dart';
import '../../../instrument/helper/helper-instrument.dart';
import '../../../instrument/model/program_instrument.dart';
import '../../../instrument/model/radio_station_instrument.dart';

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
            (_) => mockRepository,
        override: true);
    Injector.appInstance.registerDependency<ConnectionContract>(
            (_) => mockConnection,
        override: true);
    Injector.appInstance.registerDependency<CurrentPlayerContract>(
            (_) => mockPlayer,
        override: true);
    Injector.appInstance.registerDependency<RadioStation>(
            (_) => RadioStationInstrument.givenARadioStation(),
        override: true);
  });

  setUp(() async {
    mockPlayer = MockPlayer();
  });

  tearDown(() async {
    Injector.appInstance.removeByKey<AllPodcastView>();
  });

  testWidgets('that in all podcast can show info while playing audio', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);
    when(mockPlayer.currentSong).thenReturn("mocklive");

    await tester.pumpWidget(startWidget(AllPodcast(podcasts: [ProgramInstrument.givenAProgram(),ProgramInstrument.givenAProgram()])));
    expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 1.0);
    expect(
        find.byKey(PageStorageKey<String>("allpodcastview"),skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that in all podcast can show info while not playing podcast audio', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);
    when(mockPlayer.currentSong).thenReturn("mocklive");

    await tester.pumpWidget(startWidget(AllPodcast(podcasts: [ProgramInstrument.givenAProgram(),ProgramInstrument.givenAProgram()])));
    expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 0.0);
    expect(
        find.byKey(PageStorageKey<String>("allpodcastview"),skipOffstage: true),
        findsOneWidget);
  });


  testWidgets('that in all podcast  by category can show info while not playing podcast audio', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);
    when(mockPlayer.currentSong).thenReturn("mocklive");

    await tester.pumpWidget(startWidget(AllPodcast(podcasts: [ProgramInstrument.givenAProgram(),ProgramInstrument.givenAProgram()],category: Program.getCategory(ProgramCategories.TV))));
    expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 0.0);
    expect(
        find.byKey(PageStorageKey<String>("allpodcastview"),skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that in all podcast can show empty state', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);
    when(mockPlayer.currentSong).thenReturn("mocklive");

    await tester.pumpWidget(startWidget(AllPodcast(podcasts: [ProgramInstrument.givenAProgram(),ProgramInstrument.givenAProgram()],category: Program.getCategory(ProgramCategories.SCIENCE))));
    expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 0.0);
    expect(
        find.byKey(PageStorageKey<String>("allpodcastview"),skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that in all podcast can search a podcast', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);
    when(mockPlayer.currentSong).thenReturn("mocklive");

    await tester.pumpWidget(startWidget(AllPodcast(podcasts: [ProgramInstrument.givenAProgram(),ProgramInstrument.givenAProgram()])));
    await tester.tap(find.byKey(Key("top_bar_search")));
    await tester.pump(Duration(milliseconds:400));
    await tester.enterText(find.byKey(Key("top_bar_search_input")),"Spo");
    await tester.pump(Duration(milliseconds:400));

    expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 0.0);
    expect(
        find.byKey(PageStorageKey<String>("allpodcastview"),skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that in podcast controls can handle error on connection while playing', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);
    when(mockPlayer.currentSong).thenReturn("mocklive");
    when(mockPlayer.onConnection).thenReturn((isError){
      tester.allStates.forEach((state){
        if( state is AllPodcastState){
          state.onConnectionError();
        }
      });
    });

    await tester.pumpWidget(startWidget(AllPodcast(podcasts: [ProgramInstrument.givenAProgram(),ProgramInstrument.givenAProgram()])));
    mockPlayer.onConnection(true);
    await tester.pumpAndSettle();

    expect(
        find.byKey(Key("connection_snackbar"),skipOffstage: true),
        findsOneWidget);
  });
}
