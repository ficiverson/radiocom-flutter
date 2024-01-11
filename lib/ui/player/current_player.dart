import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';

typedef void ConnectionCallback(bool isError);

enum AudioPlayerState { play, stop, pause }

abstract class CurrentPlayerContract {
  Now? now;
  Episode? episode;
  Episode? tempEpisode;
  AudioPlayerState playerState = AudioPlayerState.stop;
  AudioPlayer audioPlayer = Injector.appInstance.get<AudioPlayer>();
  String currentSong = ":";
  String currentImage =
      "https://cuacfm.org/wp-content/uploads/2015/04/cousomicros1.jpg";
  bool isPodcast = false;
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
  @override
  String currentSong = ":";
  @override
  String currentImage =
      "https://cuacfm.org/wp-content/uploads/2015/04/cousomicros1.jpg";
  @override
  bool isPodcast = false;
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

  @override
  void restorePlayer(ConnectivityResult connection) async {
    if (!isPodcast && isPlaying()) {
      if (connection != ConnectivityResult.none &&
          connection != connectivityResult &&
          playerState == AudioPlayerState.play) {
        restorePosition = position;
        restorePosition = duration;
        tempEpisode = episode;
        stop();
        play();
        if (onConnection != null) {
          onConnection!(false);
        }
        if (podcastConnectivityResult != null) {
          podcastConnectivityResult!(false);
        }
      } else if (connection == ConnectivityResult.none) {
        if (Platform.isIOS) {
          await audioPlayer.play("file://audio");
        }
        stop();
        release();

        if (onConnection != null) {
          onConnection!(true);
        }
        if (podcastConnectivityResult != null) {
          podcastConnectivityResult!(true);
        }
      }
    }
    connectivityResult = connection;
  }

  @override
  Future<bool> seek(Duration position) async {
    if (playerState == AudioPlayerState.play) {
      if (position <= duration) {
        final result = await audioPlayer.seek(position);
        return result == 1;
      } else {
        final result = await audioPlayer.seek(duration);
        return result == 1;
      }
    } else {
      return false;
    }
  }

  @override
  Future<bool> setVolume(double volume) async {
    if (playerState == AudioPlayerState.play) {
      this.volume = volume;
      final result = await audioPlayer.setVolume(volume);
      return result == 1;
    } else {
      return false;
    }
  }

  @override
  Future<bool> play() async {
    if (playerState != AudioPlayerState.play) {
      if (Platform.isIOS) {
        audioPlayer.notificationService.startHeadlessService();
      }
      if (isPodcast) {
        audioPlayer.onPlayerCompletion.listen((event) {
          stop();
          position = Duration(seconds: 0);
          restoreDuration = Duration(seconds: 0);
          restorePosition = Duration(seconds: 0);
          seek(position);
          if (onUpdate != null) {
            onUpdate!();
          }
        });

        audioPlayer.onDurationChanged.listen((Duration d) {
          print(d);
          duration = d;
          if (onUpdate != null) {
            onUpdate!();
          }
        });
      }
      audioPlayer.onAudioPositionChanged.listen((Duration p) {
        if (isPodcast) {
          if (p.inSeconds.ceilToDouble() >= 0.0 &&
              p.inSeconds.ceilToDouble() <= duration.inSeconds.ceilToDouble()) {
            position = p;
            if (onUpdate != null) {
              onUpdate!();
            }
            if (Platform.isIOS) {
              audioPlayer.notificationService.setNotification(
                  title: currentSong,
                  imageUrl: currentImage,
                  artist: "CUAC FM",
                  albumTitle: "Podcast",
                  forwardSkipInterval: const Duration(seconds: 30),
                  backwardSkipInterval: const Duration(seconds: 30),
                  duration: duration,
                  elapsedTime: position);
            }
          }
        } else {
          position = p;
          if (Platform.isIOS) {
            audioPlayer.notificationService.setNotification(
                title: currentSong,
                imageUrl: currentImage,
                albumTitle: "Live",
                artist: "CUAC FM");
          }
        }
      });

      if (Platform.isIOS) {
        audioPlayer.onNotificationPlayerStateChanged.listen((state) {
          if (state == PlayerState.PLAYING) {
            playerState = AudioPlayerState.play;
          } else {
            playerState = AudioPlayerState.pause;
          }
          if (onUpdate != null) {
            onUpdate!();
          }
        });
      }

      audioPlayer.onPlayerError.listen((onError) {
        print(onError);
      });
      setVolume(1.0);
      if ((isPodcast && episode?.audio != null && episode!.audio.isNotEmpty) ||
          (!isPodcast &&
              now?.streamUrl() != null &&
              now!.streamUrl().isNotEmpty)) {
        if (!isPodcast) {
          playbackRate = 1.0;
          audioPlayer.setPlaybackRate(playbackRate);
        }
        final result = await audioPlayer.play(
            isPodcast
                ? episode?.audio ?? RadioStation.base().streamUrl
                : now?.streamUrl() ?? RadioStation.base().streamUrl,
            isLocal: false,
            respectSilence: false);
        if (result == 1) playerState = AudioPlayerState.play;
        if (Platform.isAndroid) {
          MethodChannel('cuacfm.flutter.io/notificationInfo')
              .invokeMethod('notificationInfo', {
            "notificationTitle": isPodcast ? "Podcast" : "Directo",
            "notificationImage": currentImage,
            "notificationSubtitle": currentSong
          });
        }
        if (restorePosition != Duration(seconds: 0) &&
            restoreDuration != Duration(seconds: 0) &&
            isPodcast &&
            tempEpisode == episode) {
          duration = restoreDuration;
          tempEpisode = null;
          seek(restorePosition);
        } else {
          restoreDuration = Duration(seconds: 0);
          restorePosition = Duration(seconds: 0);
        }
        return result == 1;
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
      if (!isPodcast) {
        playbackRate = 1.0;
        audioPlayer.setPlaybackRate(playbackRate);
      }
      final result = await audioPlayer.pause();
      if (result == 1) playerState = AudioPlayerState.pause;
      duration = Duration(seconds: 0);
      position = Duration(seconds: 0);
      if (!isPodcast) {
        setVolume(1.0);
      }
      final playResult = await audioPlayer.play(
          isPodcast
              ? episode?.audio ?? RadioStation.base().streamUrl
              : now?.streamUrl() ?? RadioStation.base().streamUrl,
          isLocal: false,
          respectSilence: false);
      if (playResult == 1) playerState = AudioPlayerState.play;
      if (Platform.isAndroid) {
        MethodChannel('cuacfm.flutter.io/notificationInfo')
            .invokeMethod('notificationInfo', {
          "notificationTitle": isPodcast ? "Podcast" : "Directo",
          "notificationImage": currentImage,
          "notificationSubtitle": currentSong
        });
      }
      return playResult == 1;
    } else {
      return false;
    }
  }

  @override
  void stop() async {
    if (playerState == AudioPlayerState.play ||
        playerState == AudioPlayerState.pause) {
      playerState = AudioPlayerState.stop;
      if (isPodcast) {
        tempEpisode = episode;
        restoreDuration = duration;
        restorePosition = position;
      }
      position = Duration(seconds: 0);
      await audioPlayer.stop();
    }
  }

  @override
  Future resume() async {
    if (playerState == AudioPlayerState.pause) {
      playerState = AudioPlayerState.play;
      await audioPlayer.resume();
      if (Platform.isAndroid) {
        MethodChannel('cuacfm.flutter.io/notificationInfo')
            .invokeMethod('notificationInfo', {
          "notificationTitle": isPodcast ? "Podcast" : "Directo",
          "notificationImage": currentImage,
          "notificationSubtitle": currentSong
        });
      }
    }
  }

  @override
  Future pause() async {
    if (playerState == AudioPlayerState.play) {
      final result = await audioPlayer.pause();
      if (result == 1) playerState = AudioPlayerState.pause;
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
    playerState = AudioPlayerState.stop;
    position = Duration(seconds: 0);
    duration = Duration(seconds: 0);
    audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
    await audioPlayer.release();
  }

  @override
  double getPlaybackRate() {
    return playbackRate;
  }

  @override
  void setPlaybackRate(double playbackRate) {
    this.playbackRate = playbackRate;
    audioPlayer.setPlaybackRate(playbackRate);
  }
}
