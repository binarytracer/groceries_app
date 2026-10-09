import 'package:flutter_test/flutter_test.dart';
import 'package:groceries_app/main.dart';

void main() {
  testWidgets('Grocery list screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Grocery List'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);
  });
}
