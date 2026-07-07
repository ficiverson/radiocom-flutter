import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cuacfm/ui/player/cuac_audio_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';

// ---------------------------------------------------------------------------
// Fake AudioPlayer — provides only what CuacAudioHandler actually reads
// ---------------------------------------------------------------------------
class _FakeAudioPlayer extends Fake implements AudioPlayer {
  final _playbackEventCtrl =
      StreamController<PlaybackEvent>.broadcast();
  final _playingCtrl = StreamController<bool>.broadcast();
  final _durationCtrl = StreamController<Duration?>.broadcast();

  @override
  Stream<PlaybackEvent> get playbackEventStream => _playbackEventCtrl.stream;
  @override
  Stream<bool> get playingStream => _playingCtrl.stream;
  @override
  Stream<Duration?> get durationStream => _durationCtrl.stream;

  // Controllable state
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration? _duration;

  @override
  bool get playing => _playing;
  @override
  ProcessingState get processingState => ProcessingState.idle;
  @override
  Duration get position => _position;
  @override
  Duration get bufferedPosition => Duration.zero;
  @override
  double get speed => 1.0;
  @override
  Duration? get duration => _duration;

  // Recorded calls
  final List<Duration> seekCalls = [];
  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;

  @override
  Future<void> play() async {
    playCalls++;
    _playing = true;
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    _playing = false;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    _playing = false;
  }

  @override
  Future<void> seek(Duration? position, {Duration? rest}) async {
    if (position != null) seekCalls.add(position);
  }

  void fakeClose() {
    _playbackEventCtrl.close();
    _playingCtrl.close();
    _durationCtrl.close();
  }

  // Helpers to push events from test
  void emitPlaying(bool value) => _playingCtrl.add(value);
  void emitDuration(Duration? d) => _durationCtrl.add(d);
}

// ---------------------------------------------------------------------------
// A minimal MediaItem for setNowPlaying calls
// ---------------------------------------------------------------------------
MediaItem _testMediaItem({bool isLive = false}) => MediaItem(
      id: isLive ? 'live' : 'podcast-ep-1',
      title: isLive ? 'Live Radio' : 'Episode 1',
      artist: 'CUAC FM',
    );

void main() {
  late _FakeAudioPlayer fakePlayer;
  late CuacAudioHandler handler;

  setUp(() {
    fakePlayer = _FakeAudioPlayer();
    handler = CuacAudioHandler(fakePlayer);
  });

  tearDown(() {
    fakePlayer.fakeClose();
  });

  // -------------------------------------------------------------------------
  // setNowPlaying
  // -------------------------------------------------------------------------
  group('setNowPlaying', () {
    test('sets mediaItem', () {
      final item = _testMediaItem();
      handler.setNowPlaying(item, isLive: false);
      expect(handler.mediaItem.value?.id, equals(item.id));
    });

    test('live mode broadcasts controls without seek actions', () {
      handler.setNowPlaying(_testMediaItem(isLive: true), isLive: true);
      final state = handler.playbackState.value;
      // Seek-related system actions must be absent when live
      expect(state.systemActions.contains(MediaAction.seek), isFalse);
      expect(state.systemActions.contains(MediaAction.seekForward), isFalse);
      expect(state.systemActions.contains(MediaAction.seekBackward), isFalse);
    });

    test('podcast mode broadcasts seek actions', () {
      handler.setNowPlaying(_testMediaItem(), isLive: false);
      final state = handler.playbackState.value;
      expect(state.systemActions.contains(MediaAction.seek), isTrue);
    });

    test('live mode controls do not include rewind or fastForward', () {
      handler.setNowPlaying(_testMediaItem(isLive: true), isLive: true);
      final controlActions =
          handler.playbackState.value.controls.map((c) => c.action).toList();
      expect(controlActions.contains(MediaAction.rewind), isFalse);
      expect(controlActions.contains(MediaAction.fastForward), isFalse);
    });

    test('podcast mode controls include rewind and fastForward', () {
      handler.setNowPlaying(_testMediaItem(), isLive: false);
      final controlActions =
          handler.playbackState.value.controls.map((c) => c.action).toList();
      expect(controlActions.contains(MediaAction.rewind), isTrue);
      expect(controlActions.contains(MediaAction.fastForward), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // play / pause / stop delegation
  // -------------------------------------------------------------------------
  group('playback delegation', () {
    test('play() delegates to AudioPlayer', () async {
      await handler.play();
      expect(fakePlayer.playCalls, equals(1));
    });

    test('pause() delegates to AudioPlayer', () async {
      await handler.pause();
      expect(fakePlayer.pauseCalls, equals(1));
    });

    test('stop() delegates to AudioPlayer', () async {
      await handler.stop();
      expect(fakePlayer.stopCalls, equals(1));
    });

    test('seek() delegates to AudioPlayer', () async {
      const pos = Duration(seconds: 45);
      await handler.seek(pos);
      expect(fakePlayer.seekCalls, equals([pos]));
    });
  });

  // -------------------------------------------------------------------------
  // _seekBy / rewind / fastForward
  // -------------------------------------------------------------------------
  group('rewind and fastForward', () {
    test('rewind is a no-op when live', () async {
      handler.setNowPlaying(_testMediaItem(isLive: true), isLive: true);
      await handler.rewind();
      expect(fakePlayer.seekCalls, isEmpty);
    });

    test('fastForward is a no-op when live', () async {
      handler.setNowPlaying(_testMediaItem(isLive: true), isLive: true);
      await handler.fastForward();
      expect(fakePlayer.seekCalls, isEmpty);
    });

    test('rewind seeks backward 30 s when not live', () async {
      handler.setNowPlaying(_testMediaItem(), isLive: false);
      fakePlayer._position = const Duration(seconds: 60);
      fakePlayer._duration = const Duration(seconds: 120);
      await handler.rewind();
      expect(fakePlayer.seekCalls.single,
          equals(const Duration(seconds: 30)));
    });

    test('fastForward seeks forward 30 s when not live', () async {
      handler.setNowPlaying(_testMediaItem(), isLive: false);
      fakePlayer._position = const Duration(seconds: 30);
      fakePlayer._duration = const Duration(seconds: 120);
      await handler.fastForward();
      expect(fakePlayer.seekCalls.single,
          equals(const Duration(seconds: 60)));
    });

    test('rewind clamps to Duration.zero when position < 30 s', () async {
      handler.setNowPlaying(_testMediaItem(), isLive: false);
      fakePlayer._position = const Duration(seconds: 10);
      fakePlayer._duration = const Duration(seconds: 120);
      await handler.rewind();
      expect(fakePlayer.seekCalls.single, equals(Duration.zero));
    });

    test('fastForward clamps to duration when remaining < 30 s', () async {
      handler.setNowPlaying(_testMediaItem(), isLive: false);
      fakePlayer._position = const Duration(seconds: 100);
      fakePlayer._duration = const Duration(seconds: 120);
      await handler.fastForward();
      expect(fakePlayer.seekCalls.single,
          equals(const Duration(seconds: 120)));
    });

    test('fastForward does not seek past end when duration is zero', () async {
      // duration == Duration.zero means unknown → clamp is skipped
      handler.setNowPlaying(_testMediaItem(), isLive: false);
      fakePlayer._position = const Duration(seconds: 30);
      fakePlayer._duration = Duration.zero; // treated as unknown
      await handler.fastForward();
      // target = 60s, duration == 0 so no upper-bound clamp applied
      expect(fakePlayer.seekCalls.single,
          equals(const Duration(seconds: 60)));
    });
  });

  // -------------------------------------------------------------------------
  // _broadcastState reacts to player events
  // -------------------------------------------------------------------------
  group('state broadcasting', () {
    test('playbackState reflects playing=true after player emits', () async {
      fakePlayer._playing = true;
      fakePlayer.emitPlaying(true);
      await Future.microtask(() {}); // let listener fire
      expect(handler.playbackState.value.playing, isTrue);
    });

    test('playbackState reflects playing=false after player emits', () async {
      fakePlayer._playing = false;
      fakePlayer.emitPlaying(false);
      await Future.microtask(() {});
      expect(handler.playbackState.value.playing, isFalse);
    });

    test('mediaItem duration is updated when not live', () async {
      handler.setNowPlaying(_testMediaItem(), isLive: false);
      const dur = Duration(minutes: 5);
      fakePlayer._duration = dur;
      fakePlayer.emitDuration(dur);
      await Future.microtask(() {});
      // Duration is set on the mediaItem
      expect(handler.mediaItem.value?.duration, equals(dur));
    });

    test('mediaItem duration is NOT updated when live', () async {
      handler.setNowPlaying(_testMediaItem(isLive: true), isLive: true);
      fakePlayer.emitDuration(const Duration(minutes: 5));
      await Future.microtask(() {});
      // Live streams should not get a duration on the media item
      expect(handler.mediaItem.value?.duration, isNull);
    });
  });
}
