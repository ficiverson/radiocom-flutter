import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class ReorderPlaylistUseCase extends BaseUseCase<List<Map<String, dynamic>>, bool> {
  final PlaylistRepositoryContract repository;

  ReorderPlaylistUseCase({required this.repository});

  @override
  void invoke() {
    repository.reorderFromList(params ?? []);
    notifyListeners(Future.value(Success(true, Status.ok)));
  }
}
