import 'package:flutter_test/flutter_test.dart';
import 'package:digi_khata/main.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DigiKhataApp());
    expect(find.text('Digi Khata'), findsOneWidget);
  });
}
