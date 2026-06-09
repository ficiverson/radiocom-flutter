import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/wrapped_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class EndSessionUseCase extends BaseUseCase<void, bool> {
  final WrappedRepositoryContract repository;

  EndSessionUseCase({required this.repository});

  @override
  void invoke() {
    repository.endSession();
    notifyListeners(Future.value(Success(true, Status.ok)));
  }
}
