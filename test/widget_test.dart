import 'package:flutter_test/flutter_test.dart';
import 'package:qr_studio/main.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('QR Studio'), findsOneWidget);
  });
}
