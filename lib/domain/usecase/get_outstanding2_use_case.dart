import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/outstanding.dart';

class GetOutstanding2UseCase extends BaseUseCase<void, Outstanding> {
  final CuacRepositoryContract radiocoRepository;

  GetOutstanding2UseCase({required this.radiocoRepository});

  @override
  void invoke() {
    notifyListeners(radiocoRepository.getOutStanding2().then(
      (result) => result is Success && result.data != null
          ? Success(result.data!, Status.ok)
          : Error(null, Status.fail, 'no data') as Result<Outstanding>,
    ));
  }
}
