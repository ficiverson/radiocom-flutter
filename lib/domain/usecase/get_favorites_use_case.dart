import 'package:cuacfm/domain/invoker/base_use_case.dart';
import 'package:cuacfm/domain/repository/favorites_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';

class GetFavoritesUseCase extends BaseUseCase<void, List> {
  final FavoritesRepositoryContract repository;

  GetFavoritesUseCase({required this.repository});

  @override
  void invoke() {
    notifyListeners(Future.value(Success(repository.getFavorites(), Status.ok)));
  }
}
