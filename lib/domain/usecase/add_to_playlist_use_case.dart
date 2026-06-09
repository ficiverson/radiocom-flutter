import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/models/episode.dart';

class AddToPlaylistParams {
  final Episode episode;
  final String programName;
  final String logoUrl;

  AddToPlaylistParams(this.episode, this.programName, this.logoUrl);
}

class AddToPlaylistUseCase extends BaseUseCase<AddToPlaylistParams, bool> {
  final PlaylistRepositoryContract repository;

  AddToPlaylistUseCase({required this.repository});

  @override
  void invoke() {
    final p = params;
    if (p != null) {
      repository.addEpisode(p.episode, p.programName, p.logoUrl);
    }
    notifyListeners(Future.value(Success(true, Status.ok)));
  }
}
