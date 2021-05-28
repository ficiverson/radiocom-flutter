import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/ui/home/home_view.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/utils/bottom_bar.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../instrument/data/repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';

void main() {
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  MockConnection mockConnection = MockConnection();
  MockPlayer mockPlayer = MockPlayer();

  setupCloudFirestoreMocks();

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Firebase.initializeApp();
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
  });

  setUp(() async {
    mockPlayer = MockPlayer();
  });

  tearDown(() async {
    Injector.appInstance.removeByKey<HomeView>();
  });

  testWidgets('that can init the home screen', (WidgetTester tester) async{
        when(mockRepository.getLiveBroadcast())
            .thenAnswer((_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockRepository.getEpisodes(any)).thenAnswer((_) => MockRadiocoRepository.episodes());
        when(mockRepository.getAllPodcasts()).thenAnswer((_) => MockRadiocoRepository.podcasts());
        when(mockRepository.getRadioStationData()).thenAnswer((_) => MockRadiocoRepository.radioStation());
        when(mockRepository.getNews()).thenAnswer((_) => MockRadiocoRepository.news());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.stop()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPodcast).thenReturn(false);
        when(mockPlayer.currentSong).thenReturn("mocklive");

        await tester.pumpWidget(startWidget(MyHomePage()));
        expect(
            find.byKey(Key("bottom_bar"),skipOffstage: true),
            findsOneWidget);
        expect(
            find.byKey(PageStorageKey<String>(BottomBarOption.HOME.toString()),skipOffstage: true),
            findsOneWidget);
        expect(
            find.byKey(Key("welcome_message_home"),skipOffstage: true),
            findsOneWidget);
  });

  testWidgets('that can list the podcasts', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
    when(mockRepository.getEpisodes(any)).thenAnswer((_) => MockRadiocoRepository.episodes());
    when(mockRepository.getAllPodcasts()).thenAnswer((_) => MockRadiocoRepository.podcasts());
    when(mockRepository.getRadioStationData()).thenAnswer((_) => MockRadiocoRepository.radioStation());
    when(mockRepository.getNews()).thenAnswer((_) => MockRadiocoRepository.news());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);
    when(mockPlayer.currentSong).thenReturn("mocklive");

    await tester.pumpWidget(startWidget(MyHomePage()));
    await tester.tap(find.byKey(Key("bottom_bar_item2")));
    await tester.pump();
    expect(
        find.byKey(Key("bottom_bar"),skipOffstage: true),
        findsOneWidget);
    expect(
        find.byKey(PageStorageKey<String>(BottomBarOption.SEARCH.toString()),skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that can list the news', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
    when(mockRepository.getEpisodes(any)).thenAnswer((_) => MockRadiocoRepository.episodes());
    when(mockRepository.getAllPodcasts()).thenAnswer((_) => MockRadiocoRepository.podcasts());
    when(mockRepository.getRadioStationData()).thenAnswer((_) => MockRadiocoRepository.radioStation());
    when(mockRepository.getNews()).thenAnswer((_) => MockRadiocoRepository.news());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);
    when(mockPlayer.currentSong).thenReturn("mocklive");

    await tester.pumpWidget(startWidget(MyHomePage()));
    await tester.tap(find.byKey(Key("bottom_bar_item3")));
    await tester.pump();
    expect(
        find.byKey(Key("bottom_bar"),skipOffstage: true),
        findsOneWidget);
    expect(
        find.byKey(PageStorageKey<String>(BottomBarOption.NEWS.toString()),skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that in home screen can handle error on connection while playing', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
    when(mockRepository.getEpisodes(any)).thenAnswer((_) => MockRadiocoRepository.episodes());
    when(mockRepository.getAllPodcasts()).thenAnswer((_) => MockRadiocoRepository.podcasts());
    when(mockRepository.getRadioStationData()).thenAnswer((_) => MockRadiocoRepository.radioStation());
    when(mockRepository.getNews()).thenAnswer((_) => MockRadiocoRepository.news());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);
    when(mockPlayer.currentSong).thenReturn("mocklive");
    when(mockPlayer.onConnection).thenReturn((isError){
      tester.allStates.forEach((state){
        if( state is MyHomePageState){
          state.onConnectionError();
        }
      });
    });

    await tester.pumpWidget(startWidget(MyHomePage()));
    mockPlayer.onConnection(true);
    await tester.pumpAndSettle();

    expect(
        find.byKey(Key("connection_snackbar"),skipOffstage: true),
        findsOneWidget);
  });
}
