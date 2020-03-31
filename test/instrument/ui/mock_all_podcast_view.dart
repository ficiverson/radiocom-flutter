import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_presenter.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_router.dart';

enum AllPodcastState {
  noConnection,
  onNewData,
  goToEpisode,
  goToPodcastDetail
}

class MockAllPodcastDetailView implements AllPodcastView {
  List<AllPodcastState> viewState = List();
  List<dynamic> data = List();

  @override
  onConnectionError() {
    viewState.add(AllPodcastState.noConnection);
  }

  @override
  onNewData() {
    viewState.add(AllPodcastState.onNewData);
  }
}

class MockAllPodcastDetailRouter implements AllPodcastRouter {
  List<AllPodcastState> viewState = List();
  List<dynamic> data = List();
  @override
  goToPodcastControls(Episode episode) {
    viewState.add(AllPodcastState.goToEpisode);
    data.add(episode);
  }

  @override
  goToPodcastDetail(Program podcast) {
    viewState.add(AllPodcastState.goToPodcastDetail);
    data.add(podcast);
  }
}