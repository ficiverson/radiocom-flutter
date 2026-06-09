import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/alerts_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class SaveAlertUseCase extends BaseUseCase<Map<String, dynamic>, bool> {
  final AlertsRepositoryContract repository;

  SaveAlertUseCase({required this.repository});

  @override
  void invoke() {
    repository.saveFromForeground(params ?? {});
    notifyListeners(Future.value(Success(true, Status.ok)));
  }
}
