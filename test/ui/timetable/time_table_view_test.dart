import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/timetable/time_table_presenter.dart';
import 'package:cuacfm/ui/timetable/time_table_view.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';

import '../../instrument/data/repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/model/timetable_instrument.dart';

void main() {
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  MockConnection mockConnection = MockConnection();
  MockPlayer mockPlayer = MockPlayer();

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
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
    Injector.appInstance.removeByKey<TimeTableView>();
  });

  testWidgets('that can init time table with music player',
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

    await tester.pumpWidget(startWidget(Timetable(timeTables: [
      TimeTableInstrument.givenATimeTable(time: 0),
      TimeTableInstrument.givenATimeTable(time: 1),
      TimeTableInstrument.givenATimeTable(time: 2),
      TimeTableInstrument.givenATimeTable(time: 3),
      TimeTableInstrument.givenATimeTable(time: 4),
      TimeTableInstrument.givenATimeTable(time: 5),
      TimeTableInstrument.givenATimeTable(time: 6),
      TimeTableInstrument.givenATimeTable(time: 7),
      TimeTableInstrument.givenATimeTable(time: 8),
      TimeTableInstrument.givenATimeTable(time: 9),
      TimeTableInstrument.givenATimeTable(time: 10),
      TimeTableInstrument.givenATimeTable(time: 11),
      TimeTableInstrument.givenATimeTable(time: 12),
      TimeTableInstrument.givenATimeTable(time: 13),
      TimeTableInstrument.givenATimeTable(time: 14),
      TimeTableInstrument.givenATimeTable(time: 15),
      TimeTableInstrument.givenATimeTable(time: 16),
      TimeTableInstrument.givenATimeTable(time: 17),
      TimeTableInstrument.givenATimeTable(time: 18),
      TimeTableInstrument.givenATimeTable(time: 19),
      TimeTableInstrument.givenATimeTable(time: 20),
      TimeTableInstrument.givenATimeTable(time: 21),
      TimeTableInstrument.givenATimeTable(time: 22),
      TimeTableInstrument.givenATimeTable(time: 23),
    ])));

    expect(
        tester
            .widget<Opacity>(find.byKey(Key("player_view_container")))
            .opacity,
        1.0);
    expect(
        find.byKey(PageStorageKey<String>("timeTableList"), skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that can init time table without music player playing',
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

    await tester.pumpWidget(startWidget(Timetable(timeTables: [
      TimeTableInstrument.givenATimeTable(time: 0),
      TimeTableInstrument.givenATimeTable(time: 1),
      TimeTableInstrument.givenATimeTable(time: 2),
      TimeTableInstrument.givenATimeTable(time: 3),
      TimeTableInstrument.givenATimeTable(time: 4),
      TimeTableInstrument.givenATimeTable(time: 5),
      TimeTableInstrument.givenATimeTable(time: 6),
      TimeTableInstrument.givenATimeTable(time: 7),
      TimeTableInstrument.givenATimeTable(time: 8),
    ])));

    expect(
        tester
            .widget<Opacity>(find.byKey(Key("player_view_container")))
            .opacity,
        0.0);
    expect(
        find.byKey(PageStorageKey<String>("timeTableList"), skipOffstage: true),
        findsOneWidget);
  });

  testWidgets('that in time table screen can handle connection error',
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
    when(mockPlayer.onConnection).thenReturn((isError) {
      tester.allStates.forEach((state) {
        if (state is TimetableState) {
          state.onConnectionError();
        }
      });
    });
    await tester.pumpWidget(startWidget(Timetable(timeTables: [
      TimeTableInstrument.givenATimeTable(time: 0),
      TimeTableInstrument.givenATimeTable(time: 1),
      TimeTableInstrument.givenATimeTable(time: 2),
      TimeTableInstrument.givenATimeTable(time: 3),
      TimeTableInstrument.givenATimeTable(time: 4),
    ])));
    mockPlayer.onConnection!(true);
    await tester.pumpAndSettle();

    expect(find.byKey(Key("connection_snackbar"), skipOffstage: true),
        findsOneWidget);
  });
}
