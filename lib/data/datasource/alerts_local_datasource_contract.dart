import 'package:cuacfm/models/alert_record.dart';

abstract class AlertsLocalDataSourceContract {
  Future<void> migratePending();
  void saveFromForeground(Map<String, dynamic> data);
  List<AlertRecord> getAlerts();
  void cleanOldAlerts({int keepDays = 90});
  Future<int> getUnreadCount();
  Future<void> markAllRead();
}
