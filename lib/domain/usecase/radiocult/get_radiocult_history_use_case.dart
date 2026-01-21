import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocult_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/radiocult/radiocult.dart';

/// Parameters for getting history
class GetHistoryParams {
  final int limit;

  GetHistoryParams({this.limit = 5});
}

class GetRadioCultHistoryUseCase
    extends BaseUseCase<GetHistoryParams, List<RadioCultLastPlayed>> {
  RadioCultRepositoryContract repository;

  GetRadioCultHistoryUseCase({required this.repository});

  @override
  void invoke() {
    final limit = params?.limit ?? 5;
    notifyListeners(repository.getHistory(limit: limit));
  }
}
