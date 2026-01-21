import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocult_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/radiocult/radiocult.dart';

class GetRadioCultTagsUseCase
    extends BaseUseCase<DataPolicy, List<RadioCultTag>> {
  RadioCultRepositoryContract repository;

  GetRadioCultTagsUseCase({required this.repository});

  @override
  void invoke() {
    notifyListeners(repository.getTags());
  }
}
