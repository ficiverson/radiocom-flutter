import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail_router.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_presenter_detail.dart';

enum SettingsDetailViewState {
  noConnection,
  onNewData,
  goToEpisode
}

class MockSettingsDetailView implements SettingsDetailView {
  List<SettingsDetailViewState> viewState = [];
  List<dynamic> data = [];

  @override
  onConnectionError() {
    viewState.add(SettingsDetailViewState.noConnection);
  }

  @override
  onNewData() {
    viewState.add(SettingsDetailViewState.onNewData);
  }
}

class MockSettingsDetailRouter implements SettingsDetailRouterContract {
  List<SettingsDetailViewState> viewState = [];
  List<dynamic> data = [];
  @override
  goToPodcastControls(Episode episode) {
    viewState.add(SettingsDetailViewState.goToEpisode);
    data.add(episode);
  }
}