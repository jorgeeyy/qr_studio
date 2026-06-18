import 'package:flutter/material.dart';
import 'package:qr_studio/models/qr_create_type.dart';

class QuickGenerateIcons extends StatelessWidget {
  const QuickGenerateIcons({super.key, required this.onTypeTap});

  final ValueChanged<QrCreateType> onTypeTap;

  @override
  Widget build(BuildContext context) {
    final cardData = [
      (
        icon: Icons.language,
        title: 'Website',
        iconColor: Colors.blue[400]!,
        bgColor: Colors.blue.withValues(alpha: 0.15),
        type: QrCreateType.website,
      ),
      (
        icon: Icons.wifi,
        title: 'WiFi',
        iconColor: Colors.teal[300]!,
        bgColor: Colors.green.withValues(alpha: 0.15),
        type: QrCreateType.wifi,
      ),
      (
        icon: Icons.campaign,
        title: 'Socials',
        iconColor: Colors.orange[300]!,
        bgColor: Colors.orange.withValues(alpha: 0.15),
        type: QrCreateType.contact,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Quick Generate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: cardData.length,
            separatorBuilder: (context, index) => SizedBox(width: 10),
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => onTypeTap(cardData[index].type),
                child: SizedBox(
                  width: 120,
                  child: Card(
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    elevation: 0.1,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: cardData[index].bgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              cardData[index].icon,
                              size: 18,
                              color: cardData[index].iconColor,
                            ),
                          ),
                          Spacer(),
                          Text(
                            cardData[index].title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              // fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
