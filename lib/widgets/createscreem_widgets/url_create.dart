import 'package:flutter/material.dart';

class UrlCreate extends StatefulWidget {
  const UrlCreate({super.key, required this.onChanged, this.controller});

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  State<UrlCreate> createState() => _UrlCreateState();
}

class _UrlCreateState extends State<UrlCreate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'enter destination url'.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: 'https://example.com',
              fillColor: Colors.grey[50],
              filled: true,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              suffixIcon: Icon(Icons.link, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}
