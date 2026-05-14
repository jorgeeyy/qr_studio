import 'package:flutter/material.dart';

class RecentCodes extends StatefulWidget {
  const RecentCodes({super.key, required this.onHistory});

  final VoidCallback onHistory;

  @override
  State<RecentCodes> createState() => _RecentCodesState();
}

class _RecentCodesState extends State<RecentCodes> {
  @override
  Widget build(BuildContext context) {
    final recentCodes = [
      (
        icon: Icons.language,
        title: 'Portfolio Website',
        type: 'URL',
        date: 'May 15',
        iconBg: Colors.blue[50],
        iconColor: Colors.blue,
      ),
      (
        icon: Icons.wifi,
        title: 'Cafe Guest WiFi',
        type: 'WiFi',
        date: 'May 14',
        iconBg: Colors.green[50],
        iconColor: Colors.green,
      ),
      (
        icon: Icons.contact_page_outlined,
        title: 'John Doe Contact',
        type: 'Contact',
        date: 'May 12',
        iconBg: Colors.orange[50],
        iconColor: Colors.orange,
      ),
    ];

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
              onPressed: widget.onHistory,
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
          itemCount: recentCodes.length,
          separatorBuilder: (context, index) => SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = recentCodes[index];

            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: item.iconBg,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(item.icon, size: 30, color: item.iconColor),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${item.type} . ${item.date}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
