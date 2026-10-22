import 'dart:math' as math;

import 'package:audio_service/audio_service.dart';
import 'package:cuacfm/data/datasource/episode_progress_local_datasource_contract.dart';
import 'package:cuacfm/domain/invoker/invoker.dart';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:cuacfm/domain/result/result.dart';
import 'package:cuacfm/domain/usecase/get_favorites_use_case.dart';
import 'package:cuacfm/domain/usecase/get_playlist_use_case.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/now.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/models/time_table.dart';
import 'package:cuacfm/ui/player/current_player.dart';
import 'package:hive/hive.dart';
import 'package:injector/injector.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class CuacAudioHandler extends BaseAudioHandler {
  static const _seekStep = Duration(seconds: 30);
  static const _tabLive = 'tab_live';
  static const _tabRecent = 'tab_recent';
  static const _tabFavorites = 'tab_favorites';
  static const _tabPlaylist = 'tab_playlist';

  static const _csBrowsableHint =
      'androidx.media.utils.extras.CONTENT_STYLE_BROWSABLE_HINT';
  static const _csPlayableHint =
      'androidx.media.utils.extras.CONTENT_STYLE_PLAYABLE_HINT';
  static const _csGroupTitleHint =
      'androidx.media.utils.extras.CONTENT_STYLE_GROUP_TITLE_HINT';
  static const _csBrowsableHintLegacy =
      'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT';
  static const _csPlayableHintLegacy =
      'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT';
  static const _csGroupTitleHintLegacy =
      'android.media.browse.CONTENT_STYLE_GROUP_TITLE_HINT';
  static const _csGridItem = 2;
  static const _csListItem = 1;

  static const _monthsGl = [
    'xan', 'feb', 'mar', 'abr', 'mai', 'xuñ',
    'xul', 'ago', 'set', 'out', 'nov', 'dec'
  ];
  static const _musicCoverArt =
      'https://cuacfm.org/wp-content/uploads/2026/04/cuac_music_cover.png';
  static const _defaultProgrammeArt =
      'https://cuacfm.org/wp-content/uploads/2026/06/default_programme_cover.png';

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

  final Map<String, List<Episode>> _episodesByRss = {};
  final Map<String, TimeTable> _recentByKey = {};
  final Map<String, Program> _favoriteByRss = {};
  final Map<String, Map<String, dynamic>> _continueByAudio = {};
  final Map<String, BehaviorSubject<Map<String, dynamic>>> _childrenSubjects =
      {};
  bool _wasPlaying = false;
  List<Map<String, dynamic>> _playlistItems = [];
  List<Program> _allProgramsCache = [];
  Now? _liveNow;

  CuacRepositoryContract get _repository =>
      Injector.appInstance.get<CuacRepositoryContract>();

  Invoker get _invoker => Injector.appInstance.get<Invoker>();

  CuacAudioHandler(this._player) {
    _player.playbackEventStream.listen((_) => _broadcastState());
    _player.playingStream.listen((playing) {
      _broadcastState();
      if (_wasPlaying && !playing && !_isLive) {
        _notifyInicioChanged();
      }
      _wasPlaying = playing;
    });
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
  Future<void> play() async {
    try {
      final player = Injector.appInstance.get<CurrentPlayerContract>();
      if (player.playerState == AudioPlayerState.stop) {
        player.playbackSource = 'android_auto';
        try {
          await _playLive(player);
        } finally {
          player.playbackSource = 'app';
        }
        return;
      }
      if (player.playerState == AudioPlayerState.pause) {
        await player.resume();
        return;
      }
    } catch (_) {}
    await _player.play();
  }

  @override
  Future<void> pause() async {
    try {
      Injector.appInstance.get<CurrentPlayerContract>().pause();
    } catch (_) {}
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    try {
      Injector.appInstance.get<CurrentPlayerContract>().stop();
    } catch (_) {}
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

  @override
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
    return _childrenSubjects.putIfAbsent(
        parentMediaId, () => BehaviorSubject.seeded(<String, dynamic>{}));
  }

  void _notifyInicioChanged() {
    _childrenSubjects[_tabLive]?.add(<String, dynamic>{});
  }

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    switch (parentMediaId) {
      case AudioService.browsableRootId:
        return [
          MediaItem(
              id: _tabLive,
              title: 'Inicio',
              playable: false,
              extras: _homeStyle()),
          MediaItem(
              id: _tabRecent,
              title: 'Recentes',
              playable: false,
              extras: _gridStyle()),
          MediaItem(
              id: _tabFavorites,
              title: 'Favoritos',
              playable: false,
              extras: _gridStyle()),
          MediaItem(id: _tabPlaylist, title: 'Playlist', playable: false),
        ];
      case _tabLive:
        return _homeChildren();
      case _tabRecent:
        return _recentChildren();
      case _tabFavorites:
        return _favoriteChildren();
      case _tabPlaylist:
        return _playlistChildren();
      default:
        if (parentMediaId.startsWith('fav|')) {
          return _favoriteEpisodes(parentMediaId.substring(4));
        }
        return [];
    }
  }

  Future<List<MediaItem>> _homeChildren() async {
    Now? now;
    try {
      final result = await _repository.getLiveBroadcast();
      if (result is Success) now = result.data;
    } catch (_) {}
    _liveNow = now ?? Now.mock();
    final items = <MediaItem>[
      MediaItem(
        id: 'live',
        title: _liveNow!.name,
        artist: 'CUAC FM 103.4',
        artUri: _artUri(_liveNow!.logoUrl),
        extras: _group('Directo'),
      ),
    ];
    items.addAll(_continueChildren());
    final discover = await _discoverPrograms();
    for (final p in discover) {
      _favoriteByRss[p.rssUrl] = p;
      items.add(MediaItem(
        id: 'fav|${p.rssUrl}',
        title: p.name,
        playable: false,
        artUri: _artUri(p.logoUrl),
        extras: _group('Descubre podcasts'),
      ));
    }
    return items;
  }

  List<MediaItem> _continueChildren() {
    EpisodeProgressLocalDataSourceContract? store;
    try {
      store =
          Injector.appInstance.get<EpisodeProgressLocalDataSourceContract>();
    } catch (_) {}
    if (store == null) return [];
    final entries = store.getAll().entries.where((e) {
      final m = e.value;
      final pos = (m['position'] as num?)?.toInt() ?? 0;
      final dur = (m['duration'] as num?)?.toInt() ?? 0;
      return m['completed'] != true &&
          (m['title'] as String?)?.isNotEmpty == true &&
          dur > 0 &&
          pos > 5 &&
          pos < dur * 0.9;
    }).toList()
      ..sort((a, b) => ((b.value['updatedAt'] as num?)?.toInt() ?? 0)
          .compareTo((a.value['updatedAt'] as num?)?.toInt() ?? 0));
    _continueByAudio.clear();
    return entries.take(2).map((e) {
      _continueByAudio[e.key] = e.value;
      final m = e.value;
      final pos = (m['position'] as num?)?.toInt() ?? 0;
      final program = m['programName'] as String? ?? 'CUAC FM';
      return MediaItem(
        id: 'cont|${e.key}',
        title: m['title'] as String? ?? '',
        artist: '$program · ${_formatPos(pos)}',
        artUri: _artUri(m['logoUrl'] as String? ?? ''),
        extras: _group('Seguir escoitando'),
      );
    }).toList();
  }

  String _formatPos(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final ss = s.toString().padLeft(2, '0');
    if (h > 0) {
      final mm = m.toString().padLeft(2, '0');
      return '$h:$mm:$ss';
    }
    return '$m:$ss';
  }

  Future<List<MediaItem>> _recentChildren() async {
    final formatter = DateFormat('dd/MM/yyyy');
    final nowDate = DateTime.now();
    List<TimeTable> timetable = [];
    try {
      final result = await _repository.getTimetableData(
          formatter.format(nowDate.subtract(const Duration(days: 7))),
          formatter.format(nowDate));
      if (result is Success) {
        timetable = List<TimeTable>.from(result.data ?? []);
      }
    } catch (_) {}
    final finished = timetable
        .where((e) =>
            e.type != 'S' && e.end.isBefore(nowDate) && e.rssUrl.isNotEmpty)
        .toList()
      ..sort((a, b) => b.start.compareTo(a.start));
    final seen = <String>{};
    final recent = finished.where((e) => seen.add(e.name)).take(20).toList();
    _recentByKey.clear();
    return recent.map((e) {
      final key = 'recent|${e.rssUrl}|${e.start.millisecondsSinceEpoch}';
      _recentByKey[key] = e;
      return MediaItem(
        id: key,
        title: e.name,
        artist: '${e.start.day} ${_monthsGl[e.start.month - 1]}',
        artUri: _artUri(e.logoUrl),
      );
    }).toList();
  }

  Future<List<MediaItem>> _favoriteChildren() async {
    final favorites = <Program>[];
    await for (final result
        in _invoker.execute(Injector.appInstance.get<GetFavoritesUseCase>())) {
      if (result is Success) {
        favorites.addAll((result.data ?? [])
            .map((e) => Program.fromFavorite(e))
            .toList()
            .cast<Program>());
      }
    }
    final logos = <String, String>{};
    for (final p in await _allPrograms()) {
      if (p.rssUrl.isNotEmpty && p.logoUrl.isNotEmpty) logos[p.rssUrl] = p.logoUrl;
    }
    _favoriteByRss.clear();
    return favorites.where((p) => p.rssUrl.isNotEmpty).map((p) {
      final freshLogo = logos[p.rssUrl];
      if (freshLogo != null && freshLogo.isNotEmpty) p.logoUrl = freshLogo;
      _favoriteByRss[p.rssUrl] = p;
      return MediaItem(
        id: 'fav|${p.rssUrl}',
        title: p.name,
        playable: false,
        artUri: _artUri(p.logoUrl),
      );
    }).toList();
  }

  Future<List<MediaItem>> _favoriteEpisodes(String rssUrl) async {
    final episodes = await _episodesFor(rssUrl);
    final program = _favoriteByRss[rssUrl];
    return episodes.take(30).map((ep) {
      return MediaItem(
        id: 'ep|$rssUrl|${ep.audio}',
        title: ep.title,
        artist: program?.name ?? 'CUAC FM',
        artUri: _artUri(program?.logoUrl ?? ''),
      );
    }).toList();
  }

  Future<List<MediaItem>> _playlistChildren() async {
    await _loadPlaylistItems();
    if (_playlistItems.isEmpty) return [];
    final logosByName = <String, String>{};
    for (final p in await _allPrograms()) {
      if (p.name.isNotEmpty && p.logoUrl.isNotEmpty) logosByName[p.name] = p.logoUrl;
    }
    return [
      MediaItem(
        id: 'pl_all',
        title: 'Reproducir todo',
        artist: _playlistItems.length == 1
            ? '1 episodio'
            : '${_playlistItems.length} episodios',
      ),
      ..._playlistItems.map((item) {
        final fresh = logosByName[item['programName']] ?? (item['logoUrl'] ?? '');
        return MediaItem(
          id: 'pl|${item['audio']}',
          title: item['title'] ?? '',
          artist: item['programName'] ?? 'CUAC FM',
          artUri: _artUri(fresh),
        );
      }),
    ];
  }

  Future<String> _freshLogoForProgram(String? programName, String fallback) async {
    if (programName != null && programName.isNotEmpty) {
      for (final p in await _allPrograms()) {
        if (p.name == programName && p.logoUrl.isNotEmpty) return p.logoUrl;
      }
    }
    return fallback;
  }

  Future<void> _loadPlaylistItems() async {
    _playlistItems = [];
    await for (final result
        in _invoker.execute(Injector.appInstance.get<GetPlaylistUseCase>())) {
      if (result is Success) {
        _playlistItems = List<Map<String, dynamic>>.from(result.data ?? []);
      }
    }
  }

  Future<List<Episode>> _episodesFor(String rssUrl) async {
    final cached = _episodesByRss[rssUrl];
    if (cached != null && cached.isNotEmpty) return cached;
    List<Episode> episodes = [];
    try {
      final result = await _repository.getEpisodes(rssUrl);
      if (result is Success) {
        episodes = List<Episode>.from(result.data ?? []);
      }
    } catch (_) {}
    _episodesByRss[rssUrl] = episodes;
    return episodes;
  }

  @override
  Future<void> playFromMediaId(String mediaId,
      [Map<String, dynamic>? extras]) async {
    playbackState.add(playbackState.value
        .copyWith(processingState: AudioProcessingState.loading));
    try {
      await _handlePlayFromMediaId(mediaId);
    } finally {
      _broadcastState();
    }
  }

  Future<void> _handlePlayFromMediaId(String mediaId) async {
    final player = Injector.appInstance.get<CurrentPlayerContract>();
    player.playbackSource = 'android_auto';
    try {
      await _dispatchPlayFromMediaId(mediaId, player);
    } finally {
      player.playbackSource = 'app';
    }
  }

  @override
  Future<void> playFromSearch(String query,
      [Map<String, dynamic>? extras]) async {
    playbackState.add(playbackState.value
        .copyWith(processingState: AudioProcessingState.loading));
    final player = Injector.appInstance.get<CurrentPlayerContract>();
    player.playbackSource = 'android_auto';
    try {
      await _handleSearch(query, player);
    } finally {
      player.playbackSource = 'app';
      _broadcastState();
    }
  }

  Future<void> _handleSearch(String query, CurrentPlayerContract player) async {
    final normQuery = _normalize(query);
    if (_cleanQuery(normQuery).isEmpty ||
        _liveAliases.any((a) => normQuery.contains(a))) {
      await _playLive(player);
      return;
    }
    final program = _matchProgram(normQuery, await _allPrograms());
    if (program == null) {
      await _playLive(player);
      return;
    }
    final episodes = await _episodesFor(program.rssUrl);
    if (episodes.isEmpty) {
      await _playLive(player);
      return;
    }
    final sorted = List<Episode>.from(episodes)
      ..sort((a, b) => b.pubDate.compareTo(a.pubDate));
    await _playEpisode(player, sorted.first, program.name, program.logoUrl);
  }

  static const _searchStopWords = {
    'pon', 'poner', 'reproduce', 'reproducir', 'escoita', 'escoitar', 'abre',
    'o', 'a', 'os', 'as', 'un', 'unha', 'una', 'de', 'do', 'da', 'dos', 'das',
    'en', 'el', 'la', 'los', 'las', 'e', 'y',
    'ultimo', 'ultima', 'novo', 'nova', 'episodio', 'programa', 'capitulo',
    'cuac', 'fm', 'radio',
  };

  static const _liveAliases = {
    'radio comunitaria', 'comunitaria', 'continuidade',
    'en directo', 'directo', 'a emisora', 'emisora',
    '103.4', '103 4', '1034',
  };

  Program? _matchProgram(String normQuery, List<Program> programs) {
    final cleaned = _cleanQuery(normQuery);
    final target = cleaned.isNotEmpty ? cleaned : normQuery;
    Program? bySubstring;
    int bySubstringLen = 0;
    Program? byFuzzy;
    double byFuzzyScore = 0;
    for (final p in programs) {
      if (p.rssUrl.isEmpty) continue;
      final name = _normalize(p.name);
      if (name.isEmpty) continue;
      if (normQuery.contains(name) ||
          name.contains(normQuery) ||
          (cleaned.isNotEmpty &&
              (cleaned.contains(name) || name.contains(cleaned)))) {
        if (name.length > bySubstringLen) {
          bySubstringLen = name.length;
          bySubstring = p;
        }
        continue;
      }
      if (target.length >= 4) {
        final cleanedName = _cleanQuery(name);
        final score = math.max(
          _similarity(target, name),
          cleanedName.isEmpty ? 0.0 : _similarity(target, cleanedName),
        );
        if (score > byFuzzyScore) {
          byFuzzyScore = score;
          byFuzzy = p;
        }
      }
    }
    if (bySubstring != null) return bySubstring;
    if (byFuzzy != null && byFuzzyScore >= 0.6) return byFuzzy;
    return null;
  }

  String _cleanQuery(String normQuery) {
    return normQuery
        .split(' ')
        .where((t) => t.isNotEmpty && !_searchStopWords.contains(t))
        .join(' ');
  }

  double _similarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final distance = _levenshtein(a, b);
    final maxLen = math.max(a.length, b.length);
    return 1 - distance / maxLen;
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    var prev = List<int>.generate(t.length + 1, (i) => i);
    var curr = List<int>.filled(t.length + 1, 0);
    for (var i = 0; i < s.length; i++) {
      curr[0] = i + 1;
      for (var j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        curr[j + 1] = math.min(
          math.min(curr[j] + 1, prev[j + 1] + 1),
          prev[j] + cost,
        );
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[t.length];
  }

  Future<List<Program>> _allPrograms() async {
    if (_allProgramsCache.isNotEmpty) return _allProgramsCache;
    try {
      final result = await _repository.getAllPodcasts();
      if (result is Success) {
        _allProgramsCache = List<Program>.from(result.data ?? []);
      }
    } catch (_) {}
    return _allProgramsCache;
  }

  String _normalize(String input) {
    var s = input.toLowerCase();
    const accents = {
      'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'ã': 'a',
      'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
      'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
      'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o', 'õ': 'o',
      'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
      'ñ': 'n', 'ç': 'c',
    };
    final buffer = StringBuffer();
    for (final ch in s.split('')) {
      buffer.write(accents[ch] ?? ch);
    }
    return buffer
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _dispatchPlayFromMediaId(
      String mediaId, CurrentPlayerContract player) async {
    if (mediaId == 'live') {
      await _playLive(player);
      return;
    }
    if (mediaId.startsWith('recent|')) {
      final item = _recentByKey[mediaId];
      if (item == null) return;
      final episodes = await _episodesFor(item.rssUrl);
      if (episodes.isEmpty) return;
      final sorted = List<Episode>.from(episodes)
        ..sort((a, b) => (a.pubDate.difference(item.start).inSeconds.abs())
            .compareTo(b.pubDate.difference(item.start).inSeconds.abs()));
      await _playEpisode(player, sorted.first, item.name, item.logoUrl);
      return;
    }
    if (mediaId.startsWith('cont|')) {
      final audio = mediaId.substring(5);
      final m = _continueByAudio[audio];
      final episode = Episode.fromMap({
        'title': m?['title'] ?? '',
        'audio': audio,
        'link': audio,
      });
      await _playEpisode(player, episode,
          m?['programName'] as String? ?? episode.title,
          m?['logoUrl'] as String? ?? '');
      return;
    }
    if (mediaId.startsWith('ep|')) {
      final rest = mediaId.substring(3);
      final sep = rest.indexOf('|');
      if (sep < 0) return;
      final rssUrl = rest.substring(0, sep);
      final audio = rest.substring(sep + 1);
      final episodes = await _episodesFor(rssUrl);
      Episode? episode;
      for (final e in episodes) {
        if (e.audio == audio) episode = e;
      }
      if (episode == null) return;
      final program = _favoriteByRss[rssUrl];
      await _playEpisode(
          player, episode, program?.name ?? episode.title, program?.logoUrl ?? '');
      return;
    }
    if (mediaId == 'pl_all') {
      if (_playlistItems.isEmpty) await _loadPlaylistItems();
      if (_playlistItems.isEmpty) return;
      final item = _playlistItems.first;
      final episode = Episode.fromMap(item);
      final logo = await _freshLogoForProgram(
          item['programName'] as String?, item['logoUrl'] ?? '');
      await _playEpisode(
          player, episode, item['programName'] ?? episode.title, logo);
      return;
    }
    if (mediaId.startsWith('pl|')) {
      final audio = mediaId.substring(3);
      Map<String, dynamic>? item;
      for (final it in _playlistItems) {
        if (it['audio'] == audio) item = it;
      }
      if (item == null) return;
      final episode = Episode.fromMap(item);
      final logo = await _freshLogoForProgram(
          item['programName'] as String?, item['logoUrl'] ?? '');
      await _playEpisode(
          player, episode, item['programName'] ?? episode.title, logo);
    }
  }

  Future<void> _playLive(CurrentPlayerContract player) async {
    var now = _liveNow;
    if (now == null) {
      try {
        final result = await _repository.getLiveBroadcast();
        if (result is Success) now = result.data;
      } catch (_) {}
      now ??= Now.mock();
      _liveNow = now;
    }
    player.isPodcast = false;
    player.now = now;
    player.currentSong = now.name;
    player.currentImage = now.logoUrl;
    if (player.isPlaying()) {
      await player.stopAndPlay();
    } else {
      await player.play();
    }
  }

  Future<void> _playEpisode(CurrentPlayerContract player, Episode episode,
      String programName, String logoUrl) async {
    player.isPodcast = true;
    player.episode = episode;
    player.currentSong = programName;
    player.currentSubtitle = episode.title;
    player.currentImage = logoUrl.isNotEmpty ? logoUrl : _defaultProgrammeArt;
    if (player.isPlaying() || player.isPaused()) {
      await player.stopAndPlay();
    } else {
      await player.play();
    }
  }

  Map<String, dynamic> _gridStyle() => {
        _csBrowsableHint: _csGridItem,
        _csPlayableHint: _csGridItem,
        _csBrowsableHintLegacy: _csGridItem,
        _csPlayableHintLegacy: _csGridItem,
      };

  Map<String, dynamic> _homeStyle() => {
        _csBrowsableHint: _csGridItem,
        _csPlayableHint: _csListItem,
        _csBrowsableHintLegacy: _csGridItem,
        _csPlayableHintLegacy: _csListItem,
      };

  Map<String, dynamic> _group(String title) => {
        _csGroupTitleHint: title,
        _csGroupTitleHintLegacy: title,
      };

  Future<List<Program>> _discoverPrograms() async {
    List<Program> programs = [];
    try {
      final result = await _repository.getAllPodcasts();
      if (result is Success) programs = List<Program>.from(result.data ?? []);
    } catch (_) {}
    Box? cache;
    try {
      cache = Hive.box('episodes_cache');
    } catch (_) {}
    final withEpisodes = programs
        .where((p) => p.rssUrl.isNotEmpty && cache?.get(p.rssUrl) == true)
        .toList();
    final base = withEpisodes.isNotEmpty ? withEpisodes : <Program>[];
    if (base.isEmpty) return [];
    base.shuffle(math.Random(DateTime.now().year));
    final week = _isoWeek();
    final start = (week * 3) % base.length;
    final pick = <Program>[];
    for (int i = 0; i < 3 && i < base.length; i++) {
      pick.add(base[(start + i) % base.length]);
    }
    return pick;
  }

  int _isoWeek() {
    final now = DateTime.now();
    final jan4 = DateTime(now.year, 1, 4);
    final firstMonday = jan4.subtract(Duration(days: jan4.weekday - 1));
    return now.difference(firstMonday).inDays ~/ 7;
  }

  Uri _artUri(String url) {
    if (url.contains('cuac_music_cover')) {
      return Uri.parse(_musicCoverArt);
    }
    if (url.isEmpty ||
        url.startsWith('assets/') ||
        url.contains('default-programme-photo')) {
      return Uri.parse(_defaultProgrammeArt);
    }
    return Uri.parse(url);
  }
}
