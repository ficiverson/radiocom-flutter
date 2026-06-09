import 'package:cuacfm/data/datasource/favorites_local_datasource_contract.dart';
import 'package:hive/hive.dart';

class FavoritesLocalDataSource implements FavoritesLocalDataSourceContract {
  final Box _box = Hive.box('favourites');

  @override
  void addProgram(Map program) {
    _box.put(program['rssUrl'], program);
  }

  @override
  void removeProgram(String rssUrl) {
    _box.delete(rssUrl);
  }

  @override
  List getFavorites() {
    return _box.values.toList();
  }

  @override
  bool isFavorite(String rssUrl) {
    return _box.containsKey(rssUrl);
  }
}
