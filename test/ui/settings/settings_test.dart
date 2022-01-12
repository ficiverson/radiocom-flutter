import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/settings/settings.dart';
import 'package:cuacfm/ui/settings/settings_presenter.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../instrument/data/repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/model/radio_station_instrument.dart';

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
    Injector.appInstance.registerDependency<RadioStation>(
            () => RadioStationInstrument.givenARadioStation(),
        override: true);
  });

  setUp(() async {
    mockPlayer = MockPlayer();
  });

  tearDown(() async {
    Injector.appInstance.removeByKey<SettingsView>();
  });

  testWidgets('that can init the setting screen screen with player', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";

    await tester.pumpWidget(startWidget(Settings()));
    expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 1.0);
    expect(
        find.byKey(PageStorageKey<String>("settings_container"),skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that can init the setting screen screen with player no playing', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";

    await tester.pumpWidget(startWidget(Settings()));
    expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 0.0);
    expect(
        find.byKey(PageStorageKey<String>("settings_container"),skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that in setting screen can handle error on connection while playing', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";
    when(mockPlayer.onConnection).thenReturn((isError){
      tester.allStates.forEach((state){
        if( state is SettingsState){
          state.onConnectionError();
        }
      });
    });

    await tester.pumpWidget(startWidget(Settings()));
    mockPlayer.onConnection!(true);
    await tester.pumpAndSettle();

    expect(
        find.byKey(Key("connection_snackbar"),skipOffstage: true),
        findsOneWidget);
  });
}
