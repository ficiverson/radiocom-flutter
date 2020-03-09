import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail_router.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_presenter_detail.dart';

enum SettingsDetailState {
  noConnection,
  onNewData,
  goToEpisode
}

class MockSettingsDetailView implements SettingsDetailView {
  List<SettingsDetailState> viewState = List();
  List<dynamic> data = List();

  @override
  onConnectionError() {
    viewState.add(SettingsDetailState.noConnection);
  }

  @override
  onNewData() {
    viewState.add(SettingsDetailState.onNewData);
  }
}

class MockSettingsDetailRouter implements SettingsDetailRouterContract {
  List<SettingsDetailState> viewState = List();
  List<dynamic> data = List();
  @override
  goToPodcastControls(Episode episode) {
    viewState.add(SettingsDetailState.goToEpisode);
    data.add(episode);
  }
}