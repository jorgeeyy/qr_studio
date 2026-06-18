import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_studio/providers/history_provider.dart';
import 'package:qr_studio/utils/qr_helpers.dart';

class RecentCodes extends ConsumerWidget {
  const RecentCodes({super.key, required this.onHistory});

  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final items =
        historyAsync.whenOrNull(data: (list) => list.take(3).toList()) ?? [];

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.qr_code_2,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No QR codes yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Generate your first QR code and it will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Recent Codes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            TextButton(
              onPressed: onHistory,
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _ColorDot(color: item.foregroundColor),
                            const SizedBox(width: 4),
                            _ColorDot(
                              color: item.backgroundColor,
                              bordered: true,
                            ),
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
                ],
              ),
            );
          },
        ),
      ],
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
