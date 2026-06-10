import 'package:flutter_test/flutter_test.dart';
import 'package:beetle_app/main.dart';

void main() {
  testWidgets('BeetleApp loads', (WidgetTester tester) async {
    await tester.pumpWidget(const BeetleApp());
    expect(find.text('Nhận diện bọ cánh cứng'), findsOneWidget);
  });
}

