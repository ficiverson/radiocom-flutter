import 'package:cuacfm/models/alert_record.dart';
import 'package:cuacfm/ui/alerts/alerts_presenter.dart';

enum AlertsState {
  onLoadAlerts,
  onAlertsError,
}

class MockAlertsView implements AlertsView {
  List<AlertsState> viewState = [];
  List<dynamic> data = [];

  @override
  void onLoadAlerts(List<AlertRecord> alerts) {
    viewState.add(AlertsState.onLoadAlerts);
    data.add(alerts);
  }

  @override
  void onAlertsError(dynamic error) {
    viewState.add(AlertsState.onAlertsError);
    data.add(error);
  }
}
