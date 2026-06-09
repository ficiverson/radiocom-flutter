import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class ClearPlaylistUseCase extends BaseUseCase<void, bool> {
  final PlaylistRepositoryContract repository;

  ClearPlaylistUseCase({required this.repository});

  @override
  void invoke() {
    repository.clearAll();
    notifyListeners(Future.value(Success(true, Status.ok)));
  }
}
