import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocult_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/radiocult/radiocult.dart';

class GetRadioCultLiveStatusUseCase
    extends BaseUseCase<DataPolicy, RadioCultLiveStatus> {
  RadioCultRepositoryContract repository;

  GetRadioCultLiveStatusUseCase({required this.repository});

  @override
  void invoke() {
    notifyListeners(repository.getLiveStatus());
  }
}
