import 'package:cuacfm/models/episode.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PlaylistService {
  final Box _box = Hive.box('playlist');

  // A orde gárdase como lista de claves (URLs de audio) nunha entrada especial
  static const _orderKey = '__order__';

  List<String> _getOrder() {
    final raw = _box.get(_orderKey);
    if (raw == null) return [];
    return List<String>.from(raw);
  }

  void _saveOrder(List<String> order) {
    _box.put(_orderKey, order);
  }

  void addEpisode(Episode episode, String programName, String logoUrl) {
    final key = episode.audio;
    if (_box.containsKey(key)) return;
    _box.put(key, {
      'title': episode.title,
      'audio': episode.audio,
      'link': episode.link,
      'description': episode.description,
      'pubDate': episode.pubDate.toIso8601String(),
      'duration': episode.duration,
      'programName': programName,
      'logoUrl': logoUrl,
    });
    final order = _getOrder()..add(key);
    _saveOrder(order);
  }

  void addEpisodeAtStart(Episode episode, String programName, String logoUrl) {
    final key = episode.audio;
    _box.put(key, {
      'title': episode.title,
      'audio': episode.audio,
      'link': episode.link,
      'description': episode.description,
      'pubDate': episode.pubDate.toIso8601String(),
      'duration': episode.duration,
      'programName': programName,
      'logoUrl': logoUrl,
    });
    final order = _getOrder()..remove(key);
    order.insert(0, key);
    _saveOrder(order);
  }

  void removeEpisode(String audioUrl) {
    _box.delete(audioUrl);
    final order = _getOrder()..remove(audioUrl);
    _saveOrder(order);
  }

  void clearAll() {
    _box.clear();
  }

  bool isInPlaylist(String audioUrl) {
    return _box.containsKey(audioUrl) && audioUrl != _orderKey;
  }

  List<Map<String, dynamic>> getRawItems() {
    final order = _getOrder();
    final result = <Map<String, dynamic>>[];
    for (final key in order) {
      final raw = _box.get(key);
      if (raw != null) {
        result.add(Map<String, dynamic>.from(raw));
      }
    }
    return result;
  }

  List<Episode> getEpisodes() {
    return getRawItems().map((e) => Episode.fromMap(e)).toList();
  }

  String programNameForAudio(String audioUrl) {
    final raw = _box.get(audioUrl);
    if (raw == null) return '';
    return Map<String, dynamic>.from(raw)['programName'] ?? '';
  }

  String logoUrlForAudio(String audioUrl) {
    final raw = _box.get(audioUrl);
    if (raw == null) return '';
    return Map<String, dynamic>.from(raw)['logoUrl'] ?? '';
  }

  void reorderFromList(List<Map<String, dynamic>> items) {
    final order = items.map((m) => m['audio'] as String).toList();
    _saveOrder(order);
  }
}
