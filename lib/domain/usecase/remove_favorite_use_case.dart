import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/favorites_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class RemoveFavoriteUseCase extends BaseUseCase<String, bool> {
  final FavoritesRepositoryContract repository;

  RemoveFavoriteUseCase({required this.repository});

  @override
  void invoke() {
    repository.removeProgram(params ?? '');
    notifyListeners(Future.value(Success(true, Status.ok)));
  }
}
