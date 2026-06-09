import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/wrapped_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class StartSessionParams {
  final bool isPodcast;
  final String programName;
  final String category;
  final String episodeTitle;
  final String episodeId;

  StartSessionParams({
    required this.isPodcast,
    this.programName = '',
    this.category = '',
    this.episodeTitle = '',
    this.episodeId = '',
  });
}

class StartSessionUseCase extends BaseUseCase<StartSessionParams, bool> {
  final WrappedRepositoryContract repository;

  StartSessionUseCase({required this.repository});

  @override
  void invoke() {
    final p = params;
    if (p != null) {
      repository.startSession(
        isPodcast: p.isPodcast,
        programName: p.programName,
        category: p.category,
        episodeTitle: p.episodeTitle,
        episodeId: p.episodeId,
      );
    }
    notifyListeners(Future.value(Success(true, Status.ok)));
  }
}
