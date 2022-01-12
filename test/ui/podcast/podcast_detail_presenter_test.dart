import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_presenter.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_router.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';

import '../../instrument/data/repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/model/episode_instrument.dart';
import '../../instrument/ui/mock_podcast_detail_view.dart';

void main() {
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  MockPodcastDetailView view = MockPodcastDetailView();
  MockPodcastDetailRouter router = MockPodcastDetailRouter();
  MockConnection mockConnection = MockConnection();
  MockPlayer mockPlayer = MockPlayer();
  late DetailPodcastPresenter presenter;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    DependencyInjector().loadModules();
    Injector.appInstance.registerDependency<CuacRepositoryContract>(
        () => mockRepository,
        override: true);
    Injector.appInstance
        .registerDependency<DetailPodcastView>(() => view, override: true);
    Injector.appInstance
        .registerDependency<DetailPodcastRouterContract>(() => router, override: true);
    Injector.appInstance.registerDependency<ConnectionContract>(
        () => mockConnection,
        override: true);
    Injector.appInstance.registerDependency<CurrentPlayerContract>(
        () => mockPlayer,
        override: true);
    presenter = Injector.appInstance.get<DetailPodcastPresenter>();
  });

  setUp(() async {
    mockPlayer = MockPlayer();
    presenter = Injector.appInstance.get<DetailPodcastPresenter>();
  });

  tearDown(() async {
    view.viewState.clear();
    view.data.clear();
    router.viewState.clear();
    router.data.clear();
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
    mockPlayer.isPodcast = false;

    presenter.onViewResumed();
    await Future.delayed(Duration(milliseconds: 200));

    expect(view.viewState[0], equals(PodcastDetailState.onNewData));
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
        mockPlayer.isPodcast = false;

        presenter.onViewResumed();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(PodcastDetailState.onNewData));
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
        mockPlayer.isPodcast = false;

        presenter.onViewResumed();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState.isEmpty, equals(true));
      });

  test(
      'that can init the presenter, then resume the view with a podcast then nothing happens in the view',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onViewResumed();
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState.isEmpty, equals(true));

      });

  test(
      'that can load episodes and update view',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getEpisodes(any)).thenAnswer(
                (_) => MockRadiocoRepository.episodes());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.loadEpisodes("feed");
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(PodcastDetailState.loadEpisodes));
        expect((view.data[0] as List).length, equals(1));
      });

  test(
      'that failed loading episodes and update view',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getEpisodes(any)).thenAnswer(
                (_) => MockRadiocoRepository.episodes(isEmpty: true));
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.loadEpisodes("feed");
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(PodcastDetailState.errorLoading));
        expect(view.data[0], equals(Status.fail.toString()));
      });

  test(
      'that can verify same episode',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getEpisodes(any)).thenAnswer(
                (_) => MockRadiocoRepository.episodes(isEmpty: true));
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;
        mockPlayer.episode = EpisodeInstrument.givenAnEpisode();


       expect(presenter.isSamePodcast(EpisodeInstrument.givenAnEpisode()), true);
      });


  test(
      'that can verify different episode',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getEpisodes(any)).thenAnswer(
                (_) => MockRadiocoRepository.episodes(isEmpty: true));
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;
        mockPlayer.episode = EpisodeInstrument.givenAnEpisode();


        expect( presenter.isSamePodcast(EpisodeInstrument.givenAnEpisode(audioUrl: "http://myaudio")), false);
      });

  test(
      'that can play different episode when its paused',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getEpisodes(any)).thenAnswer(
                (_) => MockRadiocoRepository.episodes(isEmpty: true));
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.isStreamingAudio()).thenReturn(true);
        when(mockPlayer.stopAndPlay()).thenAnswer((_) => Future.value(true));
        mockPlayer.episode = EpisodeInstrument.givenAnEpisode(audioUrl: "http://random");

        presenter.onSelectedEpisode(EpisodeInstrument.givenAnEpisode(),"http://image");
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(PodcastDetailState.playerStatus));
        expect((view.data[0] as StatusPlayer), equals(StatusPlayer.PLAYING));
      });

  test(
      'that can play different episode when its pause and notify an error in player because cannot pause current',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getEpisodes(any)).thenAnswer(
                (_) => MockRadiocoRepository.episodes(isEmpty: true));
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;
        when(mockPlayer.isPlaying()).thenReturn(true);
        when(mockPlayer.isStreamingAudio()).thenReturn(true);
        when(mockPlayer.stopAndPlay()).thenAnswer((_) => Future.value(false));
        mockPlayer.episode = EpisodeInstrument.givenAnEpisode(audioUrl: "http://random");

        presenter.onSelectedEpisode(EpisodeInstrument.givenAnEpisode(),"http://image");
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(PodcastDetailState.playerStatus));
        expect((view.data[0] as StatusPlayer), equals(StatusPlayer.FAILED));
      });

  test(
      'that can play an audio if its not playing',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getEpisodes(any)).thenAnswer(
                (_) => MockRadiocoRepository.episodes(isEmpty: true));
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;
        when(mockPlayer.isPlaying()).thenReturn(false);
        when(mockPlayer.isStreamingAudio()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer((_) => Future.value(true));
        mockPlayer.episode = EpisodeInstrument.givenAnEpisode(audioUrl: "http://random");

        presenter.onSelectedEpisode(EpisodeInstrument.givenAnEpisode(),"http://image");
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(PodcastDetailState.playerStatus));
        expect((view.data[0] as StatusPlayer), equals(StatusPlayer.PLAYING));
      });

  test(
      'that cannot play an audio if its not playing',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getEpisodes(any)).thenAnswer(
                (_) => MockRadiocoRepository.episodes(isEmpty: true));
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;
        when(mockPlayer.isPlaying()).thenReturn(false);
        when(mockPlayer.isStreamingAudio()).thenReturn(true);
        when(mockPlayer.play()).thenAnswer((_) => Future.value(false));
        mockPlayer.episode = EpisodeInstrument.givenAnEpisode(audioUrl: "http://random");

        presenter.onSelectedEpisode(EpisodeInstrument.givenAnEpisode(),"http://image");
        await Future.delayed(Duration(milliseconds: 200));

        expect(view.viewState[0], equals(PodcastDetailState.playerStatus));
        expect((view.data[0] as StatusPlayer), equals(StatusPlayer.FAILED));
      });

  test(
      'that can resume the same episode when its paused',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockRepository.getEpisodes(any)).thenAnswer(
                (_) => MockRadiocoRepository.episodes(isEmpty: true));
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;
        mockPlayer.episode = EpisodeInstrument.givenAnEpisode();
        when(mockPlayer.isPlaying()).thenReturn(false);
        when(mockPlayer.resume()).thenAnswer((_) => Future.value());


        presenter.onSelectedEpisode(EpisodeInstrument.givenAnEpisode(),"http://image");
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState.length, equals(0));
      });


  test(
      'that can navigate to podcast controls',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onPodcastControlsClicked(EpisodeInstrument.givenAnEpisode());
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(PodcastDetailState.goToEpisode));
        expect((router.data[0] as Episode).title, equals(EpisodeInstrument.givenAnEpisode().title));
      });

  test(
      'that can navigate to detail podcast',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onDetailPodcast("title","subtile","content","http://url");
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(PodcastDetailState.goToEpisodeDetail));
        expect((router.data[0] as New).title, equals("title"));
      });

  test(
      'that can navigate to detail episode',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onDetailEpisode("title","subtile","content","http://url");
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(PodcastDetailState.goToEpisodeDetail));
        expect((router.data[0] as New).title, equals("title"));
      });
}
