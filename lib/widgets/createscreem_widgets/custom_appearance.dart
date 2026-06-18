import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_studio/utils/qr_shapes.dart';

class CustomAppearance extends StatefulWidget {
  const CustomAppearance({
    super.key,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.eyeStyle,
    required this.bodyStyle,
    required this.onForegroundChanged,
    required this.onBackgroundChanged,
    required this.onEyeShapeChanged,
    required this.onBodyShapeChanged,
    required this.onLogoChanged,
    required this.onLogoPositionChanged,
    this.logoPosition = PrettyQrDecorationImagePosition.embedded,
  });

  final Color foregroundColor;
  final Color backgroundColor;
  final QrStyle eyeStyle;
  final QrStyle bodyStyle;
  final ValueChanged<Color> onForegroundChanged;
  final ValueChanged<Color> onBackgroundChanged;
  final ValueChanged<QrStyle> onEyeShapeChanged;
  final ValueChanged<QrStyle> onBodyShapeChanged;
  final ValueChanged<ImageProvider?> onLogoChanged;
  final ValueChanged<PrettyQrDecorationImagePosition> onLogoPositionChanged;
  final PrettyQrDecorationImagePosition logoPosition;

  @override
  State<CustomAppearance> createState() => _CustomAppearanceState();
}

class _CustomAppearanceState extends State<CustomAppearance> {
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      widget.onLogoChanged(FileImage(File(image.path)));
    }
  }

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
        side: BorderSide(color: Colors.transparent), // Remove default border
      ),
      isScrollControlled:
          true, // Allows sheet to size properly and avoid keyboard/compact screen issues
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.sizeOf(context).height;
        final isSmallScreen = screenHeight < 700;
        Color selectedColor = initialColor;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: 16,
            ),
            height: isSmallScreen ? screenHeight * 0.55 : 380,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isForeground ? 'Pick Foreground' : 'Pick Background',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter setModalState) {
                            return HueRingPicker(
                              pickerColor: selectedColor,
                              onColorChanged: (Color color) {
                                final opaqueColor = color.withValues(
                                  alpha: 1.0,
                                );
                                setModalState(() {
                                  selectedColor = opaqueColor;
                                });
                                if (isForeground) {
                                  widget.onForegroundChanged(opaqueColor);
                                } else {
                                  widget.onBackgroundChanged(opaqueColor);
                                }
                              },
                              enableAlpha: false,
                              displayThumbColor: true,
                              colorPickerHeight: isSmallScreen ? 180 : 250,
                            );
                          },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShapePicker({required bool isBody, required QrStyle currentStyle}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isBody ? 'Select Inner Body Shape' : 'Select Outer Eye Shape',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildShapeOption(
                          title: 'Square (Classic)',
                          icon: isBody ? Icons.grid_on : Icons.crop_square,
                          value: QrStyle.square,
                          currentValue: currentStyle,
                          isBody: isBody,
                        ),
                        _buildShapeOption(
                          title: 'Rounded Squares',
                          icon: Icons.check_box_outline_blank,
                          value: QrStyle.rounded,
                          currentValue: currentStyle,
                          isBody: isBody,
                        ),
                        _buildShapeOption(
                          title: isBody ? 'Dots' : 'Dots (Rounded)',
                          icon: Icons.lens_blur,
                          value: QrStyle.dots,
                          currentValue: currentStyle,
                          isBody: isBody,
                        ),
                        _buildShapeOption(
                          title: isBody ? 'Smooth' : 'Smooth (Circle)',
                          icon: isBody ? Icons.waves : Icons.circle_outlined,
                          value: QrStyle.smooth,
                          currentValue: currentStyle,
                          isBody: isBody,
                        ),
                        _buildShapeOption(
                          title: 'Diamond',
                          icon: Icons.diamond_outlined,
                          value: QrStyle.diamond,
                          currentValue: currentStyle,
                          isBody: isBody,
                        ),
                        _buildShapeOption(
                          title: 'Star',
                          icon: Icons.star_border,
                          value: QrStyle.star,
                          currentValue: currentStyle,
                          isBody: isBody,
                        ),
                        _buildShapeOption(
                          title: 'Hexagon',
                          icon: Icons.hexagon_outlined,
                          value: QrStyle.hexagon,
                          currentValue: currentStyle,
                          isBody: isBody,
                        ),
                        _buildShapeOption(
                          title: 'Leaf',
                          icon: Icons.eco_outlined,
                          value: QrStyle.leaf,
                          currentValue: currentStyle,
                          isBody: isBody,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShapeOption({
    required String title,
    required IconData icon,
    required QrStyle value,
    required QrStyle currentValue,
    required bool isBody,
  }) {
    final isSelected = value == currentValue;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 4.0,
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isSelected
              ? Colors.blue[400]
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? Colors.blue[400]
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Colors.blue[400], size: 28)
          : null,
      onTap: () {
        if (isBody) {
          widget.onBodyShapeChanged(value);
        } else {
          widget.onEyeShapeChanged(value);
        }
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCurrentShapeDisplay({
    required QrStyle currentStyle,
    required bool isBody,
  }) {
    String title;
    IconData icon;
    switch (currentStyle) {
      case QrStyle.square:
        title = 'Square';
        icon = isBody ? Icons.grid_on : Icons.crop_square;
        break;
      case QrStyle.rounded:
        title = 'Rounded';
        icon = Icons.check_box_outline_blank;
        break;
      case QrStyle.dots:
        title = 'Dots';
        icon = Icons.lens_blur;
        break;
      case QrStyle.smooth:
        title = 'Smooth';
        icon = isBody ? Icons.waves : Icons.circle_outlined;
        break;
      case QrStyle.diamond:
        title = 'Diamond';
        icon = Icons.diamond_outlined;
        break;
      case QrStyle.star:
        title = 'Star';
        icon = Icons.star_border;
        break;
      case QrStyle.hexagon:
        title = 'Hexagon';
        icon = Icons.hexagon_outlined;
        break;
      case QrStyle.leaf:
        title = 'Leaf';
        icon = Icons.eco_outlined;
        break;
    }

    return GestureDetector(
      onTap: () => _showShapePicker(isBody: isBody, currentStyle: currentStyle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.blue[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Appearance'.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Color Picker',
            style: TextStyle(fontSize: 14, color: Colors.white),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Foreground', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 6),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Background', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 6),
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
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'body shape'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildCurrentShapeDisplay(
                      currentStyle: widget.bodyStyle,
                      isBody: true,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'eye shape'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildCurrentShapeDisplay(
                      currentStyle: widget.eyeStyle,
                      isBody: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'logo upload'.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                for (final pos in PrettyQrDecorationImagePosition.values)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onLogoPositionChanged(pos),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: widget.logoPosition == pos
                              ? Colors.blue[700]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          pos.name[0].toUpperCase() + pos.name.substring(1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.logoPosition == pos
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    size: 24,
                    color: Colors.blue[400],
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Upload Logo',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[400],
                      fontWeight: FontWeight.w600,
                    ),
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
