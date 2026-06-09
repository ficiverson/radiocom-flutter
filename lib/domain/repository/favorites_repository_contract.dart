abstract class FavoritesRepositoryContract {
  void addProgram(Map program);
  void removeProgram(String rssUrl);
  List getFavorites();
  bool isFavorite(String rssUrl);
}
