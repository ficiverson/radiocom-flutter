import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/add_favorite_use_case.dart';
import 'package:cuacfm/domain/usecase/add_to_playlist_start_use_case.dart';
import 'package:cuacfm/domain/usecase/add_to_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/get_episodes_use_case.dart';
import 'package:cuacfm/domain/usecase/get_live_program_use_case.dart';
import 'package:cuacfm/domain/usecase/is_favorite_use_case.dart';
import 'package:cuacfm/domain/usecase/is_in_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/remove_favorite_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/new.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/ui/home/home_presenter.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:cuacfm/translations/localizations.dart';
import 'package:cuacfm/utils/connection_contract.dart';
import 'package:cuacfm/utils/safe_map.dart';
import 'package:injector/injector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import 'detail_podcast_router.dart';

abstract class DetailPodcastView {
  void onLoadEpidoses(List<Episode> episodes);
  onErrorLoadingEpisodes(String err);
  onNewData();
  onPlayerData(StatusPlayer statusPlayer);
  onConnectionError();
}

class DetailPodcastPresenter {
  DetailPodcastView _view;
  Invoker invoker;
  DetailPodcastRouter router;
  GetLiveProgramUseCase getLiveDataUseCase;
  late ConnectionContract connection;
  late CurrentPlayerContract currentPlayer;
  late IsFavoriteUseCase _isFavoriteUseCase;
  late AddFavoriteUseCase _addFavoriteUseCase;
  late RemoveFavoriteUseCase _removeFavoriteUseCase;
  late IsInPlaylistUseCase _isInPlaylistUseCase;
  late AddToPlaylistStartUseCase _addToPlaylistStartUseCase;
  late AddToPlaylistUseCase _addToPlaylistUseCase;
  GetEpisodesUseCase getEpisodesUseCase;
  bool isLoading = false;
  Timer? _timer;

  DetailPodcastPresenter(
    this._view, {
    required this.invoker,
    required this.router,
    required this.getEpisodesUseCase,
    required this.getLiveDataUseCase,
  }) {
    connection = Injector.appInstance.get<ConnectionContract>();
    currentPlayer = Injector.appInstance.get<CurrentPlayerContract>();
    _isFavoriteUseCase = Injector.appInstance.get<IsFavoriteUseCase>();
    _addFavoriteUseCase = Injector.appInstance.get<AddFavoriteUseCase>();
    _removeFavoriteUseCase = Injector.appInstance.get<RemoveFavoriteUseCase>();
    _isInPlaylistUseCase = Injector.appInstance.get<IsInPlaylistUseCase>();
    _addToPlaylistStartUseCase = Injector.appInstance.get<AddToPlaylistStartUseCase>();
    _addToPlaylistUseCase = Injector.appInstance.get<AddToPlaylistUseCase>();
  }

  void checkIsFavorite(String rssUrl, Function(bool) callback) {
    invoker.execute(_isFavoriteUseCase.withParams(rssUrl)).listen((result) {
      if (result is Success) callback(result.data ?? false);
    });
  }

  void addFavorite(Map program) {
    invoker.execute(_addFavoriteUseCase.withParams(program)).listen((_) {});
  }

  void removeFavorite(String rssUrl) {
    invoker.execute(_removeFavoriteUseCase.withParams(rssUrl)).listen((_) {});
  }

  onViewResumed() async {
    if (await connection.isConnectionAvailable()) {
      getLiveProgram();
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

  loadEpisodes(String feedProgram) async {
    invoker
        .execute(
      getEpisodesUseCase.withParams(GetEpisodesUseCaseParams(feedProgram)),
    )
        .listen((result) {
      if (result is Success) {
        _view.onLoadEpidoses(result.data);
      } else {
        _view.onErrorLoadingEpisodes((result as Error).status.toString());
      }
    });
  }

  bool isSamePodcast(Episode episode) {
    var uuid = Uuid();
    return currentPlayer.episode != null &&
        uuid.v5(Namespace.url.value, episode.audio) ==
            uuid.v5(
              Namespace.url.value,
              currentPlayer.episode?.audio ?? "no_audio",
            ) &&
        currentPlayer.isPodcast;
  }

  onResume() async {
    if (currentPlayer.playerState == AudioPlayerState.stop) {
      await currentPlayer.play();
    } else {
      await currentPlayer.resume();
    }
  }

  onPause() async {
    await currentPlayer.pause();
  }

  onSelectedEpisode(Episode episode, String image, String programName) async {
    bool isSameEpisode = isSamePodcast(episode);

    void _continueSelection() {
      currentPlayer.isPodcast = true;
      currentPlayer.episode = episode;
      currentPlayer.currentSong = programName;
      currentPlayer.currentImage = image;
      if (currentPlayer.isPlaying()) {
        _onPlayEpisode(episode);
      } else if (isSameEpisode) {
        currentPlayer.resume();
      } else {
        _play();
      }
    }

    if (currentPlayer.isPlaying() &&
        currentPlayer.isPodcast &&
        !isSameEpisode &&
        currentPlayer.episode != null) {
      final current = currentPlayer.episode!;
      final currentName = currentPlayer.currentSong;
      final currentImage = currentPlayer.currentImage;
      invoker.execute(_isInPlaylistUseCase.withParams(current.audio)).listen((result) {
        if (result is Success && !(result.data ?? false)) {
          invoker.execute(_addToPlaylistStartUseCase.withParams(
            AddToPlaylistParams(current, currentName, currentImage))).listen((_) {});
        }
        _continueSelection();
      });
      return;
    }

    _continueSelection();
  }

  onShareClicked(Program podcast) async {
    final localization = Injector.appInstance.get<CuacLocalization>();
    final template = SafeMap.safe(localization.translateMap("actions"), ["share_program"]);
    final webUrl = podcast.rssUrl.replaceAll(RegExp(r'/rss/?$'), '');
    final text = template.replaceFirst("%s", podcast.name) + webUrl;
    try {
      final response = await http.get(Uri.parse(podcast.logoUrl));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/share_image.jpg');
      await file.writeAsBytes(response.bodyBytes);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: text));
    } catch (_) {
      SharePlus.instance.share(ShareParams(text: text));
    }
  }

  onDetailPodcast(String title, String subtitle, String content, String link) {
    router.goToNewDetail(New.fromPodcast(title, subtitle, content, link));
  }

  void addToPlaylistIfNew(Episode episode, String programName, String logoUrl, Function(bool added) callback) {
    invoker.execute(_isInPlaylistUseCase.withParams(episode.audio)).listen((result) {
      if (result is Success && (result.data ?? false)) {
        callback(false);
      } else {
        invoker.execute(_addToPlaylistUseCase.withParams(
            AddToPlaylistParams(episode, programName, logoUrl))).listen((_) {
          callback(true);
        });
      }
    });
  }

  onDetailEpisode(Episode episode, String programName, String logoUrl, {Program? program}) {
    router.goToEpisodeDetail(episode, programName, logoUrl, program: program);
  }

  onPodcastControlsClicked(Episode? episode) {
    if (episode != null) {
      router.goToPodcastControls(episode);
    }
  }

  //private methods

  _onPlayEpisode(Episode episode) {
    if (currentPlayer.isPlaying()) {
      _stopAndPlay();
    } else {
      _play();
    }
  }

  _play() async {
    isLoading = true;
    var success = await currentPlayer.play();
    bool isConnectionAvailable = await connection.isConnectionAvailable();
    if (!isConnectionAvailable || !success) {
      currentPlayer.stop();
      isLoading = false;
      _view.onPlayerData(StatusPlayer.FAILED);
    } else {
      if (_timer != null) {
        _timer?.cancel();
      }
      _timer = new Timer.periodic(new Duration(milliseconds: 100), (timer) {
        if (currentPlayer.isStreamingAudio()) {
          isLoading = false;
          _view.onPlayerData(StatusPlayer.PLAYING);
          _timer?.cancel();
          _timer = null;
        } else if (timer.tick > 500) {
          currentPlayer.stop();
          isLoading = false;
          _view.onPlayerData(StatusPlayer.FAILED);
          _timer?.cancel();
          _timer = null;
        }
      });
    }
  }

  _stopAndPlay() async {
    isLoading = true;
    var success = await currentPlayer.stopAndPlay();
    bool isConnectionAvailable = await connection.isConnectionAvailable();
    if (!isConnectionAvailable || !success) {
      currentPlayer.stop();
      isLoading = false;
      _view.onPlayerData(StatusPlayer.FAILED);
    } else {
      if (_timer != null) {
        _timer?.cancel();
      }
      _timer = new Timer.periodic(new Duration(milliseconds: 100), (timer) {
        if (currentPlayer.isStreamingAudio()) {
          isLoading = false;
          _view.onPlayerData(StatusPlayer.PLAYING);
          _timer?.cancel();
          _timer = null;
        } else if (timer.tick > 500) {
          currentPlayer.stop();
          isLoading = false;
          _view.onPlayerData(StatusPlayer.FAILED);
          _timer?.cancel();
          _timer = null;
        }
      });
    }
  }
}
