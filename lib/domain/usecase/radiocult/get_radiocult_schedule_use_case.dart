import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocult_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/radiocult/radiocult.dart';

/// Parameters for getting schedule
class GetScheduleParams {
  final DateTime startDate;
  final DateTime endDate;
  final bool expandArtist;

  GetScheduleParams({
    required this.startDate,
    required this.endDate,
    this.expandArtist = false,
  });
}

class GetRadioCultScheduleUseCase
    extends BaseUseCase<GetScheduleParams, List<RadioCultEvent>> {
  RadioCultRepositoryContract repository;

  GetRadioCultScheduleUseCase({required this.repository});

  @override
  void invoke() {
    if (params != null) {
      notifyListeners(repository.getSchedule(
        params!.startDate,
        params!.endDate,
        expandArtist: params!.expandArtist,
      ));
    }
  }
}
