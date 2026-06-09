import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:flutter/foundation.dart';
import 'package:cuacfm/domain/usecase/add_to_playlist_start_use_case.dart';
import 'package:cuacfm/domain/usecase/add_to_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/clear_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/domain/usecase/get_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/is_in_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/remove_from_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/reorder_playlist_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/ui/player/current_timer.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:injector/injector.dart';
import 'package:share_plus/share_plus.dart';

abstract class PodcastControlsView {
  onNewData();
  setupInitialRate(int index);
}

class PodcastControlsPresenter {
  PodcastControlsView _view;
  Invoker invoker;
  late CurrentTimerContract currentTimer;
  late CurrentPlayerContract currentPlayer;
  late ConnectionContract connection;
  late GetPlaylistUseCase _getPlaylistUseCase;
  late ClearPlaylistUseCase _clearPlaylistUseCase;
  late RemoveFromPlaylistUseCase _removeFromPlaylistUseCase;
  late ReorderPlaylistUseCase _reorderPlaylistUseCase;
  late IsInPlaylistUseCase _isInPlaylistUseCase;
  late AddToPlaylistStartUseCase _addToPlaylistStartUseCase;
  GetLiveProgramUseCase getLiveDataUseCase;

  List<Map<String, dynamic>> _playlist = [];
  List<Map<String, dynamic>> get playlist => List.from(_playlist);

  PodcastControlsPresenter(
    this._view, {
    required this.invoker,
    required this.getLiveDataUseCase,
  }) {
    currentTimer = Injector.appInstance.get<CurrentTimerContract>();
    connection = Injector.appInstance.get<ConnectionContract>();
    currentPlayer = Injector.appInstance.get<CurrentPlayerContract>();
    _getPlaylistUseCase = Injector.appInstance.get<GetPlaylistUseCase>();
    _clearPlaylistUseCase = Injector.appInstance.get<ClearPlaylistUseCase>();
    _removeFromPlaylistUseCase = Injector.appInstance.get<RemoveFromPlaylistUseCase>();
    _reorderPlaylistUseCase = Injector.appInstance.get<ReorderPlaylistUseCase>();
    _isInPlaylistUseCase = Injector.appInstance.get<IsInPlaylistUseCase>();
    _addToPlaylistStartUseCase = Injector.appInstance.get<AddToPlaylistStartUseCase>();
    _view.setupInitialRate(_getRateIndex(currentPlayer.getPlaybackRate()));
  }

  void loadPlaylist(VoidCallback onLoaded) {
    invoker.execute(_getPlaylistUseCase).listen((result) {
      if (result is Success) {
        _playlist = List<Map<String, dynamic>>.from(result.data ?? []);
        onLoaded();
      }
    });
  }

  void clearPlaylist(VoidCallback onDone) {
    invoker.execute(_clearPlaylistUseCase).listen((_) {
      _playlist.clear();
      onDone();
    });
  }

  void removeFromPlaylist(String audioUrl, VoidCallback onDone) {
    invoker.execute(_removeFromPlaylistUseCase.withParams(audioUrl)).listen((_) {
      _playlist.removeWhere((m) => m['audio'] == audioUrl);
      onDone();
    });
  }

  void reorderPlaylist(List<Map<String, dynamic>> items, VoidCallback onDone) {
    invoker.execute(_reorderPlaylistUseCase.withParams(items)).listen((_) {
      _playlist = List<Map<String, dynamic>>.from(items);
      onDone();
    });
  }

  bool isInPlaylist(String audioUrl) =>
      _playlist.any((m) => m['audio'] == audioUrl);

  void addEpisodeAtStartOfPlaylist(Episode episode, String song, String image, VoidCallback onDone) {
    invoker.execute(_addToPlaylistStartUseCase.withParams(AddToPlaylistParams(episode, song, image))).listen((_) {
      loadPlaylist(onDone);
    });
  }

  onViewResumed() async {
    if (await connection.isConnectionAvailable()) {
      getLiveProgram();
    }
  }

  onTimerStart(Duration minutes, int index) {
    if (currentPlayer.isPlaying()) {
      if (currentTimer.isTimerRunning()) {
        currentTimer.stopTimer();
      }
      currentTimer.currentTime = index;
      currentTimer.startTimer(minutes);
    }
  }

  onSpeedSelected(double speed) {
    if (currentPlayer.isPlaying()) {
      currentPlayer.setPlaybackRate(speed);
    }
  }

  getLiveProgram() {
    invoker.execute(getLiveDataUseCase).listen((result) {
      if (result is Success) {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = result.data;
          currentPlayer.currentSong = result.data.name;
          currentPlayer.currentImage = result.data.logoUrl;
          _view.onNewData();
        }
      } else {
        if (!currentPlayer.isPodcast) {
          currentPlayer.now = Now.mock();
          currentPlayer.currentSong = Now.mock().name;
          currentPlayer.currentImage = Now.mock().logoUrl;
          _view.onNewData();
        }
      }
    });
  }

  onShareClicked() async {
    final localization = Injector.appInstance.get<CuacLocalization>();
    final imageUrl = currentPlayer.currentImage;
    String text;
    if (currentPlayer.isPodcast) {
      final ep = currentPlayer.episode;
      final template = SafeMap.safe(localization.translateMap("actions"), ["share_episode"]);
      text = template
          .replaceFirst("%s", currentPlayer.currentSong)
          .replaceFirst("%s", ep?.title ?? "") + (ep?.link ?? "https://cuacfm.org");
    } else {
      final template = SafeMap.safe(localization.translateMap("actions"), ["share_program"]);
      text = template.replaceFirst("%s", currentPlayer.currentSong) + "https://cuacfm.org";
    }
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/share_image.jpg');
      await file.writeAsBytes(response.bodyBytes);
      await Share.shareXFiles([XFile(file.path)], text: text);
    } catch (_) {
      Share.share(text);
    }
  }

  onPlayPause() async {
    if (currentPlayer.isPlaying()) {
      await currentPlayer.pause();
    } else if (currentPlayer.playerState == AudioPlayerState.stop) {
      await currentPlayer.play();
    } else {
      await currentPlayer.resume();
    }
    _view.onNewData();
  }

  onSeek(int timeSeek) async {
    if (currentPlayer.isPodcast) {
      await currentPlayer.seek(
        Duration(seconds: currentPlayer.position.inSeconds + timeSeek),
      );
      _view.onNewData();
    }
  }

  int _getRateIndex(double speed) {
    int index = 1;
    if (speed == 0.8) {
      index = 0;
    } else if (speed == 1.0) {
      index = 1;
    } else if (speed == 1.2) {
      index = 2;
    } else if (speed == 1.5) {
      index = 3;
    } else if (speed == 2.0) {
      index = 4;
    }
    return index;
  }
}
