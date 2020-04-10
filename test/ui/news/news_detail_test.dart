import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/ui/new-detail/new_detail.dart';
import 'package:cuacfm/ui/new-detail/new_detail_presenter.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../instrument/data/repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/model/news_instrument.dart';

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
  });

  setUp(() async {
    mockPlayer = MockPlayer();
  });

  tearDown(() async {
    Injector.appInstance.removeByKey<NewDetailView>();
  });

  testWidgets('that can init the news detail screen', (WidgetTester tester) async{
        when(mockRepository.getLiveBroadcast())
            .thenAnswer((_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.stop()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPodcast).thenReturn(false);
        when(mockPlayer.currentSong).thenReturn("mocklive");

        await tester.pumpWidget(startWidget(NewDetail(newItem : NewInstrument.givenANew())));
        expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 1.0);
        expect(
            find.byKey(PageStorageKey<String>("news_detail_container"),skipOffstage: true),
            findsOneWidget);

  });


  testWidgets('that can init the news detail screen without a player', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);
    when(mockPlayer.currentSong).thenReturn("mocklive");

    await tester.pumpWidget(startWidget(NewDetail(newItem : NewInstrument.givenANew())));
    expect(tester.widget<Opacity>(find.byKey(Key("player_view_container"))).opacity, 0.0);
    expect(
        find.byKey(PageStorageKey<String>("news_detail_container"),skipOffstage: true),
        findsOneWidget);

  });

  testWidgets('that in news detail screen can handle error on connection while playing', (WidgetTester tester) async{
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(false);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPodcast).thenReturn(false);
    when(mockPlayer.currentSong).thenReturn("mocklive");
    when(mockPlayer.onConnection).thenReturn((isError){
      tester.allStates.forEach((state){
        if( state is NewDetailState){
          state.onConnectionError();
        }
      });
    });

    await tester.pumpWidget(startWidget(NewDetail(newItem : NewInstrument.givenANew())));
    mockPlayer.onConnection(true);
    await tester.pumpAndSettle();

    expect(
        find.byKey(Key("connection_snackbar"),skipOffstage: true),
        findsOneWidget);
  });
}
