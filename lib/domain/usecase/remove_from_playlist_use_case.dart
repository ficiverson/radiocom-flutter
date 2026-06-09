import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class RemoveFromPlaylistUseCase extends BaseUseCase<String, bool> {
  final PlaylistRepositoryContract repository;

  RemoveFromPlaylistUseCase({required this.repository});

  @override
  void invoke() {
    repository.removeEpisode(params ?? '');
    notifyListeners(Future.value(Success(true, Status.ok)));
  }
}
