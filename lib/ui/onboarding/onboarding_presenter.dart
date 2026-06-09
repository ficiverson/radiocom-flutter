import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/usecase/add_favorite_use_case.dart';
import 'package:cuacfm/domain/usecase/add_to_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/remove_favorite_use_case.dart';
import 'package:cuacfm/domain/usecase/remove_from_playlist_use_case.dart';
import 'package:cuacfm/models/episode.dart';

abstract class OnboardingView {}

class OnboardingPresenter {
  final Invoker invoker;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;
  final AddToPlaylistUseCase addToPlaylistUseCase;
  final RemoveFromPlaylistUseCase removeFromPlaylistUseCase;

  OnboardingPresenter({
    required this.invoker,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
    required this.addToPlaylistUseCase,
    required this.removeFromPlaylistUseCase,
  });

  void addFavorite(Map program) {
    invoker.execute(addFavoriteUseCase.withParams(program)).listen((_) {});
  }

  void removeFavorite(String rssUrl) {
    invoker.execute(removeFavoriteUseCase.withParams(rssUrl)).listen((_) {});
  }

  void addToPlaylist(Episode episode, String programName, String logoUrl) {
    invoker
        .execute(addToPlaylistUseCase
            .withParams(AddToPlaylistParams(episode, programName, logoUrl)))
        .listen((_) {});
  }

  void removeFromPlaylist(String audioUrl) {
    invoker.execute(removeFromPlaylistUseCase.withParams(audioUrl)).listen((_) {});
  }
}
