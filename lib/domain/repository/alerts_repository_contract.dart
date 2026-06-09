import 'package:cuacfm/models/alert_record.dart';

abstract class AlertsRepositoryContract {
  Future<void> migratePending();
  void saveFromForeground(Map<String, dynamic> data);
  List<AlertRecord> getAlerts();
  Future<int> getUnreadCount();
  Future<void> markAllRead();
}
