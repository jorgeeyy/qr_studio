import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_studio/models/qr_history_item.dart';
import 'package:qr_studio/providers/history_provider.dart';
import 'package:qr_studio/utils/qr_helpers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Delete all QR code history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear All', style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(historyProvider.notifier).clearAll();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  historyAsync.whenOrNull(
                        data: (items) => items.isNotEmpty
                            ? TextButton.icon(
                                onPressed: () => _clearAll(context, ref),
                                icon: Icon(
                                  Icons.delete_sweep,
                                  color: Colors.red[600],
                                  size: 18,
                                ),
                                label: Text(
                                  'Clear All',
                                  style: TextStyle(color: Colors.red[600]),
                                ),
                              )
                            : null,
                      ) ??
                      const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: historyAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.qr_code_2,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No history yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Generated QR codes will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => ref.refresh(historyProvider.future),
                      child: ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _HistoryCard(
                            item: item,
                            onDelete: () => ref
                                .read(historyProvider.notifier)
                                .deleteItem(item.id),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final QrHistoryItem item;
  final VoidCallback onDelete;

  const _HistoryCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: () => _showQrDialog(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: PrettyQrView.data(
                    data: item.qrData,
                    decoration: PrettyQrDecoration(
                      // ignore: experimental_member_use
                      shape: PrettyQrShape.custom(
                        getQrShape(item.bodyStyle, item.foregroundColor),
                        finderPattern: getQrShape(
                          item.eyeStyle,
                          item.foregroundColor,
                        ),
                      ),
                      background: item.backgroundColor,
                      image: item.logoPath != null
                          ? PrettyQrDecorationImage(
                              image: FileImage(File(item.logoPath!)),
                              scale: 0.35,
                              position: item.logoPosition,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qrLabel(item.qrData),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(item.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _ColorDot(color: item.foregroundColor),
                        const SizedBox(width: 4),
                        _ColorDot(color: item.backgroundColor, bordered: true),
                        const SizedBox(width: 6),
                        Text(
                          item.bodyStyle.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      qrLabel(item.qrData),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: PrettyQrView.data(
                    data: item.qrData,
                    decoration: PrettyQrDecoration(
                      // ignore: experimental_member_use
                      shape: PrettyQrShape.custom(
                        getQrShape(item.bodyStyle, item.foregroundColor),
                        finderPattern: getQrShape(
                          item.eyeStyle,
                          item.foregroundColor,
                        ),
                      ),
                      background: item.backgroundColor,
                      image: item.logoPath != null
                          ? PrettyQrDecorationImage(
                              image: FileImage(File(item.logoPath!)),
                              scale: 0.35,
                              position: item.logoPosition,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                formatDate(item.createdAt),
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool bordered;
  const _ColorDot({required this.color, this.bordered = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: bordered
            ? Border.all(color: Colors.grey[700]!, width: 1)
            : null,
      ),
    );
  }
}
