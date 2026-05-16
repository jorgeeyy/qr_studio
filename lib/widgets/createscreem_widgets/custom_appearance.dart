import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

class CustomAppearance extends StatefulWidget {
  const CustomAppearance({
    super.key,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.isRounded,
    required this.onForegroundChanged,
    required this.onBackgroundChanged,
    required this.onShapeChanged,
    required this.onLogoChanged,
  });

  final Color foregroundColor;
  final Color backgroundColor;
  final bool isRounded;
  final ValueChanged<Color> onForegroundChanged;
  final ValueChanged<Color> onBackgroundChanged;
  final ValueChanged<bool> onShapeChanged;
  final ValueChanged<ImageProvider?> onLogoChanged;

  @override
  State<CustomAppearance> createState() => _CustomAppearanceState();
}

class _CustomAppearanceState extends State<CustomAppearance> {
  void _showColorPicker({
    required bool isForeground,
    required Color currentColor,
  }) {
    // Standardize to opaque color since we disabled alpha picking,
    // to prevent picking invisible colors if the initial color was transparent.
    final Color initialColor = currentColor == Colors.transparent
        ? Colors.white
        : currentColor.withValues(alpha: 1.0);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isForeground ? 'Pick Foreground' : 'Pick Background',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ColorPicker(
                  pickerColor: initialColor,
                  onColorChanged: (Color color) {
                    final opaqueColor = color.withValues(alpha: 1.0);
                    if (isForeground) {
                      widget.onForegroundChanged(opaqueColor);
                    } else {
                      widget.onBackgroundChanged(opaqueColor);
                    }
                  },
                  colorPickerWidth: 220,
                  pickerAreaHeightPercent: 0.4,
                  enableAlpha: false,
                  labelTypes: const [],
                  displayThumbColor: true,
                  portraitOnly: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ImagePicker _picker = ImagePicker();

    Future<void> _pickImage() async {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        widget.onLogoChanged(FileImage(File(image.path)));
      }
    }

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
              Expanded(
                child: GestureDetector(
                  onTap: () => _showColorPicker(
                    isForeground: true,
                    currentColor: widget.foregroundColor,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Foreground', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Icon(
                          Icons.palette,
                          size: 16,
                          color: widget.foregroundColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showColorPicker(
                    isForeground: false,
                    currentColor: widget.backgroundColor,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Background', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Icon(
                          Icons.format_color_fill,
                          size: 16,
                          color: widget.backgroundColor == Colors.transparent
                              ? Colors.grey
                              : widget.backgroundColor,
                        ),
                      ],
                    ),
                  ),
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
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onShapeChanged(false),
                  child: Container(
                    decoration: BoxDecoration(
                      color: !widget.isRounded
                          ? Colors.blue[50]
                          : Colors.grey[100],
                      border: Border.all(
                        color: !widget.isRounded
                            ? Colors.blue
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 24,
                          color: !widget.isRounded
                              ? Colors.blue
                              : Colors.grey[800],
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Classic',
                          style: TextStyle(
                            fontSize: 14,
                            color: !widget.isRounded
                                ? Colors.blue
                                : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onShapeChanged(true),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isRounded
                          ? Colors.blue[50]
                          : Colors.grey[100],
                      border: Border.all(
                        color: widget.isRounded
                            ? Colors.blue
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle_outlined,
                          size: 24,
                          color: widget.isRounded
                              ? Colors.blue
                              : Colors.grey[800],
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Rounded',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isRounded
                                ? Colors.blue
                                : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
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
          GestureDetector(
            onTap: _pickImage,
            child: Container(
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
          ),
        ],
      ),
    );
  }
}
