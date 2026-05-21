import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_studio/models/qr_history_item.dart';
import 'package:qr_studio/services/qr_history_service.dart';

class HistoryNotifier extends AsyncNotifier<List<QrHistoryItem>> {
  @override
  Future<List<QrHistoryItem>> build() => QrHistoryService.getHistory();

  Future<void> addItem(QrHistoryItem item) async {
    await QrHistoryService.addItem(item);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteItem(String id) async {
    await QrHistoryService.deleteItem(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> clearAll() async {
    await QrHistoryService.clearHistory();
    ref.invalidateSelf();
    await future;
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<QrHistoryItem>>(
      HistoryNotifier.new,
    );
