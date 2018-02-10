import 'package:audioplayer/audioplayer.dart';
import 'package:cuacfm/models/current_podcast.dart';

enum PlayerState {
  play,
  stop,
  pause
}

/// Simple DI
class Injector {
  static final Injector _singleton = new Injector._internal();
  static CurrentPodcast _currentPodcast;
  static AudioPlayer audioPlayer;
  static Object state;

  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  static CurrentPodcast getPodcast() {
    return _currentPodcast;
  }

  static void setPodcast(CurrentPodcast currentPodcast) {
    _currentPodcast = currentPodcast;
  }

  static AudioPlayer get player {
    if(audioPlayer == null) {
      audioPlayer = new AudioPlayer();
    }
    return audioPlayer;
  }

  static get playerState {
    return state;
  }

  static set playerState(Object newState) {
    state = newState;
  }

}