import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_alerts_use_case.dart';
import 'package:cuacfm/domain/usecase/mark_alerts_read_use_case.dart';
import 'package:cuacfm/models/alert_record.dart';

abstract class AlertsView {
  void onLoadAlerts(List<AlertRecord> alerts);
  void onAlertsError(dynamic error);
}

class AlertsPresenter {
  final AlertsView _view;
  final Invoker invoker;
  final GetAlertsUseCase getAlertsUseCase;
  final MarkAlertsReadUseCase markAlertsReadUseCase;

  AlertsPresenter(
    this._view, {
    required this.invoker,
    required this.getAlertsUseCase,
    required this.markAlertsReadUseCase,
  });

  void loadAlerts() {
    invoker.execute(markAlertsReadUseCase).listen((_) {
      invoker.execute(getAlertsUseCase).listen((result) {
        if (result is Success) {
          _view.onLoadAlerts(result.data ?? []);
        } else {
          _view.onAlertsError((result as Error).status);
        }
      });
    });
  }
}
