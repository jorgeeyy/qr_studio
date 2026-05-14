import 'package:flutter/material.dart';
import 'package:qr_studio/widgets/createscreem_widgets/preview.dart';
import 'package:qr_studio/widgets/createscreem_widgets/url_create.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const createData = [
      (icon: Icons.link, title: 'URL'),
      (icon: Icons.wifi, title: 'WiFi'),
      (icon: Icons.contact_page_outlined, title: 'Contact'),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final item = createData[index];
                    return Container(
                      width: 100,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.grey[300],
                      ),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 20),
                          SizedBox(width: 8),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(width: 20),
                  itemCount: createData.length,
                ),
              ),
              SizedBox(height: 20),
              Preview(),
              SizedBox(height: 10),
              UrlCreate(),
            ],
          ),
        ),
      ),
    );
  }
}
