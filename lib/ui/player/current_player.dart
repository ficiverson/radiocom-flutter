import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/now.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';

typedef void ConnectionCallback(bool isError);

enum PlayerState { play, stop, pause }

abstract class CurrentPlayerContract {
  Now now;
  Episode episode;
  Episode tempEpisode;
  PlayerState playerState = PlayerState.stop;
  AudioPlayer audioPlayer = Injector.appInstance.getDependency<AudioPlayer>();
  String currentSong = ":";
  String currentImage = "https://cuacfm.org/wp-content/uploads/2015/04/cousomicros1.jpg";
  bool isPodcast = false;
  Duration duration = Duration(seconds: 0);
  Duration position = Duration(seconds: 0);
  Duration restoreDuration = Duration(seconds: 0);
  Duration restorePosition = Duration(seconds: 0);
  double volume = 1.0;
  VoidCallback onUpdate;
  ConnectionCallback onConnection;
  ConnectionCallback podcastConnectivityResult;
  ConnectivityResult connectivityResult;

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
}

class CurrentPlayer implements CurrentPlayerContract {
  @override
  Now now;
  @override
  Episode episode;
  @override
  Episode tempEpisode;
  @override
  PlayerState playerState = PlayerState.stop;
  @override
  AudioPlayer audioPlayer = Injector.appInstance.getDependency<AudioPlayer>();
  @override
  String currentSong = ":";
  @override
  String currentImage = "https://cuacfm.org/wp-content/uploads/2015/04/cousomicros1.jpg";
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
  VoidCallback onUpdate;
  @override
  ConnectionCallback onConnection;
  @override
  ConnectionCallback podcastConnectivityResult;
  @override
  ConnectivityResult connectivityResult;

  @override
  void restorePlayer(ConnectivityResult connection) async {
    if (!isPodcast && isPlaying()) {
      if (connection != ConnectivityResult.none &&
          connection != connectivityResult &&
          playerState == PlayerState.play) {
        restorePosition = position;
        restorePosition = duration;
        tempEpisode = episode;
        stop();
        play();
        if (onConnection != null) {
          onConnection(false);
        }
        if (podcastConnectivityResult != null) {
          podcastConnectivityResult(false);
        }
      } else if (connection == ConnectivityResult.none) {
        if (Platform.isIOS) {
          await audioPlayer.play("file://audio");
        }
        stop();
        release();

        if (onConnection != null) {
          onConnection(true);
        }
        if (podcastConnectivityResult != null) {
          podcastConnectivityResult(true);
        }
      }
    }
    connectivityResult = connection;
  }

  @override
  Future<bool> seek(Duration position) async {
    if (playerState == PlayerState.play) {
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
    if (playerState == PlayerState.play) {
      this.volume = volume;
      final result = await audioPlayer.setVolume(volume);
      return result == 1;
    } else {
      return false;
    }
  }

  @override
  Future<bool> play() async {
    if (playerState != PlayerState.play) {
      if (Platform.isIOS) {
        audioPlayer.startHeadlessService();
      }
      if (isPodcast) {
        audioPlayer.onPlayerCompletion.listen((event) {
          stop();
          position = Duration(seconds: 0);
          restoreDuration = Duration(seconds: 0);
          restorePosition = Duration(seconds: 0);
          seek(position);
          if (onUpdate != null) {
            onUpdate();
          }
        });

        audioPlayer.onDurationChanged.listen((Duration d) {
          print(d);
          duration = d;
          if (onUpdate != null) {
            onUpdate();
          }
        });

        audioPlayer.onAudioPositionChanged.listen((Duration p) {
          if (p.inSeconds.ceilToDouble() >= 0.0 &&
              p.inSeconds.ceilToDouble() <= duration.inSeconds.ceilToDouble()) {
            position = p;
            if (onUpdate != null) {
              onUpdate();
            }
          }
        });

//          if (Platform.isIOS) {
//            audioPlayer.setNotification(
//                title: currentSong,
//                imageUrl: currentImage,
//                artist: "CUAC FM",
//                forwardSkipInterval: const Duration(seconds: 30),
//                backwardSkipInterval: const Duration(seconds: 30),
//                duration: d,
//                elapsedTime: position);
//          }

//        if (Platform.isIOS) {
//          audioPlayer.onNotificationPlayerStateChanged.listen((state) {
//            if (state == AudioPlayerState.PLAYING) {
//              playerState = PlayerState.play;
//            } else {
//              playerState = PlayerState.pause;
//            }
//          });
//        }

      } else {
        audioPlayer.onAudioPositionChanged.listen((Duration p) {
          position = p;
        });
      }

      audioPlayer.onPlayerError.listen((onError) {
        print(onError);
      });
      setVolume(1.0);
      if ((isPodcast && episode.audio != null && episode.audio.isNotEmpty) ||
          (!isPodcast &&
              now.streamUrl() != null &&
              now.streamUrl().isNotEmpty)) {
        final result = await audioPlayer.play(
            isPodcast ? episode.audio : now.streamUrl(),
            isLocal: false,
            respectSilence: false);
        if (result == 1) playerState = PlayerState.play;
        if (Platform.isAndroid) {
          MethodChannel('cuacfm.flutter.io/notificationInfo')
              .invokeMethod('notificationInfo', {
            "notificationTitle": isPodcast ? "Podcast" : "Directo",
            "notificationImage" : currentImage,
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
    if (playerState == PlayerState.play || playerState == PlayerState.pause) {
      final result = await audioPlayer.pause();
      if (result == 1) playerState = PlayerState.pause;
      duration = Duration(seconds: 0);
      position = Duration(seconds: 0);
      if (!isPodcast) {
        setVolume(1.0);
      }
      final playResult = await audioPlayer.play(
          isPodcast ? episode.audio : now.streamUrl(),
          isLocal: false,
          respectSilence: false);
      if (playResult == 1) playerState = PlayerState.play;
      if (Platform.isAndroid) {
        MethodChannel('cuacfm.flutter.io/notificationInfo')
            .invokeMethod('notificationInfo', {
          "notificationTitle": isPodcast ? "Podcast" : "Directo",
          "notificationImage" : currentImage,
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
    if (playerState == PlayerState.play || playerState == PlayerState.pause) {
      playerState = PlayerState.stop;
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
    if (playerState == PlayerState.pause) {
      playerState = PlayerState.play;
      await audioPlayer.resume();
      if (Platform.isAndroid) {
        MethodChannel('cuacfm.flutter.io/notificationInfo')
            .invokeMethod('notificationInfo', {
          "notificationTitle": isPodcast ? "Podcast" : "Directo",
          "notificationImage" : currentImage,
          "notificationSubtitle": currentSong
        });
      }
    }
  }

  @override
  Future pause() async {
    if (playerState == PlayerState.play) {
      final result = await audioPlayer.pause();
      if (result == 1) playerState = PlayerState.pause;
    }
  }

  @override
  bool isPlaying() {
    return playerState == PlayerState.play;
  }

  @override
  bool isStreamingAudio() {
    return position.inMilliseconds > 0;
  }

  @override
  bool isPaused() {
    return playerState == PlayerState.pause;
  }

  @override
  void release() async {
    playerState = PlayerState.stop;
    position = Duration(seconds: 0);
    duration = Duration(seconds: 0);
    audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
    await audioPlayer.release();
  }
}
