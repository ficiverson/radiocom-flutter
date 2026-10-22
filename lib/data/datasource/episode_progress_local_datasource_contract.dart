abstract class EpisodeProgressLocalDataSourceContract {
  void save(String episodeId, int positionSeconds, int durationSeconds,
      {String? title, String? programName, String? logoUrl});
  void markCompleted(String episodeId, int durationSeconds);
  Map<String, dynamic>? getProgress(String episodeId);
  Map<String, Map<String, dynamic>> getAll();
}
