import 'package:cuacfm/data/datasource/alerts_local_datasource_contract.dart';
import 'package:cuacfm/domain/repository/alerts_repository_contract.dart';
import 'package:cuacfm/models/alert_record.dart';

class AlertsRepository implements AlertsRepositoryContract {
  final AlertsLocalDataSourceContract _localDataSource;

  AlertsRepository({required AlertsLocalDataSourceContract localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<void> migratePending() => _localDataSource.migratePending();

  @override
  void saveFromForeground(Map<String, dynamic> data) =>
      _localDataSource.saveFromForeground(data);

  @override
  List<AlertRecord> getAlerts() => _localDataSource.getAlerts();

  @override
  Future<int> getUnreadCount() => _localDataSource.getUnreadCount();

  @override
  Future<void> markAllRead() => _localDataSource.markAllRead();
}
