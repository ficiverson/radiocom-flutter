
import 'package:cuacfm/ui/podcast/controls/podcast_controls_presenter.dart';

enum PodcastControlState {
  onNewData,
  setupInitialRate
}

class MockPodcastControlsView implements PodcastControlsView {
  List<PodcastControlState> viewState = List();
  List<dynamic> data = List();

  @override
  onNewData() {
    viewState.add(PodcastControlState.onNewData);
  }

  @override
  setupInitialRate(int index) {
    viewState.add(PodcastControlState.setupInitialRate);
    data.add(index);
  }
}