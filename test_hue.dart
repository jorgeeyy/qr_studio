import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  HueRingPicker(
    pickerColor: Colors.red,
    onColorChanged: (c) {},
    enableAlpha: false,
    displayThumbColor: true,
  );
}
