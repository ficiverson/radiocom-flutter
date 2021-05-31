import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_presenter.dart';
import 'package:cuacfm/ui/podcast/detail_podcast_router.dart';

enum PodcastDetailState {
  noConnection,
  onNewData,
  errorLoading,
  loadEpisodes,
  playerStatus,
  goToEpisode,
  goToEpisodeDetail
}

class MockPodcastDetailView implements DetailPodcastView {
  List<PodcastDetailState> viewState = [];
  List<dynamic> data = [];

  @override
  onConnectionError() {
    viewState.add(PodcastDetailState.noConnection);
  }

  @override
  onNewData() {
    viewState.add(PodcastDetailState.onNewData);
  }

  @override
  onErrorLoadingEpisodes(String err) {
    viewState.add(PodcastDetailState.errorLoading);
    data.add(err);
  }

  @override
  void onLoadEpidoses(List<Episode> episodes) {
    viewState.add(PodcastDetailState.loadEpisodes);
    data.add(episodes);
  }

  @override
  onPlayerData(StatusPlayer statusPlayer) {
    viewState.add(PodcastDetailState.playerStatus);
    data.add(statusPlayer);
  }
}

class MockPodcastDetailRouter implements DetailPodcastRouter {
  List<PodcastDetailState> viewState = [];
  List<dynamic> data = [];
  @override
  goToPodcastControls(Episode episode) {
    viewState.add(PodcastDetailState.goToEpisode);
    data.add(episode);
  }

  @override
  goToNewDetail(New itemNew) {
    viewState.add(PodcastDetailState.goToEpisodeDetail);
    data.add(itemNew);
  }
}