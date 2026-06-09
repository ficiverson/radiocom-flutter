import 'package:cuacfm/ui/episode-detail/episode_detail_presenter.dart';

enum EpisodeDetailState {
  onPlaylistStatusChanged,
}

class MockEpisodeDetailView implements EpisodeDetailView {
  List<EpisodeDetailState> viewState = [];
  List<dynamic> data = [];

  @override
  void onPlaylistStatusChanged(bool inPlaylist) {
    viewState.add(EpisodeDetailState.onPlaylistStatusChanged);
    data.add(inPlaylist);
  }
}
