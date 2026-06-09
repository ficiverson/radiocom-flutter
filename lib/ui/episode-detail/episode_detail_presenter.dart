import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/add_to_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/is_in_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/remove_from_playlist_use_case.dart';
import 'package:cuacfm/models/episode.dart';

abstract class EpisodeDetailView {
  void onPlaylistStatusChanged(bool inPlaylist);
}

class EpisodeDetailPresenter {
  final EpisodeDetailView _view;
  final Invoker invoker;
  final IsInPlaylistUseCase isInPlaylistUseCase;
  final AddToPlaylistUseCase addToPlaylistUseCase;
  final RemoveFromPlaylistUseCase removeFromPlaylistUseCase;

  EpisodeDetailPresenter(
    this._view, {
    required this.invoker,
    required this.isInPlaylistUseCase,
    required this.addToPlaylistUseCase,
    required this.removeFromPlaylistUseCase,
  });

  void checkPlaylistStatus(String audioUrl) {
    invoker.execute(isInPlaylistUseCase.withParams(audioUrl)).listen((result) {
      if (result is Success) {
        _view.onPlaylistStatusChanged(result.data ?? false);
      }
    });
  }

  void addToPlaylist(Episode episode, String programName, String logoUrl) {
    invoker
        .execute(addToPlaylistUseCase.withParams(
            AddToPlaylistParams(episode, programName, logoUrl)))
        .listen((_) {
      _view.onPlaylistStatusChanged(true);
    });
  }

  void removeFromPlaylist(String audioUrl) {
    invoker
        .execute(removeFromPlaylistUseCase.withParams(audioUrl))
        .listen((_) {
      _view.onPlaylistStatusChanged(false);
    });
  }

  void togglePlaylist(Episode episode, String programName, String logoUrl, bool currentlyInPlaylist) {
    if (currentlyInPlaylist) {
      removeFromPlaylist(episode.audio);
    } else {
      addToPlaylist(episode, programName, logoUrl);
    }
  }
}
