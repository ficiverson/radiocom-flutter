import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/ui/home/home_router.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../instrument/data/repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/model/episode_instrument.dart';
import '../../instrument/model/news_instrument.dart';
import '../../instrument/model/now_instrument.dart';
import '../../instrument/model/outstanding_instrument.dart';
import '../../instrument/model/program_instrument.dart';
import '../../instrument/ui/mock_home_view.dart';

void main() {
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  MockHomeView view = MockHomeView();
  MockHomeRouter router = MockHomeRouter();
  MockConnection mockConnection = MockConnection();
  MockPlayer mockPlayer = MockPlayer();
  late HomePresenter presenter;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    DependencyInjector().loadModules();
    getTranslations();
    Injector.appInstance.registerDependency<CuacRepositoryContract>(
        () => mockRepository,
        override: true);
    Injector.appInstance
        .registerDependency<HomeView>(() => view, override: true);
    Injector.appInstance
        .registerDependency<HomeRouterContract>(() => router, override: true);
    Injector.appInstance.registerDependency<ConnectionContract>(
        () => mockConnection,
        override: true);
    Injector.appInstance.registerDependency<CurrentPlayerContract>(
        () => mockPlayer,
        override: true);
    presenter = Injector.appInstance.get<HomePresenter>();
  });

  setUp(() async {
    mockPlayer = MockPlayer();
    presenter = Injector.appInstance.get<HomePresenter>();
  });

  tearDown(() async {
    view.viewState.clear();
    view.data.clear();
    router.viewState.clear();
    router.data.clear();
  });

  test('that can init the presenter and load all data',
          () async {
        when(mockRepository.getLiveBroadcast())
            .thenAnswer((_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockRepository.getEpisodes(any)).thenAnswer((_) => MockRadiocoRepository.episodes());
        when(mockRepository.getAllPodcasts()).thenAnswer((_) => MockRadiocoRepository.podcasts());
        when(mockRepository.getRadioStationData()).thenAnswer((_) => MockRadiocoRepository.radioStation());
        when(mockRepository.getNews()).thenAnswer((_) => MockRadiocoRepository.news());
        when(mockRepository.getOutStanding()).thenAnswer((_) => MockRadiocoRepository.outstanding());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.stop()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = false;

        presenter.init();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.onDarkMode));
        expect(view.viewState[1], equals(HomeState.connectionSuccess));
        expect(view.viewState[2], equals(HomeState.loadStation));
        expect(view.viewState[3], equals(HomeState.liveDataLoaded));
        expect(view.viewState[4], equals(HomeState.loadRecent));
        expect(view.viewState[5], equals(HomeState.onOutstanding));
        expect(view.viewState[6], equals(HomeState.loadTimetable));
        expect(view.viewState[7], equals(HomeState.loadPodcast));
        expect(view.viewState[8], equals(HomeState.loadNews));
      });

  test('that can init the presenter without connection',
          () async {
        when(mockRepository.getLiveBroadcast())
            .thenAnswer((_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockRepository.getEpisodes(any)).thenAnswer((_) => MockRadiocoRepository.episodes());
        when(mockRepository.getAllPodcasts()).thenAnswer((_) => MockRadiocoRepository.podcasts());
        when(mockRepository.getRadioStationData()).thenAnswer((_) => MockRadiocoRepository.radioStation());
        when(mockRepository.getNews()).thenAnswer((_) => MockRadiocoRepository.news());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(false));
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.stop()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = false;

        presenter.init();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.onDarkMode));
        expect(view.viewState[1], equals(HomeState.noConnection));
        expect(view.viewState[2], equals(HomeState.recenterror));
        expect(view.viewState[3], equals(HomeState.newsError));
        expect(view.viewState[4], equals(HomeState.podcastError));
        expect(view.viewState[5], equals(HomeState.timetableError));
      });

  test('that can init the presenter withhout service working',
          () async {
        when(mockRepository.getLiveBroadcast())
            .thenAnswer((_) => MockRadiocoRepository.now(isEmpty: true));
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables(isEmpty: true));
        when(mockRepository.getEpisodes(any)).thenAnswer((_) => MockRadiocoRepository.episodes(isEmpty: true));
        when(mockRepository.getAllPodcasts()).thenAnswer((_) => MockRadiocoRepository.podcasts(isEmpty: true));
        when(mockRepository.getRadioStationData()).thenAnswer((_) => MockRadiocoRepository.radioStation(isEmpty: true));
        when(mockRepository.getNews()).thenAnswer((_) => MockRadiocoRepository.news(isEmpty: true));
        when(mockRepository.getOutStanding()).thenAnswer((_) => MockRadiocoRepository.outstanding());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.stop()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = false;

        presenter.init();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.onDarkMode));
        expect(view.viewState[1], equals(HomeState.connectionSuccess));
        expect(view.viewState[2], equals(HomeState.stationError));
        expect(view.viewState[3], equals(HomeState.liveDataError));
        expect(view.viewState[4], equals(HomeState.recenterror));
        expect(view.viewState[5], equals(HomeState.onOutstanding));
        expect(view.viewState[6], equals(HomeState.timetableError));
        expect(view.viewState[7], equals(HomeState.podcastError));
        expect(view.viewState[8], equals(HomeState.newsError));
      });

  test('that can resume the view and realod the data',
      () async {
    when(mockRepository.getLiveBroadcast())
        .thenAnswer((_) => MockRadiocoRepository.now());
    when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
    when(mockConnection.isConnectionAvailable())
        .thenAnswer((_) => Future.value(true));
    when(mockPlayer.isPlaying()).thenReturn(true);
    when(mockPlayer.stop()).thenReturn(true);
    when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
    mockPlayer.isPodcast = false;

    presenter.onHomeResumed();
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState[0], equals(HomeState.onDarkMode));
    expect(view.viewState[1], equals(HomeState.liveDataLoaded));
    expect((view.data[1] as Now).name, equals(NowInstrument.givenANow().name));
    expect(view.viewState[2], equals(HomeState.loadRecent));
    expect((view.data[2] as List<TimeTable>).length, equals(1));
  });

  test('that can resume the view and realod the data with error response reload the view with base now',
          () async {
        when(mockRepository.getLiveBroadcast())
            .thenAnswer((_) => MockRadiocoRepository.now(isEmpty: true));
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables(isEmpty: true));
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.stop()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = false;

        presenter.onHomeResumed();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.onDarkMode));
        expect(view.viewState[1], equals(HomeState.liveDataError));
        expect(view.viewState[2], equals(HomeState.recenterror));
      });

  test(
      'that can resume the view and connection error then nothing happens in the view',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(false));
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.stop()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = false;

        presenter.onHomeResumed();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.onDarkMode));
        expect(view.viewState.length, equals(1));
      });

  test(
      'that can navigate to podcast controls',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onPodcastControlsClicked(EpisodeInstrument.givenAnEpisode());
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(HomeState.goToEpisode));
        expect((router.data[0] as Episode).title, equals(EpisodeInstrument.givenAnEpisode().title));
      });

  test(
      'that can navigate to all podcast',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onSeeAllPodcast([]);
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(HomeState.goToAllPodcast));
        expect((router.data[0] as List), equals([]));
      });

  test(
      'that can navigate to all podcast with category',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onSeeCategory([], "Humor");
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(HomeState.goToAllPodcast));
        expect(router.data[0], equals( "Humor"));
      });

  test(
      'that can navigate to now playing',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.nowPlayingClicked([]);
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(HomeState.goToTimeTable));
        expect((router.data[0] as List), equals([]));
      });

  test(
      'that can navigate to new detail',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onNewClicked(NewInstrument.givenANew());
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(HomeState.goToNewDetail));
        expect((router.data[0] as New).title, equals(NewInstrument.givenANew().title));
      });

  test(
      'that can navigate to new detail',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onMenuClicked();
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(HomeState.goToSettings));
      });

  test(
      'that can navigate to podcast detail',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onPodcastClicked(ProgramInstrument.givenAProgram());
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(HomeState.goToPodcast));
        expect((router.data[0] as Program).name, equals(ProgramInstrument.givenAProgram().name));
      });

  test(
      'that can navigate to outstanding detail',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onOutstandingClicked(OutstandingInstrument.givenAOutstanding());
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(HomeState.goToNewDetail));
      });

  test(
      'that can play podcast in stop state',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.play())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;
        mockPlayer.playerState = AudioPlayerState.stop;

        presenter.onSelectedEpisode();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.notifyUser));
        expect((view.data[0] as StatusPlayer), equals(StatusPlayer.PLAYING));
      });

  test(
      'that can resume podcast',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        when(mockPlayer.play())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onSelectedEpisode();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.notifyUser));
        expect((view.data[0] as StatusPlayer), equals(StatusPlayer.PLAYING));
      });

  test(
      'that can pause streaming',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = false;
        when(mockPlayer.stop()).thenAnswer(
                (_) => Future.value(true));

        presenter.onPausePlayer();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.notifyUser));
        expect((view.data[0] as StatusPlayer), equals(StatusPlayer.STOP));
      });

  test(
      'that can pause podcast',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;
        when(mockPlayer.pause()).thenAnswer(
                (_) => Future.value(true));

        presenter.onPausePlayer();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.notifyUser));
        expect((view.data[0] as StatusPlayer), equals(StatusPlayer.STOP));
      });

  test(
      'that can play streaming when its not playing',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = false;
        when(mockPlayer.isPlaying()).thenReturn(false);
        when(mockPlayer.isStreamingAudio()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer(
                (_) => Future.value(true));

        presenter.onLiveSelected(NowInstrument.givenANow());
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.liveDataLoaded));
        expect(view.viewState[1], equals(HomeState.loadRecent));
        expect(view.viewState[2], equals(HomeState.notifyUser));
        expect((view.data[2] as StatusPlayer), equals(StatusPlayer.PLAYING));
      });

  test(
      'that can play streaming when its playing',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = false;
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.isStreamingAudio()).thenReturn(true);
        when(mockPlayer.stopAndPlay()).thenAnswer(
                (_) => Future.value(true));

        presenter.onLiveSelected(NowInstrument.givenANow());
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.liveDataLoaded));
        expect(view.viewState[1], equals(HomeState.loadRecent));
        expect(view.viewState[2], equals(HomeState.notifyUser));
        expect((view.data[2] as StatusPlayer), equals(StatusPlayer.PLAYING));
      });


  test(
      'that cannot play streaming when its not playing',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = false;
        when(mockPlayer.isPlaying()).thenReturn(false);
        when(mockPlayer.isStreamingAudio()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer(
                (_) => Future.value(false));

        presenter.onLiveSelected(NowInstrument.givenANow());
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.notifyUser));
        expect((view.data[0] as StatusPlayer), equals(StatusPlayer.FAILED));
      });

  test(
      'that cannot play streaming when its playing',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getTimetableData(any, any)).thenAnswer((_) => MockRadiocoRepository.timetables());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = false;
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.isStreamingAudio()).thenReturn(true);
        when(mockPlayer.stopAndPlay()).thenAnswer(
                (_) => Future.value(false));

        presenter.onLiveSelected(NowInstrument.givenANow());
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(HomeState.notifyUser));
        expect((view.data[0] as StatusPlayer), equals(StatusPlayer.FAILED));
      });
}
