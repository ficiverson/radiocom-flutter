import 'package:cuacfm/data/datasource/favorites_local_datasource_contract.dart';
import 'package:cuacfm/data/datasource/wrapped_local_datasource_contract.dart';
import 'package:cuacfm/domain/repository/favorites_repository_contract.dart';

class FavoritesRepository implements FavoritesRepositoryContract {
  final FavoritesLocalDataSourceContract _localDataSource;
  final WrappedLocalDataSourceContract _wrappedDataSource;

  FavoritesRepository({
    required FavoritesLocalDataSourceContract localDataSource,
    required WrappedLocalDataSourceContract wrappedDataSource,
  })  : _localDataSource = localDataSource,
        _wrappedDataSource = wrappedDataSource;

  @override
  void addProgram(Map program) {
    _localDataSource.addProgram(program);
    _wrappedDataSource.recordFavoriteChange(program['name'] ?? '', true);
  }

  @override
  void removeProgram(String rssUrl) {
    final favorites = _localDataSource.getFavorites();
    final program = favorites.firstWhere(
      (p) => p['rssUrl'] == rssUrl,
      orElse: () => null,
    );
    _localDataSource.removeProgram(rssUrl);
    if (program != null) {
      _wrappedDataSource.recordFavoriteChange(program['name'] ?? '', false);
    }
  }

  @override
  List getFavorites() => _localDataSource.getFavorites();

  @override
  bool isFavorite(String rssUrl) => _localDataSource.isFavorite(rssUrl);
}
