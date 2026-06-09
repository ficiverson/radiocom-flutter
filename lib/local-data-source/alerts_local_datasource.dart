import 'dart:convert';

import 'package:cuacfm/data/datasource/alerts_local_datasource_contract.dart';
import 'package:cuacfm/models/alert_record.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _hivePendingKey = 'alerts_list';
const _prefsPendingKey = 'pending_alerts';
const _prefsUnreadKey = 'alerts_unread_count';

class AlertsLocalDataSource implements AlertsLocalDataSourceContract {
  Box get _box => Hive.box('alerts');

  // Garda dende background (SharedPreferences, sen Hive). Static: chamado pre-DI.
  static Future<void> saveFromBackground(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsPendingKey) ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.add(data);
    await prefs.setString(_prefsPendingKey, jsonEncode(list));
    final unread = prefs.getInt(_prefsUnreadKey) ?? 0;
    await prefs.setInt(_prefsUnreadKey, unread + 1);
  }

  @override
  Future<void> migratePending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsPendingKey);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    for (final m in list) {
      _saveToHive(AlertRecord.fromMap(m));
    }
    await prefs.remove(_prefsPendingKey);
  }

  @override
  void saveFromForeground(Map<String, dynamic> data) {
    _saveToHive(AlertRecord.fromMap(data));
  }

  void _saveToHive(AlertRecord record) {
    final raw = _box.get(_hivePendingKey) as String? ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.insert(0, record.toMap());
    _box.put(_hivePendingKey, jsonEncode(list));
  }

  @override
  List<AlertRecord> getAlerts() {
    final raw = _box.get(_hivePendingKey) as String? ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((m) => AlertRecord.fromMap(m)).toList();
  }

  @override
  void cleanOldAlerts({int keepDays = 90}) {
    final raw = _box.get(_hivePendingKey) as String? ?? '[]';
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));
    final filtered = list
        .map((m) => AlertRecord.fromMap(m))
        .where((r) => r.receivedAt.isAfter(cutoff))
        .map((r) => r.toMap())
        .toList();
    _box.put(_hivePendingKey, jsonEncode(filtered));
  }

  @override
  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefsUnreadKey) ?? 0;
  }

  @override
  Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsUnreadKey, 0);
  }
}
