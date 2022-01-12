import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/models/outstanding.dart';



class GetOutstandingUseCase extends BaseUseCase<void, Outstanding> {
  CuacRepositoryContract radiocoRepository;

  GetOutstandingUseCase({required this.radiocoRepository});

  @override
  void invoke() {
    notifyListeners(radiocoRepository.getOutStanding());
  }
}