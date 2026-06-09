import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class IsInPlaylistUseCase extends BaseUseCase<String, bool> {
  final PlaylistRepositoryContract repository;

  IsInPlaylistUseCase({required this.repository});

  @override
  void invoke() {
    final result = repository.isInPlaylist(params ?? '');
    notifyListeners(Future.value(Success(result, Status.ok)));
  }
}
