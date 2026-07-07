import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class CuacAudioHandler extends BaseAudioHandler {
  static const _seekStep = Duration(seconds: 30);

  static const _rewindControl = MediaControl(
    androidIcon: 'drawable/ic_replay_30',
    label: 'Retroceder 30 segundos',
    action: MediaAction.rewind,
  );
  static const _fastForwardControl = MediaControl(
    androidIcon: 'drawable/ic_forward_30',
    label: 'Avanzar 30 segundos',
    action: MediaAction.fastForward,
  );

  final AudioPlayer _player;
  bool _isLive = false;

  CuacAudioHandler(this._player) {
    _player.playbackEventStream.listen((_) => _broadcastState());
    _player.playingStream.listen((_) => _broadcastState());
    _player.durationStream.listen((duration) {
      final item = mediaItem.valueOrNull;
      if (!_isLive && item != null && duration != null) {
        mediaItem.add(item.copyWith(duration: duration));
      }
    });
  }

  void setNowPlaying(MediaItem item, {required bool isLive}) {
    _isLive = isLive;
    mediaItem.add(isLive ? item : item.copyWith(duration: _player.duration));
    _broadcastState();
  }

  void _broadcastState() {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        if (!_isLive) _rewindControl,
        if (playing) MediaControl.pause else MediaControl.play,
        if (!_isLive) _fastForwardControl,
        MediaControl.stop,
      ],
      systemActions: {
        if (!_isLive) MediaAction.seek,
        if (!_isLive) MediaAction.seekForward,
        if (!_isLive) MediaAction.seekBackward,
      },
      androidCompactActionIndices: _isLive ? const [0, 1] : const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    ));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> fastForward() => _seekBy(_seekStep);

  @override
  Future<void> rewind() => _seekBy(-_seekStep);

  Future<void> _seekBy(Duration offset) async {
    if (_isLive) return;
    final duration = _player.duration ?? Duration.zero;
    var target = _player.position + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (duration > Duration.zero && target > duration) target = duration;
    await _player.seek(target);
  }
}
