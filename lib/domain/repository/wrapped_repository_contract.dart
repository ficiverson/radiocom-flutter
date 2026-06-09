abstract class WrappedRepositoryContract {
  void startSession({
    required bool isPodcast,
    String programName,
    String category,
    String episodeTitle,
    String episodeId,
  });
  void endSession();
  void recordFavoriteChange(String programName, bool added);
  List<Map<String, dynamic>> getSessions();
}
