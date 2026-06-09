import 'package:cuacfm/data/datasource/wrapped_local_datasource_contract.dart';
import 'package:cuacfm/domain/repository/wrapped_repository_contract.dart';

class WrappedRepository implements WrappedRepositoryContract {
  final WrappedLocalDataSourceContract _localDataSource;

  WrappedRepository({required WrappedLocalDataSourceContract localDataSource})
      : _localDataSource = localDataSource;

  @override
  void startSession({
    required bool isPodcast,
    String programName = '',
    String category = '',
    String episodeTitle = '',
    String episodeId = '',
  }) =>
      _localDataSource.startSession(
        isPodcast: isPodcast,
        programName: programName,
        category: category,
        episodeTitle: episodeTitle,
        episodeId: episodeId,
      );

  @override
  void endSession() => _localDataSource.endSession();

  @override
  void recordFavoriteChange(String programName, bool added) =>
      _localDataSource.recordFavoriteChange(programName, added);

  @override
  List<Map<String, dynamic>> getSessions() => _localDataSource.getSessions();
}
