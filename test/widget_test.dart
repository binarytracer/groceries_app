import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:groceries_app/data/categories.dart';
import 'package:groceries_app/main.dart';
import 'package:groceries_app/models/category.dart';
import 'package:groceries_app/models/grocery_item.dart';
import 'package:groceries_app/providers/grocery_providers.dart';
import 'package:material_ui/material_ui.dart';

import 'support/fake_grocery_repository.dart';

Future<void> pumpApp(WidgetTester tester, FakeGroceryRepository repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [groceryRepositoryProvider.overrideWithValue(repo)],
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> addItem(WidgetTester tester, String name) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  await tester.enterText(find.widgetWithText(TextFormField, 'Name'), name);
  await tester.tap(find.text('Add Item'));
  await tester.pumpAndSettle();
}

GroceryItem item(String id, String name, Categories category, [int qty = 1]) =>
    GroceryItem(
      id: id,
      name: name,
      quantity: qty,
      category: categories[category]!,
    );

void main() {
  testWidgets('Grocery list screen renders empty state', (tester) async {
    await pumpApp(tester, FakeGroceryRepository());

    expect(find.text('Your Groceries'), findsOneWidget);
    expect(find.text('No items added yet.'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Shows a spinner while loading, then the fetched items', (
    tester,
  ) async {
    final repo = FakeGroceryRepository([
      item('a', 'Milk', Categories.dairy, 2),
      item('b', 'Bananas', Categories.fruit, 6),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [groceryRepositoryProvider.overrideWithValue(repo)],
        child: const MyApp(),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Bananas'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('Shows the error and recovers with Retry', (tester) async {
    final repo = FakeGroceryRepository([item('a', 'Milk', Categories.dairy)])
      ..failWith = Exception('boom');
    await pumpApp(tester, repo);

    expect(find.textContaining('boom'), findsOneWidget);
    expect(find.text('Milk'), findsNothing);

    repo.failWith = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsOneWidget);
  });

  testWidgets('Pull to refresh loads new items from the repository', (
    tester,
  ) async {
    final repo = FakeGroceryRepository();
    await pumpApp(tester, repo);
    expect(find.text('Milk'), findsNothing);

    repo.items.add(item('a', 'Milk', Categories.dairy));
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsOneWidget);
  });

  testWidgets('Form rejects an invalid name', (tester) async {
    final repo = FakeGroceryRepository();
    await pumpApp(tester, repo);

    await addItem(tester, 'a');

    expect(find.text('Invalid name'), findsOneWidget);
    expect(find.text('Add a new item'), findsOneWidget);
    expect(repo.items, isEmpty);
  });

  testWidgets('Valid form adds an item through the repository', (tester) async {
    final repo = FakeGroceryRepository();
    await pumpApp(tester, repo);

    await addItem(tester, 'Milk');

    expect(repo.items.single.name, 'Milk');
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('No items added yet.'), findsNothing);
  });

  testWidgets('Failed add keeps the form open and shows the error', (
    tester,
  ) async {
    final repo = FakeGroceryRepository();
    await pumpApp(tester, repo);
    repo.failWith = Exception('offline');

    await addItem(tester, 'Milk');

    expect(find.text('Add a new item'), findsOneWidget);
    expect(find.textContaining('offline'), findsOneWidget);
    expect(repo.items, isEmpty);
  });

  testWidgets('Swiped item is deleted, and restored with Undo', (tester) async {
    final repo = FakeGroceryRepository();
    await pumpApp(tester, repo);

    await addItem(tester, 'Milk');
    await addItem(tester, 'Eggs');

    await tester.drag(find.text('Milk'), const Offset(-800, 0));
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsNothing);
    expect(find.text('Eggs'), findsOneWidget);
    expect(repo.items.map((i) => i.name), ['Eggs']);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Eggs'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Milk')).dy,
      lessThan(tester.getTopLeft(find.text('Eggs')).dy),
    );
    expect(repo.items.map((i) => i.name), containsAll(['Milk', 'Eggs']));
  });

  testWidgets('Failed delete puts the item back and shows the error', (
    tester,
  ) async {
    final repo = FakeGroceryRepository([item('a', 'Milk', Categories.dairy)]);
    await pumpApp(tester, repo);
    repo.failWith = Exception('cannot delete');

    await tester.drag(find.text('Milk'), const Offset(-800, 0));
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsOneWidget);
    expect(find.textContaining('cannot delete'), findsOneWidget);
  });
}
