import 'package:flutter_test/flutter_test.dart';
import 'package:groceries_app/main.dart';
import 'package:material_ui/material_ui.dart';

Future<void> addItem(WidgetTester tester, String name) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextFormField, 'Name'), name);
  await tester.tap(find.text('Add Item'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Grocery list screen renders empty state', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Your Groceries'), findsOneWidget);
    expect(find.text('No items added yet.'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Form rejects an invalid name', (tester) async {
    await tester.pumpWidget(const MyApp());

    await addItem(tester, 'a');

    expect(find.text('Invalid name'), findsOneWidget);
    expect(find.text('Add a new item'), findsOneWidget);
  });

  testWidgets('Valid form adds an item to the list', (tester) async {
    await tester.pumpWidget(const MyApp());

    await addItem(tester, 'Milk');

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('No items added yet.'), findsNothing);
  });

  testWidgets('Swiped item can be restored with Undo', (tester) async {
    await tester.pumpWidget(const MyApp());

    await addItem(tester, 'Milk');
    await addItem(tester, 'Eggs');

    await tester.drag(find.text('Milk'), const Offset(-800, 0));
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsNothing);
    expect(find.text('Eggs'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Eggs'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Milk')).dy,
      lessThan(tester.getTopLeft(find.text('Eggs')).dy),
    );
  });
}
