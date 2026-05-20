import 'package:flutter_test/flutter_test.dart';
import 'package:dilapak/main.dart';

void main() {
  testWidgets('Dilapak app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DilapakApp());
    expect(find.byType(DilapakApp), findsOneWidget);
  });
}
