import 'package:cuacfm/data/datasource/playlist_local_datasource_contract.dart';
import 'package:cuacfm/domain/repository/playlist_repository_contract.dart';
import 'package:cuacfm/models/episode.dart';

class PlaylistRepository implements PlaylistRepositoryContract {
  final PlaylistLocalDataSourceContract _localDataSource;

  PlaylistRepository({required PlaylistLocalDataSourceContract localDataSource})
      : _localDataSource = localDataSource;

  @override
  void addEpisode(Episode episode, String programName, String logoUrl) =>
      _localDataSource.addEpisode(episode, programName, logoUrl);

  @override
  void addEpisodeAtStart(Episode episode, String programName, String logoUrl) =>
      _localDataSource.addEpisodeAtStart(episode, programName, logoUrl);

  @override
  void removeEpisode(String audioUrl) => _localDataSource.removeEpisode(audioUrl);

  @override
  void clearAll() => _localDataSource.clearAll();

  @override
  bool isInPlaylist(String audioUrl) => _localDataSource.isInPlaylist(audioUrl);

  @override
  List<Map<String, dynamic>> getRawItems() => _localDataSource.getRawItems();

  @override
  List<Episode> getEpisodes() => _localDataSource.getEpisodes();

  @override
  String programNameForAudio(String audioUrl) =>
      _localDataSource.programNameForAudio(audioUrl);

  @override
  String logoUrlForAudio(String audioUrl) =>
      _localDataSource.logoUrlForAudio(audioUrl);

  @override
  void reorderFromList(List<Map<String, dynamic>> items) =>
      _localDataSource.reorderFromList(items);
}
