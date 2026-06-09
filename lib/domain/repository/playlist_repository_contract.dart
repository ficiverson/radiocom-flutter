import 'package:cuacfm/models/episode.dart';

abstract class PlaylistRepositoryContract {
  void addEpisode(Episode episode, String programName, String logoUrl);
  void addEpisodeAtStart(Episode episode, String programName, String logoUrl);
  void removeEpisode(String audioUrl);
  void clearAll();
  bool isInPlaylist(String audioUrl);
  List<Map<String, dynamic>> getRawItems();
  List<Episode> getEpisodes();
  String programNameForAudio(String audioUrl);
  String logoUrlForAudio(String audioUrl);
  void reorderFromList(List<Map<String, dynamic>> items);
}
