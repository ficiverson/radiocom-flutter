import 'package:just_audio/just_audio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/radiostation.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:just_audio_background/just_audio_background.dart';
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

  @override
  Future<bool> play() async {
    if (playerState != AudioPlayerState.play) {
      if (isPodcast) {
        audioPlayer.playerStateStream.listen((event) {
          if (event.processingState == ProcessingState.completed) {
            stop();
            position = Duration(seconds: 0);
            restoreDuration = Duration(seconds: 0);
            restorePosition = Duration(seconds: 0);
            seek(position);
            if (onUpdate != null) {
              onUpdate!();
            }
          }
        });

        audioPlayer.durationStream.listen((Duration? d) {
          print(d);
          duration = d ?? Duration(hours: 1);
          if (onUpdate != null && duration > Duration(seconds: 0)) {
            onUpdate!();
          }
        });
      }
      audioPlayer.positionStream.listen((Duration p) {
        if (isPodcast) {
          if (p.inSeconds.ceilToDouble() >= 0.0 &&
              p.inSeconds.ceilToDouble() <= duration.inSeconds.ceilToDouble()) {
            position = p;
            if (onUpdate != null) {
              onUpdate!();
            }
          }
        } else {
          position = Duration(seconds: 1);
          duration = Duration(hours: 24);
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
        AudioSource audioSource = AudioSource.uri(
            Uri.parse(isPodcast
                ? episode?.audio ?? RadioStation.base().streamUrl
                : now?.streamUrl() ?? RadioStation.base().streamUrl),
            tag: MediaItem(
              id: urlToHashId(
                  isPodcast ? episode?.audio ?? "" : now?.streamUrl() ?? ""),
              album: isPodcast ? "Podcast CUAC FM" : "Directo CUAC FM",
              title: isPodcast ? episode?.title ?? "" : "Streaming en directo",
              artist: "CUAC FM",
              artUri: Uri.parse(currentImage),
            ));
        audioPlayer.setAudioSource(audioSource);
        await audioPlayer.play();
        await audioPlayer.seek(position);
        if (audioPlayer.playing) playerState = AudioPlayerState.play;
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
      AudioSource audioSource = AudioSource.uri(
          Uri.parse(isPodcast
              ? episode?.audio ?? RadioStation.base().streamUrl
              : now?.streamUrl() ?? RadioStation.base().streamUrl),
          tag: MediaItem(
            id: urlToHashId(
                isPodcast ? episode?.audio ?? "" : now?.streamUrl() ?? ""),
            album: isPodcast ? "Podcast CUAC FM" : "Directo CUAC FM",
            title: isPodcast ? episode?.title ?? "" : "Streaming en directo",
            artist: "CUAC FM",
            artUri: Uri.parse(currentImage),
          ));
      audioPlayer.setAudioSource(audioSource);
      await audioPlayer.play();
      await audioPlayer.seek(position);
      if (audioPlayer.playing) playerState = AudioPlayerState.play;
      return true;
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
      await audioPlayer.play();
    }
  }

  @override
  Future pause() async {
    if (playerState == AudioPlayerState.play) {
      await audioPlayer.pause();
      if (!audioPlayer.playing) playerState = AudioPlayerState.pause;
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
