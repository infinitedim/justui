import 'package:flutter_test/flutter_test.dart';
import 'package:preview/main.dart';

void main() {
  testWidgets('WidgetbookApp builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const WidgetbookApp());
    expect(find.byType(WidgetbookApp), findsOneWidget);
  });
}
