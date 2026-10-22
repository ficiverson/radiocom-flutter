import 'dart:convert';

import 'package:cuacfm/data/datasource/episode_progress_local_datasource_contract.dart';
import 'package:hive/hive.dart';

const _boxName = 'episode_progress';
const _completedRatio = 0.97;

class EpisodeProgressLocalDataSource
    implements EpisodeProgressLocalDataSourceContract {
  Box? get _box {
    try {
      return Hive.box(_boxName);
    } catch (_) {
      return null;
    }
  }

  @override
  void save(String episodeId, int positionSeconds, int durationSeconds,
      {String? title, String? programName, String? logoUrl}) {
    final box = _box;
    if (box == null || episodeId.isEmpty || durationSeconds <= 0) return;
    if (positionSeconds < 0) positionSeconds = 0;
    final completed = positionSeconds >= durationSeconds * _completedRatio;
    final existing = getProgress(episodeId);
    box.put(episodeId, jsonEncode({
      'position': positionSeconds,
      'duration': durationSeconds,
      'completed': completed,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'title': title ?? existing?['title'] ?? '',
      'programName': programName ?? existing?['programName'] ?? '',
      'logoUrl': logoUrl ?? existing?['logoUrl'] ?? '',
    }));
  }

  @override
  void markCompleted(String episodeId, int durationSeconds) {
    final box = _box;
    if (box == null || episodeId.isEmpty) return;
    final existing = getProgress(episodeId);
    box.put(episodeId, jsonEncode({
      'position': durationSeconds,
      'duration': durationSeconds,
      'completed': true,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'title': existing?['title'] ?? '',
      'programName': existing?['programName'] ?? '',
      'logoUrl': existing?['logoUrl'] ?? '',
    }));
  }

  @override
  Map<String, dynamic>? getProgress(String episodeId) {
    final box = _box;
    if (box == null || episodeId.isEmpty) return null;
    final raw = box.get(episodeId) as String?;
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Map<String, Map<String, dynamic>> getAll() {
    final box = _box;
    if (box == null) return {};
    final result = <String, Map<String, dynamic>>{};
    for (final key in box.keys) {
      final raw = box.get(key) as String?;
      if (raw != null) {
        result[key.toString()] = jsonDecode(raw) as Map<String, dynamic>;
      }
    }
    return result;
  }
}
