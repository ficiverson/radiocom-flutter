import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/add_to_playlist_use_case.dart';

class AddToPlaylistStartUseCase extends BaseUseCase<AddToPlaylistParams, bool> {
  final PlaylistRepositoryContract repository;

  AddToPlaylistStartUseCase({required this.repository});

  @override
  void invoke() {
    final p = params;
    if (p != null) {
      repository.addEpisodeAtStart(p.episode, p.programName, p.logoUrl);
    }
    notifyListeners(Future.value(Success(true, Status.ok)));
  }
}
