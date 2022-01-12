import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/injector/dependency_injector.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/ui/new-detail/new_detail_presenter.dart';
import 'package:cuacfm/ui/new-detail/new_detail_router.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injector/injector.dart';
import 'package:mockito/mockito.dart';

import '../../instrument/data/repository_mock.dart';
import '../../instrument/helper/helper-instrument.dart';
import '../../instrument/model/episode_instrument.dart';
import '../../instrument/ui/mock_news_detail_view.dart';

void main() {
  MockRadiocoRepository mockRepository = MockRadiocoRepository();
  MockNewsDetailView view = MockNewsDetailView();
  MockNewsRouter router = MockNewsRouter();
  MockConnection mockConnection = MockConnection();
  MockPlayer mockPlayer = MockPlayer();
  late NewDetailPresenter presenter;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    DependencyInjector().loadModules();
    Injector.appInstance.registerDependency<CuacRepositoryContract>(
        () => mockRepository,
        override: true);
    Injector.appInstance
        .registerDependency<NewDetailView>(() => view, override: true);
    Injector.appInstance
        .registerDependency<NewDetailRouterContract>(() => router, override: true);
    Injector.appInstance.registerDependency<ConnectionContract>(
        () => mockConnection,
        override: true);
    Injector.appInstance.registerDependency<CurrentPlayerContract>(
        () => mockPlayer,
        override: true);
    presenter = Injector.appInstance.get<NewDetailPresenter>();
  });

  setUp(() async {
    mockPlayer = MockPlayer();
    presenter = Injector.appInstance.get<NewDetailPresenter>();
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

    expect(view.viewState[0], equals(NewsDetailState.onNewData));
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

        expect(view.viewState[0], equals(NewsDetailState.onNewData));
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
      'that can navigate to podcast controls',
          () async {
        when(mockRepository.getLiveBroadcast()).thenAnswer(
                (_) => MockRadiocoRepository.now());
        when(mockConnection.isConnectionAvailable())
            .thenAnswer((_) => Future.value(true));
        mockPlayer.isPodcast = true;

        presenter.onPodcastControlsClicked(EpisodeInstrument.givenAnEpisode());
        await Future.delayed(Duration(milliseconds: 200));

        expect(router.viewState[0], equals(NewsDetailState.goToEpisode));
        expect((router.data[0] as Episode).title, equals(EpisodeInstrument.givenAnEpisode().title));
      });
}
