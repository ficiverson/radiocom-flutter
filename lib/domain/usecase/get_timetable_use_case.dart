import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/models/time_table.dart';

class GetTimetableUseCaseParams{
  String now;
  String tomorrow;
  GetTimetableUseCaseParams(this.now,this.tomorrow);
}

class GetTimetableUseCase extends BaseUseCase<GetTimetableUseCaseParams, List<TimeTable>> {
  CuacRepositoryContract radiocoRepository;

  GetTimetableUseCase({required this.radiocoRepository});

  @override
  void invoke() {
    notifyListeners(radiocoRepository.getTimetableData(params?.now ?? "", params?.tomorrow ?? ""));
  }
}