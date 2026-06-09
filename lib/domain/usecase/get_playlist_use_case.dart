import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class GetPlaylistUseCase extends BaseUseCase<void, List<Map<String, dynamic>>> {
  final PlaylistRepositoryContract repository;

  GetPlaylistUseCase({required this.repository});

  @override
  void invoke() {
    notifyListeners(Future.value(Success(repository.getRawItems(), Status.ok)));
  }
}
