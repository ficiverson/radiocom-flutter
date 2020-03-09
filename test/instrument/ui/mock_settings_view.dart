import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/ui/settings/settings-detail/settings_detail.dart';
import 'package:cuacfm/ui/settings/settings_presenter.dart';
import 'package:cuacfm/ui/settings/settings_router.dart';

enum SettingsState {
  noConnection,
  onNewData,
  onDarkMode,
  goToEpisode,
  goToHistory,
  goToLegal
}

class MockSettingsView implements SettingsView {
  List<SettingsState> viewState = List();
  List<dynamic> data = List();

  @override
  onConnectionError() {
    viewState.add(SettingsState.noConnection);
  }

  @override
  onNewData() {
    viewState.add(SettingsState.onNewData);
  }

  @override
  onDarkModeStatus(bool status) {
    viewState.add(SettingsState.onDarkMode);
    data.add(status);
  }
}

class MockSettingsRouter implements SettingsRouterContract {
  List<SettingsState> viewState = List();
  List<dynamic> data = List();
  @override
  goToPodcastControls(Episode episode) {
    viewState.add(SettingsState.goToEpisode);
    data.add(episode);
  }

  @override
  goToHistory(New newItem) {
    viewState.add(SettingsState.goToHistory);
    data.add(newItem);
  }

  @override
  goToLegal(LegalType legalType) {
    viewState.add(SettingsState.goToLegal);
    data.add(legalType);
  }
}