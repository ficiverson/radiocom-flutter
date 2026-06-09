import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/favorites_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class AddFavoriteUseCase extends BaseUseCase<Map, bool> {
  final FavoritesRepositoryContract repository;

  AddFavoriteUseCase({required this.repository});

  @override
  void invoke() {
    repository.addProgram(params ?? {});
    notifyListeners(Future.value(Success(true, Status.ok)));
  }
}
