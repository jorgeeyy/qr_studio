import 'package:flutter/material.dart';

class CustomAppearance extends StatefulWidget {
  const CustomAppearance({super.key});

  @override
  State<CustomAppearance> createState() => _CustomAppearanceState();
}

class _CustomAppearanceState extends State<CustomAppearance> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Appearance'.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Color Picker',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Foreground',
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.palette, size: 16, color: Colors.grey[800]),
                  ],
                ),
              ),
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Background',
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.format_color_fill,
                      size: 16,
                      color: Colors.grey[800],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Shape selector'.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.qr_code, size: 24, color: Colors.grey[800]),
                    SizedBox(width: 8),
                    Text(
                      'Classic',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle_outlined,
                      size: 24,
                      color: Colors.grey[800],
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Rounded',
                      style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'logo upload'.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.file_upload_outlined,
                  size: 24,
                  color: Colors.blue[800],
                ),
                SizedBox(width: 8),
                Text(
                  'Upload Logo',
                  style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
