import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/alerts_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class GetAlertsUnreadCountUseCase extends BaseUseCase<void, int> {
  final AlertsRepositoryContract repository;

  GetAlertsUnreadCountUseCase({required this.repository});

  @override
  void invoke() {
    notifyListeners(
      repository.getUnreadCount().then((count) => Success(count, Status.ok) as Result<int>),
    );
  }
}
