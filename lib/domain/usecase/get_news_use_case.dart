import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/new.dart';

class GetNewsUseCase extends BaseUseCase<DataPolicy, List<New>> {
  CuacRepositoryContract radiocoRepository;

  GetNewsUseCase({required this.radiocoRepository});

  @override
  void invoke() {
    notifyListeners(radiocoRepository.getNews());
  }
}