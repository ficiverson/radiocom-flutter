import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/ui/new-detail/new_detail_presenter.dart';
import 'package:cuacfm/ui/new-detail/new_detail_router.dart';
enum NewsDetailState {
  noConnection,
  onNewData,
  goToEpisode
}

class MockNewsDetailView implements NewDetailView {
  List<NewsDetailState> viewState = List();
  List<dynamic> data = List();

  @override
  onConnectionError() {
    viewState.add(NewsDetailState.noConnection);
  }

  @override
  onNewData() {
    viewState.add(NewsDetailState.onNewData);
  }
}

class MockNewsRouter implements NewDetailRouterContract {
  List<NewsDetailState> viewState = List();
  List<dynamic> data = List();
  @override
  goToPodcastControls(Episode episode) {
    viewState.add(NewsDetailState.goToEpisode);
    data.add(episode);
  }
}