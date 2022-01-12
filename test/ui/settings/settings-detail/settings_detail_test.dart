import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_presenter_detail.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../instrument/data/repository_mock.dart';
import '../../../instrument/helper/helper-instrument.dart';
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
    Injector.appInstance.removeByKey<SettingsDetailView>();
  });

  testWidgets(
      'that can init the setting detail screen screen with player playing in terms and conditions',
      (WidgetTester tester) async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";

    await tester
        .pumpWidget(startWidget(SettingsDetail(legalType: LegalType.TERMS)));
    expect(
        tester
            .widget<Opacity>(find.byKey(Key("player_view_container")))
            .opacity,
        1.0);
    expect(find.byKey(ValueKey<String>("termsprivacynote"), skipOffstage: true),
        findsOneWidget);
  });

  testWidgets(
      'that can init the setting detail screen screen with player no playing in terms and conditions',
      (WidgetTester tester) async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";

    await tester
        .pumpWidget(startWidget(SettingsDetail(legalType: LegalType.TERMS)));
    expect(
        tester
            .widget<Opacity>(find.byKey(Key("player_view_container")))
            .opacity,
        0.0);
    expect(find.byKey(ValueKey<String>("termsprivacynote"), skipOffstage: true),
        findsOneWidget);
  });

  testWidgets(
      'that can init the setting detail screen screen with player playing in privacy',
      (WidgetTester tester) async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";

    await tester
        .pumpWidget(startWidget(SettingsDetail(legalType: LegalType.PRIVACY)));
    expect(
        tester
            .widget<Opacity>(find.byKey(Key("player_view_container")))
            .opacity,
        1.0);
    expect(find.byKey(ValueKey<String>("termsprivacynote"), skipOffstage: true),
        findsOneWidget);
  });

  testWidgets(
      'that can init the setting detail screen screen with player no playing in privacy',
      (WidgetTester tester) async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";

    await tester
        .pumpWidget(startWidget(SettingsDetail(legalType: LegalType.PRIVACY)));
    expect(
        tester
            .widget<Opacity>(find.byKey(Key("player_view_container")))
            .opacity,
        0.0);
    expect(find.byKey(ValueKey<String>("termsprivacynote"), skipOffstage: true),
        findsOneWidget);
  });

  testWidgets(
      'that can init the setting detail screen screen with player playing in license',
      (WidgetTester tester) async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";

    await tester
        .pumpWidget(startWidget(SettingsDetail(legalType: LegalType.LICENSE)));
    expect(
        tester
            .widget<Opacity>(find.byKey(Key("player_view_container")))
            .opacity,
        1.0);
    expect(find.byKey(ValueKey<String>("licenseNote"), skipOffstage: true),
        findsOneWidget);
  });

  testWidgets(
      'that can init the setting detail screen screen with player no playing in license',
      (WidgetTester tester) async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";

    await tester
        .pumpWidget(startWidget(SettingsDetail(legalType: LegalType.LICENSE)));
    expect(
        tester
            .widget<Opacity>(find.byKey(Key("player_view_container")))
            .opacity,
        0.0);
    expect(find.byKey(ValueKey<String>("licenseNote"), skipOffstage: true),
        findsOneWidget);
  });

  testWidgets(
      'that can init the setting detail screen screen with player playing in gallery',
      (WidgetTester tester) async {
    //TODO
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";

    await tester
        .pumpWidget(startWidget(SettingsDetail(legalType: LegalType.NONE)));
    expect(
        tester
            .widget<Opacity>(find.byKey(Key("player_view_container")))
            .opacity,
        1.0);
    expect(find.byKey(ValueKey<String>("gallery_cotainer"), skipOffstage: true),
        findsOneWidget);
  });

  testWidgets(
      'that can init the setting detail screen screen with player no playing in gallery',
      (WidgetTester tester) async {
    //TODO
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";

    await tester
        .pumpWidget(startWidget(SettingsDetail(legalType: LegalType.NONE)));
    expect(
        tester
            .widget<Opacity>(find.byKey(Key("player_view_container")))
            .opacity,
        0.0);
    expect(find.byKey(ValueKey<String>("gallery_cotainer"), skipOffstage: true),
        findsOneWidget);
  });

  testWidgets(
      'that in setting detail screen can handle error on connection while playing',
      (WidgetTester tester) async {
    //tODO
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;
    mockPlayer.currentSong = "mocklive";
    when(mockPlayer.onConnection).thenReturn((isError) {
      tester.allStates.forEach((state) {
        if (state is SettingsDetailState) {
          state.onConnectionError();
        }
      });
    });

    await tester
        .pumpWidget(startWidget(SettingsDetail(legalType: LegalType.NONE)));
    mockPlayer.onConnection!(true);
    await tester.pumpAndSettle();

    expect(
        tester
            .widget<Opacity>(find.byKey(Key("player_view_container")))
            .opacity,
        1.0);
    expect(find.byKey(Key("connection_snackbar"), skipOffstage: true),
        findsOneWidget);
  });
}
