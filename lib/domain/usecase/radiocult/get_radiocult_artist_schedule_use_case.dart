import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocult_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/radiocult/radiocult.dart';

/// Parameters for getting artist schedule
class GetArtistScheduleParams {
  final String artistId;
  final DateTime startDate;
  final DateTime endDate;

  GetArtistScheduleParams({
    required this.artistId,
    required this.startDate,
    required this.endDate,
  });
}

class GetRadioCultArtistScheduleUseCase
    extends BaseUseCase<GetArtistScheduleParams, List<RadioCultEvent>> {
  RadioCultRepositoryContract repository;

  GetRadioCultArtistScheduleUseCase({required this.repository});

  @override
  void invoke() {
    if (params != null) {
      notifyListeners(repository.getArtistSchedule(
        params!.artistId,
        params!.startDate,
        params!.endDate,
      ));
    }
  }
}
