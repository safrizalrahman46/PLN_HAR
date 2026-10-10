import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const PLNHARApp());
    expect(find.byType(PLNHARApp), findsOneWidget);
  });
}
