import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/end_session_use_case.dart';
import 'package:cuacfm/domain/usecase/get_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/remove_from_playlist_use_case.dart';
import 'package:cuacfm/domain/usecase/start_session_use_case.dart';
import 'package:cuacfm/data/datasource/episode_progress_local_datasource_contract.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cuacfm/ui/player/cuac_audio_handler.dart';
import 'package:injector/injector.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

typedef void ConnectionCallback(bool isError);

enum AudioPlayerState { play, stop, pause }

abstract class CurrentPlayerContract {
  Now? now;
  Episode? episode;
  Episode? tempEpisode;
  AudioPlayerState playerState = AudioPlayerState.stop;
  AudioPlayer audioPlayer = Injector.appInstance.get<AudioPlayer>();
  String currentSong = ":";
  String currentSubtitle = "";
  String currentImage =
      "https://cuacfm.org/wp-content/uploads/2026/04/cuac_music_cover.png";
  bool isPodcast = false;
  String playbackSource = 'app';
  Duration duration = Duration(seconds: 0);
  Duration position = Duration(seconds: 0);
  Duration restoreDuration = Duration(seconds: 0);
  Duration restorePosition = Duration(seconds: 0);
  double volume = 1.0;
  double playbackRate = 1.0;
  VoidCallback? onUpdate;
  ConnectionCallback? onConnection;
  ConnectionCallback? podcastConnectivityResult;
  ConnectivityResult? connectivityResult;

  void restorePlayer(ConnectivityResult connection);
  Future<bool> seek(Duration position);
  Future<bool> setVolume(double volume);
  Future<bool> play();
  Future<bool> stopAndPlay();
  void stop();
  Future resume();
  Future pause();
  bool isPlaying();
  bool isStreamingAudio();
  bool isPaused();
  void release();
  double getPlaybackRate();
  void setPlaybackRate(double playbackRate);
}

class CurrentPlayer implements CurrentPlayerContract {
  @override
  Now? now;
  @override
  Episode? episode;
  @override
  Episode? tempEpisode;
  @override
  AudioPlayerState playerState = AudioPlayerState.stop;
  @override
  AudioPlayer audioPlayer = Injector.appInstance.get<AudioPlayer>();
  String _currentSong = ":";
  @override
  String get currentSong => _currentSong;
  @override
  set currentSong(String value) {
    if (_currentSong == value) return;
    _currentSong = value;
    _refreshNotificationMetadata();
  }

  @override
  String currentSubtitle = "";

  String _currentImage =
      "https://cuacfm.org/wp-content/uploads/2026/04/cuac_music_cover.png";
  @override
  String get currentImage => _currentImage;
  @override
  set currentImage(String value) {
    if (_currentImage == value) return;
    _currentImage = value;
    _refreshNotificationMetadata();
  }

  static const _fallbackArtUrl = "https://cuacfm.org/wp-content/uploads/2026/04/cuac_music_cover.png";
  static const _defaultProgrammeArtUrl = "https://cuacfm.org/wp-content/uploads/2026/06/default_programme_cover.png";
  Uri get _artUri {
    final img = currentImage;
    if (img.contains('cuac_music_cover')) {
      return Uri.parse(_fallbackArtUrl);
    }
    if (img.startsWith('assets/') || img.contains('default-programme-photo') || img.isEmpty) {
      return Uri.parse(_defaultProgrammeArtUrl);
    }
    return Uri.parse(img);
  }

  CuacAudioHandler? get _handler {
    try {
      return Injector.appInstance.get<CuacAudioHandler>();
    } catch (_) {
      return null;
    }
  }

  MediaItem _buildMediaItem() {
    final name = currentSong.trim();
    final hasName = name.isNotEmpty && name != ":";
    return MediaItem(
      id: urlToHashId(isPodcast ? episode?.audio ?? "" : now?.streamUrl() ?? ""),
      album: isPodcast ? "Podcast CUAC FM" : "Directo CUAC FM",
      title: isPodcast
          ? episode?.title ?? ""
          : (hasName ? name : "Streaming en directo"),
      artist: isPodcast && hasName ? name : "CUAC FM",
      artUri: _artUri,
    );
  }

  final Map<String, Uri> _squareArtCache = {};
  int _artToken = 0;

  void _publishNowPlaying() {
    final item = _buildMediaItem();
    final src = item.artUri;
    final cached = src == null ? null : _squareArtCache[src.toString()];
    _handler?.setNowPlaying(
        cached != null ? item.copyWith(artUri: cached) : item,
        isLive: !isPodcast);
    final token = ++_artToken;
    if (src != null && cached == null) {
      _squareArt(src).then((square) {
        if (square != null && square != src && token == _artToken) {
          _handler?.setNowPlaying(item.copyWith(artUri: square),
              isLive: !isPodcast);
        }
      });
    }
  }

  Future<Uri?> _squareArt(Uri src) async {
    final key = src.toString();
    if (_squareArtCache.containsKey(key)) return _squareArtCache[key];
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/art2_${md5.convert(utf8.encode(key)).toString()}.png');
      if (await file.exists()) {
        final uri = Uri.file(file.path);
        _squareArtCache[key] = uri;
        return uri;
      }
      final response = await http.get(src);
      if (response.statusCode != 200) return null;
      final codec = await ui.instantiateImageCodec(response.bodyBytes);
      final image = (await codec.getNextFrame()).image;
      final minSide = math.min(image.width, image.height);
      final maxSide = math.max(image.width, image.height);
      if (minSide / maxSide >= 0.9) {
        _squareArtCache[key] = src;
        return src;
      }
      final side = minSide;
      final dx = ((image.width - side) / 2).toDouble();
      final dy = ((image.height - side) / 2).toDouble();
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawImageRect(
        image,
        ui.Rect.fromLTWH(dx, dy, side.toDouble(), side.toDouble()),
        ui.Rect.fromLTWH(0, 0, side.toDouble(), side.toDouble()),
        ui.Paint(),
      );
      final out = await recorder.endRecording().toImage(side, side);
      final data = await out.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) return null;
      await file.writeAsBytes(data.buffer.asUint8List());
      final uri = Uri.file(file.path);
      _squareArtCache[key] = uri;
      return uri;
    } catch (_) {
      return null;
    }
  }

  void _startWrappedSession() {
    Injector.appInstance.get<Invoker>().execute(
        Injector.appInstance.get<StartSessionUseCase>().withParams(
            StartSessionParams(
              isPodcast: isPodcast,
              programName: isPodcast ? (currentSong.isNotEmpty ? currentSong : episode?.title ?? '') : '',
              category: '',
              episodeTitle: isPodcast ? episode?.title ?? '' : '',
              episodeId: isPodcast ? episode?.audio ?? '' : '',
            ))).drain();
  }

  void _endWrappedSession() {
    Injector.appInstance.get<Invoker>()
        .execute(Injector.appInstance.get<EndSessionUseCase>())
        .drain();
  }

  int _lastProgressSaveSec = -10;

  EpisodeProgressLocalDataSourceContract? get _progressStore {
    try {
      return Injector.appInstance
          .get<EpisodeProgressLocalDataSourceContract>();
    } catch (_) {
      return null;
    }
  }

  void _saveProgress() {
    if (!isPodcast) return;
    final id = episode?.audio ?? '';
    if (id.isEmpty || duration.inSeconds <= 0) return;
    _progressStore?.save(id, position.inSeconds, duration.inSeconds,
        title: episode?.title, programName: currentSong, logoUrl: currentImage);
    _lastProgressSaveSec = position.inSeconds;
  }

  Duration? _savedResumePosition() {
    if (!isPodcast) return null;
    final saved = _progressStore?.getProgress(episode?.audio ?? '');
    if (saved == null || saved['completed'] == true) return null;
    final pos = (saved['position'] as num?)?.toInt() ?? 0;
    final dur = (saved['duration'] as num?)?.toInt() ?? 0;
    if (pos > 5 && (dur <= 0 || pos < dur - 5)) {
      if (dur > 0) duration = Duration(seconds: dur);
      position = Duration(seconds: pos);
      _lastProgressSaveSec = pos;
      return Duration(seconds: pos);
    }
    return null;
  }

  void _logPlay() {
    if (_suppressLiveLog) return;
    if (isPodcast) {
      final program = currentSong.trim();
      FirebaseAnalytics.instance.logEvent(
        name: 'podcast_play',
        parameters: {
          'program': program.isNotEmpty && program != ':'
              ? program
              : (episode?.title ?? ''),
          'episode': episode?.title ?? '',
          'source': playbackSource,
        },
      );
    } else {
      final live = currentSong.trim();
      FirebaseAnalytics.instance.logEvent(
        name: 'live_play',
        parameters: {
          'program': live.isNotEmpty && live != ':' ? live : 'Continuidade CUAC FM',
          'source': playbackSource,
        },
      );
    }
  }

  void _refreshNotificationMetadata() {
    if (playerState == AudioPlayerState.stop) return;
    _publishNowPlaying();
  }

  @override
  bool isPodcast = false;
  @override
  String playbackSource = 'app';
  @override
  Duration duration = Duration(seconds: 0);
  @override
  Duration position = Duration(seconds: 0);
  @override
  Duration restoreDuration = Duration(seconds: 0);
  @override
  Duration restorePosition = Duration(seconds: 0);
  @override
  double volume = 1.0;
  @override
  double playbackRate = 1.0;
  @override
  VoidCallback? onUpdate;
  @override
  ConnectionCallback? onConnection;
  @override
  ConnectionCallback? podcastConnectivityResult;
  @override
  ConnectivityResult? connectivityResult;

  // Internal stream subscriptions — cancelled before re-registering
  StreamSubscription? _stateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  bool _pendingLiveRestart = false;
  bool _suppressLiveLog = false;
  int _liveRetryCount = 0;
  Timer? _liveRetryTimer;
  bool _userPaused = false;
  bool _userWantsLive = false;

  @override
  void restorePlayer(ConnectivityResult connection) async {
    if (!isPodcast) {
      if (connection == ConnectivityResult.none) {
        if (isPlaying()) {
          await _stop();
          _pendingLiveRestart = true;
          if (onConnection != null) {
            onConnection!(true);
          }
          if (podcastConnectivityResult != null) {
            podcastConnectivityResult!(true);
          }
        }
      } else if ((isPlaying() && connection != connectivityResult) ||
          _pendingLiveRestart) {
        _pendingLiveRestart = false;
        restorePosition = position;
        restoreDuration = duration;
        tempEpisode = episode;
        await _stop();
        _suppressLiveLog = true;
        await play();
        _suppressLiveLog = false;
        if (onConnection != null) {
          onConnection!(false);
        }
        if (podcastConnectivityResult != null) {
          podcastConnectivityResult!(false);
        }
      }
    }
    connectivityResult = connection;
  }

  @override
  Future<bool> seek(Duration position) async {
    if (playerState == AudioPlayerState.play) {
      if (position <= duration) {
        await audioPlayer.seek(position);
        return true;
      } else {
        await audioPlayer.seek(duration);
        return true;
      }
    } else {
      return false;
    }
  }

  @override
  Future<bool> setVolume(double volume) async {
    if (playerState == AudioPlayerState.play) {
      this.volume = volume;
      await audioPlayer.setVolume(volume);
      return true;
    } else {
      return false;
    }
  }

  Future<void> _playNextInPlaylist() async {
    final invoker = Injector.appInstance.get<Invoker>();
    List<Map<String, dynamic>> items = [];
    await for (final result in invoker.execute(Injector.appInstance.get<GetPlaylistUseCase>())) {
      if (result is Success) items = List<Map<String, dynamic>>.from(result.data ?? []);
    }
    if (items.isEmpty) return;

    final next = items.first;
    invoker.execute(Injector.appInstance.get<RemoveFromPlaylistUseCase>().withParams(next['audio'] as String)).drain();

    final nextEpisode = Episode.fromMap(next);
    isPodcast = true;
    episode = nextEpisode;
    currentSong = next['programName'] ?? nextEpisode.title;
    currentSubtitle = nextEpisode.title;
    currentImage = next['logoUrl'] ?? currentImage;
    playerState = AudioPlayerState.stop;
    position = Duration.zero;
    duration = Duration.zero;

    if (onUpdate != null) onUpdate!();
    await play();
    if (onUpdate != null) onUpdate!();
  }

  @override
  Future<bool> play() async {
    if (playerState != AudioPlayerState.play) {
      _userPaused = false;
      if (!isPodcast) _userWantsLive = true;
      // Cancel previous subscriptions to avoid accumulation
      await _stateSubscription?.cancel();
      await _durationSubscription?.cancel();
      await _positionSubscription?.cancel();

      _stateSubscription = audioPlayer.playerStateStream.listen((event) async {
        if (!isPodcast) {
        }
        if (!isPodcast &&
            event.playing &&
            event.processingState == ProcessingState.ready) {
          _liveRetryCount = 0;
          _liveRetryTimer?.cancel();
        }
        if (isPodcast && event.processingState == ProcessingState.completed) {
          final finishedId = episode?.audio ?? '';
          if (finishedId.isNotEmpty && duration.inSeconds > 0) {
            _progressStore?.markCompleted(finishedId, duration.inSeconds);
          }
          await _stop();
          position = Duration.zero;
          restoreDuration = Duration.zero;
          restorePosition = Duration.zero;
          await _playNextInPlaylist();
          if (onUpdate != null) onUpdate!();
        } else if (event.processingState == ProcessingState.idle) {
          if (!isPodcast) {
            if (_userWantsLive && !_userPaused) {
              _scheduleLiveRetry();
            }
          } else if (playerState != AudioPlayerState.stop) {
            playerState = AudioPlayerState.stop;
            isPodcast = false;
            if (onUpdate != null) onUpdate!();
          }
        } else if (event.playing && playerState == AudioPlayerState.pause) {
          playerState = AudioPlayerState.play;
          if (onUpdate != null) onUpdate!();
          if (onConnection != null) onConnection!(false);
        } else if (!event.playing && playerState == AudioPlayerState.play &&
            event.processingState != ProcessingState.completed) {
          playerState = AudioPlayerState.pause;
          if (onUpdate != null) onUpdate!();
          if (onConnection != null) onConnection!(false);
        }
      }, onError: (Object e, StackTrace s) {
        if (!isPodcast && !_userPaused && _userWantsLive) {
          _scheduleLiveRetry();
        }
      });

      if (isPodcast) {

        _durationSubscription = audioPlayer.durationStream.listen((Duration? d) {
          duration = d ?? Duration(hours: 1);
          if (onUpdate != null && duration > Duration.zero) {
            onUpdate!();
          }
        });
      }
      _positionSubscription = audioPlayer.positionStream.listen((Duration p) {
        if (isPodcast) {
          if (p.inSeconds.ceilToDouble() >= 0.0 &&
              p.inSeconds.ceilToDouble() <= duration.inSeconds.ceilToDouble()) {
            position = p;
            if ((p.inSeconds - _lastProgressSaveSec).abs() >= 5) {
              _saveProgress();
            }
            if (onUpdate != null) {
              onUpdate!();
            }
          }
        } else {
          position = Duration(seconds: 1);
          duration = Duration(hours: 24);
          _liveRetryCount = 0;
        }
      });

      setVolume(1.0);
      if ((isPodcast && episode?.audio != null && episode!.audio.isNotEmpty) ||
          (!isPodcast &&
              now?.streamUrl() != null &&
              now!.streamUrl().isNotEmpty)) {
        if (!isPodcast) {
          playbackRate = 1.0;
          audioPlayer.setSpeed(playbackRate);
        }
        AudioSource audioSource = AudioSource.uri(Uri.parse(isPodcast
            ? episode?.audio ?? RadioStation.base().streamUrl
            : now?.streamUrl() ?? RadioStation.base().streamUrl));
        Duration? resumeAt;
        if (isPodcast) {
          if (restorePosition != Duration(seconds: 0) &&
              restoreDuration != Duration(seconds: 0) &&
              tempEpisode == episode) {
            duration = restoreDuration;
            tempEpisode = null;
            resumeAt = restorePosition;
          } else {
            resumeAt = _savedResumePosition();
          }
          restoreDuration = Duration(seconds: 0);
          restorePosition = Duration(seconds: 0);
        }
        audioPlayer.setAudioSource(audioSource, initialPosition: resumeAt);
        _publishNowPlaying();
        await audioPlayer.play();
        if (resumeAt == null) await audioPlayer.seek(position);
        if (!isPodcast) {
          playerState = AudioPlayerState.play;
          _startWrappedSession();
          _logPlay();
        } else if (audioPlayer.playing) {
          playerState = AudioPlayerState.play;
          _startWrappedSession();
          _logPlay();
        }
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Future<bool> stopAndPlay() async {
    if (playerState == AudioPlayerState.play ||
        playerState == AudioPlayerState.pause) {
      _endWrappedSession();
      _userPaused = false;
      if (!isPodcast) {
        playbackRate = 1.0;
        audioPlayer.setSpeed(playbackRate);
      }
      await audioPlayer.pause();
      if (!audioPlayer.playing) playerState = AudioPlayerState.pause;
      duration = Duration(seconds: 0);
      position = Duration(seconds: 0);
      if (!isPodcast) {
        setVolume(1.0);
      }
      AudioSource audioSource = AudioSource.uri(Uri.parse(isPodcast
          ? episode?.audio ?? RadioStation.base().streamUrl
          : now?.streamUrl() ?? RadioStation.base().streamUrl));
      final resumeAt = isPodcast ? _savedResumePosition() : null;
      audioPlayer.setAudioSource(audioSource, initialPosition: resumeAt);
      _publishNowPlaying();
      await audioPlayer.play();
      if (resumeAt == null) await audioPlayer.seek(position);
      if (audioPlayer.playing) {
        playerState = AudioPlayerState.play;
        _startWrappedSession();
        _logPlay();
      }
      return true;
    } else {
      return false;
    }
  }

  void _scheduleLiveRetry() {
    if (_liveRetryTimer?.isActive ?? false) return;
    if (!_userWantsLive || _userPaused) return;
    _liveRetryCount++;
    final delaySec = (5 * _liveRetryCount).clamp(5, 30);
    _liveRetryTimer = Timer(Duration(seconds: delaySec), () async {
      if (isPodcast || _userPaused || !_userWantsLive) {
        return;
      }
      if (audioPlayer.playing &&
          audioPlayer.processingState == ProcessingState.ready) {
        _liveRetryCount = 0;
        return;
      }
      _suppressLiveLog = true;
      await _stop();
      await play();
      _suppressLiveLog = false;
    });
  }

  @override
  void stop() {
    _pendingLiveRestart = false;
    _userPaused = false;
    _userWantsLive = false;
    _liveRetryTimer?.cancel();
    _liveRetryCount = 0;
    _stop();
  }

  Future<void> _stop() async {
    if (playerState == AudioPlayerState.play ||
        playerState == AudioPlayerState.pause) {
      _saveProgress();
      _endWrappedSession();
      playerState = AudioPlayerState.stop;
      if (isPodcast) {
        tempEpisode = episode;
        restoreDuration = duration;
        restorePosition = position;
      }
      position = Duration.zero;
      await _stateSubscription?.cancel();
      _stateSubscription = null;
      await _durationSubscription?.cancel();
      _durationSubscription = null;
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      await audioPlayer.stop();
    }
  }

  @override
  Future resume() async {
    if (playerState == AudioPlayerState.pause) {
      _userPaused = false;
      playerState = AudioPlayerState.play;
      await audioPlayer.play();
    }
  }

  @override
  Future pause() async {
    if (playerState == AudioPlayerState.play) {
      _userPaused = true;
      await audioPlayer.pause();
      if (!audioPlayer.playing) playerState = AudioPlayerState.pause;
      _saveProgress();
    }
  }

  @override
  bool isPlaying() {
    return playerState == AudioPlayerState.play;
  }

  @override
  bool isStreamingAudio() {
    return position.inMilliseconds > 0;
  }

  @override
  bool isPaused() {
    return playerState == AudioPlayerState.pause;
  }

  @override
  void release() async {
    _liveRetryTimer?.cancel();
    playerState = AudioPlayerState.stop;
    position = Duration(seconds: 0);
    duration = Duration(seconds: 0);
    await audioPlayer.dispose();
  }

  @override
  double getPlaybackRate() {
    return playbackRate;
  }

  @override
  void setPlaybackRate(double playbackRate) {
    this.playbackRate = playbackRate;
    audioPlayer.setSpeed(playbackRate);
  }

  String urlToHashId(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }
}
