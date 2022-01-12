import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/now.dart';

class GetLiveProgramUseCase extends BaseUseCase<DataPolicy, Now> {
  CuacRepositoryContract radiocoRepository;

  GetLiveProgramUseCase({required this.radiocoRepository});

  @override
  void invoke() {
    notifyListeners(radiocoRepository.getLiveBroadcast());
  }
}