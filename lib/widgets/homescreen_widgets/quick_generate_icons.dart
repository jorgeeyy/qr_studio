import 'package:flutter/material.dart';

class QuickGenerateIcons extends StatelessWidget {
  const QuickGenerateIcons({super.key});

  @override
  Widget build(BuildContext context) {
    const cardData = [
      (
        icon: Icons.language,
        title: 'Website',
        iconColor: Colors.blue,
        bgColor: Color(0xFFDCEBFF),
      ),
      (
        icon: Icons.wifi,
        title: 'WiFi',
        iconColor: Colors.black,
        bgColor: Color(0xFFE9EEF3),
      ),
      (
        icon: Icons.contact_page_outlined,
        title: 'Contact',
        iconColor: Colors.black,
        bgColor: Color(0xFFFCE4EC),
      ),
      // (icon: Icons.image_outlined, title: 'Background Image'),
    ];

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Quick Generate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
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
              return SizedBox(
                width: 120,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
                            color: Colors.black,
                          ),
                        ),
                      ],
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
