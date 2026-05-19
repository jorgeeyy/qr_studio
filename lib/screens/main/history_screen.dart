import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_studio/models/qr_history_item.dart';
import 'package:qr_studio/services/qr_history_service.dart';
import 'package:qr_studio/utils/qr_shapes.dart';
import 'package:qr_studio/utils/custom_qr_shapes.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<QrHistoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await QrHistoryService.getHistory();
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  Future<void> _deleteItem(String id) async {
    await QrHistoryService.deleteItem(id);
    setState(() => _items.removeWhere((e) => e.id == id));
  }

  Future<void> _clearAll() async {
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
      await QrHistoryService.clearHistory();
      setState(() => _items = []);
    }
  }

  // ignore: experimental_api
  PrettyQrShape _getShape(QrStyle style, Color color) {
    switch (style) {
      case QrStyle.rounded:
        return PrettyQrRoundedSymbol(color: color);
      case QrStyle.dots:
        return PrettyQrSmoothSymbol(color: color, roundFactor: 1);
      case QrStyle.smooth:
        return PrettyQrSmoothSymbol(color: color);
      case QrStyle.diamond:
        return QrDiamondShape(color: color);
      case QrStyle.star:
        return QrStarShape(color: color);
      case QrStyle.hexagon:
        return QrHexagonShape(color: color);
      case QrStyle.leaf:
        return QrLeafShape(color: color);
      case QrStyle.square:
        return PrettyQrRoundedSymbol(
          color: color,
          borderRadius: BorderRadius.zero,
        );
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'History',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_items.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearAll,
                      icon: Icon(
                        Icons.delete_sweep,
                        color: Colors.red[600],
                        size: 18,
                      ),
                      label: Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2, size: 64, color: Colors.grey[300]),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          return _HistoryCard(
            item: item,
            getShape: _getShape,
            formatDate: _formatDate,
            onDelete: () => _deleteItem(item.id),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final QrHistoryItem item;
  final PrettyQrShape Function(QrStyle, Color) getShape;
  final String Function(DateTime) formatDate;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.item,
    required this.getShape,
    required this.formatDate,
    required this.onDelete,
  });

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
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
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
                    // ignore: experimental_api
                    shape: PrettyQrShape.custom(
                      getShape(item.bodyStyle, item.foregroundColor),
                      finderPattern: getShape(
                        item.eyeStyle,
                        item.foregroundColor,
                      ),
                    ),
                    background: item.backgroundColor,
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
                    item.qrData,
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
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
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
