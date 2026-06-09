abstract class FavoritesLocalDataSourceContract {
  void addProgram(Map program);
  void removeProgram(String rssUrl);
  List getFavorites();
  bool isFavorite(String rssUrl);
}
