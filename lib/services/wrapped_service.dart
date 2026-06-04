import 'dart:convert';
import 'package:hive/hive.dart';

const _sessionsKey = 'sessions';
const _minSessionSeconds = 30;

class WrappedService {
  static final WrappedService _instance = WrappedService._internal();
  factory WrappedService() => _instance;
  WrappedService._internal();

  DateTime? _sessionStart;
  bool _isPodcast = false;
  String _programName = '';
  String _category = '';
  String _episodeTitle = '';
  String _episodeId = '';

  String get _boxName => 'wrapped_${DateTime.now().year}';

  Box? get _box {
    try {
      return Hive.box(_boxName);
    } catch (_) {
      return null;
    }
  }

  // Chamado ao iniciar reprodución
  void startSession({
    required bool isPodcast,
    String programName = '',
    String category = '',
    String episodeTitle = '',
    String episodeId = '',
  }) {
    _sessionStart = DateTime.now();
    _isPodcast = isPodcast;
    _programName = programName;
    _category = category;
    _episodeTitle = episodeTitle;
    _episodeId = episodeId;
  }

  // Chamado ao deter a reprodución
  void endSession() {
    final start = _sessionStart;
    if (start == null) return;
    final durationSeconds = DateTime.now().difference(start).inSeconds;
    _sessionStart = null;
    if (durationSeconds < _minSessionSeconds) return;
    _saveSession(durationSeconds);
  }

  void _saveSession(int durationSeconds) {
    final box = _box;
    if (box == null) return;
    final now = DateTime.now();
    final raw = box.get(_sessionsKey) as String? ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    final isRepeat = _isPodcast && _episodeId.isNotEmpty &&
        list.any((s) =>
            s['type'] == 'podcast' &&
            s['episodeId'] == _episodeId);

    list.add({
      'type': _isPodcast ? 'podcast' : 'live',
      'programName': _programName,
      'category': _category,
      'episodeTitle': _episodeTitle,
      'episodeId': _episodeId,
      'durationSeconds': durationSeconds,
      'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'month': now.month,
      'year': now.year,
      'isRepeat': isRepeat,
    });
    box.put(_sessionsKey, jsonEncode(list));
  }

  // Chamado ao engadir ou eliminar favorito
  void recordFavoriteChange(String programName, bool added) {
    final box = _box;
    if (box == null) return;
    final now = DateTime.now();
    final raw = box.get(_sessionsKey) as String? ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.add({
      'type': 'favorite',
      'action': added ? 'add' : 'remove',
      'programName': programName,
      'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'month': now.month,
      'year': now.year,
    });
    box.put(_sessionsKey, jsonEncode(list));
  }

  // Limpa datos de anos anteriores (chamar en febreiro)
  static Future<void> cleanOldData() async {
    final currentYear = DateTime.now().year;
    for (final year in [currentYear - 2, currentYear - 3]) {
      final name = 'wrapped_$year';
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).clear();
      } else {
        try {
          final box = await Hive.openBox(name);
          await box.clear();
        } catch (_) {}
      }
    }
  }

  List<Map<String, dynamic>> getSessions() {
    final box = _box;
    if (box == null) return [];
    final raw = box.get(_sessionsKey) as String? ?? '[]';
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }
}
