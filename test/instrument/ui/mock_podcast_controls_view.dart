import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/ui/new-detail/new_detail_presenter.dart';
import 'package:cuacfm/ui/new-detail/new_detail_router.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_presenter.dart';
import 'package:cuacfm/ui/podcast/all_podcast/all_podcast_router.dart';
import 'package:cuacfm/ui/podcast/controls/podcast_controls_presenter.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail_router.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_presenter_detail.dart';

enum PodcastControlState {
  onNewData,
}

class MockPodcastControlsView implements PodcastControlsView {
  List<PodcastControlState> viewState = List();
  List<dynamic> data = List();

  @override
  onNewData() {
    viewState.add(PodcastControlState.onNewData);
  }
}