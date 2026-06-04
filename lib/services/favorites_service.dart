import 'package:cuacfm/services/wrapped_service.dart';
import 'package:hive/hive.dart';

class FavoritesService {

  final Box box = Hive.box('favourites');

  void addProgram(Map program) {
    box.put(program['rssUrl'], program);
    WrappedService().recordFavoriteChange(program['name'] ?? '', true);
  }

  void removeProgram(String rssUrl) {
    final program = box.get(rssUrl);
    box.delete(rssUrl);
    if (program != null) {
      WrappedService().recordFavoriteChange(program['name'] ?? '', false);
    }
  }

  List getFavorites() {
    return box.values.toList();
  }

  bool isFavorite(String rssUrl) {
    return box.containsKey(rssUrl);
  }
}
