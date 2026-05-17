# QR Studio

A highly polished, feature-rich QR Code Generator built with Flutter.

## Features

- **Custom Designs**: Create classic or rounded QR codes.
- **Color Picking**: Fully customize foreground and background colors with an intuitive Hue Ring picker.
- **Logo Integration**: Upload custom logos to nest directly inside the QR code securely without breaking scannability (uses high error correction).
- **Background Removal**: Automatically strip solid backgrounds from uploaded logos (e.g., white or black corners) right on the device using Dart's native `image` processing.
- **High-Quality Exports**: Export the finalized QR code in **PNG**, **SVG**, or **PDF** format (built for high DPI print quality).
- **Native Sharing**: Instantly share the generated QR code straight from your device to other apps.

## Tech Stack & Packages

- **`qr_flutter`**: Renders the core QR code and handles error correction capabilities.
- **`flutter_colorpicker`**: Powers the clean, Apple-style Hue Ring for intuitive color selection.
- **`image`**: Provides raw pixel manipulation to natively strip solid color backgrounds from imported logo images.
- **`image_picker`**: Enables the user to fetch logos from their gallery.
- **`file_saver` & `share_plus`**: Facilitates native exporting, downloading, and social sharing capabilities across platforms.
- **`pdf`**: Directly vectorizes the QR representation into PDF documents.

## Getting Started

1. **Clone the repository.**
2. Run `flutter pub get` to install all dependencies.
3. Run `flutter run` to launch on your preferred device (iOS/Android/Web/Desktop).

---
*Built with ❤️ in Flutter.*
