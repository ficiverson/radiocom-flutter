import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/program.dart';

class GetAllPodcastUseCase extends BaseUseCase<DataPolicy, List<Program>> {
  CuacRepositoryContract radiocoRepository;

  GetAllPodcastUseCase({required this.radiocoRepository});

  @override
  void invoke() {
    notifyListeners(radiocoRepository.getAllPodcasts());
  }
}