import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groceries_app/models/grocery_item.dart';
import 'package:groceries_app/providers/grocery_providers.dart';
import 'package:groceries_app/widgets/new_item.dart';
import 'package:material_ui/material_ui.dart';

class GroceryListScreen extends ConsumerWidget {
  const GroceryListScreen({super.key});

  void _addItem(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const NewItem()));
  }

  void _showError(ScaffoldMessengerState messenger, Object error) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(error.toString())));
  }

  Future<void> _removeItem(
    BuildContext context,
    WidgetRef ref,
    GroceryItem item,
    int index,
  ) async {
    final notifier = ref.read(groceryListProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Item deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => notifier
              .restore(item, index)
              .catchError((Object e) => _showError(messenger, e)),
        ),
      ),
    );

    try {
      await notifier.remove(item);
    } catch (error) {
      _showError(messenger, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groceries = ref.watch(groceryListProvider);

    final content = groceries.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error.toString()),
            TextButton(
              onPressed: () => ref.invalidate(groceryListProvider),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
      data: (items) {
        // Always scrollable so pull-to-refresh works on an empty list too.
        final Widget list = items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200),
                  Center(child: Text('No items added yet.')),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(left: 16),
                itemCount: items.length,
                itemBuilder: (context, index) => Dismissible(
                  background: Container(
                    color: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  key: Key(items[index].id),
                  onDismissed: (direction) =>
                      _removeItem(context, ref, items[index], index),
                  child: ListTile(
                    title: Text(items[index].name),
                    leading: Container(
                      width: 24,
                      height: 24,
                      color: items[index].category.color,
                    ),
                    trailing: Text(items[index].quantity.toString()),
                  ),
                ),
              );

        return RefreshIndicator(
          onRefresh: () => ref.refresh(groceryListProvider.future),
          child: list,
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(groceryListProvider),
            icon: Icon(Icons.refresh),
          ),
          IconButton(onPressed: () => _addItem(context), icon: Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          // Shown on refresh, when the old list stays visible underneath.
          if (groceries.isRefreshing) LinearProgressIndicator(),
          Expanded(child: content),
        ],
      ),
    );
  }
}
