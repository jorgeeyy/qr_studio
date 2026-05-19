import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_studio/models/qr_history_item.dart';

class QrHistoryService {
  static const _key = 'qr_history';
  static const _maxItems = 50;

  static Future<List<QrHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map(QrHistoryItem.fromJsonString).toList();
  }

  static Future<void> addItem(QrHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getHistory();
    items.insert(0, item);
    if (items.length > _maxItems) {
      items.removeRange(_maxItems, items.length);
    }
    await prefs.setStringList(
      _key,
      items.map((e) => e.toJsonString()).toList(),
    );
  }

  static Future<void> deleteItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getHistory();
    items.removeWhere((e) => e.id == id);
    await prefs.setStringList(
      _key,
      items.map((e) => e.toJsonString()).toList(),
    );
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
