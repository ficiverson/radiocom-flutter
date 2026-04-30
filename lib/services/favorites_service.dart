import 'package:hive/hive.dart';

class FavoritesService {

  final Box box = Hive.box('favourites');

  void addProgram(Map program) {
    box.put(program['rssUrl'], program);
  }

  void removeProgram(String rssUrl) {
    box.delete(rssUrl);
  }

  List getFavorites() {
    return box.values.toList();
  }

  bool isFavorite(String rssUrl) {
    return box.containsKey(rssUrl);
  }
}
