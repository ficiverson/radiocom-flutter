import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _hivePendingKey = 'alerts_list';
const _prefsPendingKey = 'pending_alerts';
const _prefsUnreadKey = 'alerts_unread_count';

class AlertRecord {
  final String programName;
  final String programLogoUrl;
  final String rssUrl;
  final String episodeTitle;
  final String episodeId;
  final DateTime receivedAt;

  AlertRecord({
    required this.programName,
    required this.programLogoUrl,
    required this.rssUrl,
    required this.episodeTitle,
    required this.episodeId,
    required this.receivedAt,
  });

  Map<String, dynamic> toMap() => {
    'programName': programName,
    'programLogoUrl': programLogoUrl,
    'rssUrl': rssUrl,
    'episodeTitle': episodeTitle,
    'episodeId': episodeId,
    'receivedAt': receivedAt.toIso8601String(),
  };

  factory AlertRecord.fromMap(Map<String, dynamic> m) => AlertRecord(
    programName: m['programName'] ?? '',
    programLogoUrl: m['programLogoUrl'] ?? '',
    rssUrl: m['rssUrl'] ?? '',
    episodeTitle: m['episodeTitle'] ?? '',
    episodeId: m['episodeId'] ?? '',
    receivedAt: DateTime.tryParse(m['receivedAt'] ?? '') ?? DateTime.now(),
  );
}

class AlertsService {
  Box get _box => Hive.box('alerts');

  // Garda dende background (SharedPreferences, sen Hive)
  static Future<void> saveFromBackground(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsPendingKey) ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.add(data);
    await prefs.setString(_prefsPendingKey, jsonEncode(list));
    final unread = prefs.getInt(_prefsUnreadKey) ?? 0;
    await prefs.setInt(_prefsUnreadKey, unread + 1);
  }

  // Migra pendentes de SharedPreferences a Hive ao arrancar a app
  Future<void> migratePending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsPendingKey);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    for (final m in list) {
      final record = AlertRecord.fromMap(m);
      _saveToHive(record);
    }
    await prefs.remove(_prefsPendingKey);
  }

  // Garda dende foreground directamente en Hive
  void saveFromForeground(Map<String, dynamic> data) {
    _saveToHive(AlertRecord.fromMap(data));
  }

  void _saveToHive(AlertRecord record) {
    final raw = _box.get(_hivePendingKey) as String? ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.insert(0, record.toMap());
    _box.put(_hivePendingKey, jsonEncode(list));
  }

  // Devolve só alertas do mes actual
  List<AlertRecord> getAlerts() {
    final raw = _box.get(_hivePendingKey) as String? ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final now = DateTime.now();
    return list
        .map((m) => AlertRecord.fromMap(m))
        .where((r) => r.receivedAt.year == now.year && r.receivedAt.month == now.month)
        .toList();
  }

  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefsUnreadKey) ?? 0;
  }

  Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsUnreadKey, 0);
  }
}
