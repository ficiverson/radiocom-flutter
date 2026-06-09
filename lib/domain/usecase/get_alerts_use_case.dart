import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/alerts_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/alert_record.dart';

class GetAlertsUseCase extends BaseUseCase<void, List<AlertRecord>> {
  final AlertsRepositoryContract repository;

  GetAlertsUseCase({required this.repository});

  @override
  void invoke() {
    notifyListeners(Future.value(Success(repository.getAlerts(), Status.ok)));
  }
}
