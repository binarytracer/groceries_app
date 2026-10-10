import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groceries_app/models/category.dart';
import 'package:groceries_app/models/grocery_item.dart';
import 'package:groceries_app/repositories/grocery_repository.dart';
import 'package:groceries_app/services/grocery_api_service.dart';

final groceryApiServiceProvider = Provider<GroceryApiService>(
  (ref) => GroceryApiService(),
);

final groceryRepositoryProvider = Provider<GroceryRepository>(
  (ref) => GroceryRepository(ref.watch(groceryApiServiceProvider)),
);

/// The grocery list. UI talks only to this, never to the repository.
class GroceryListNotifier extends AsyncNotifier<List<GroceryItem>> {
  @override
  Future<List<GroceryItem>> build() async {
    // TODO: remove. Temporary delay so the loading spinner is visible.
    await Future<void>.delayed(const Duration(seconds: 2));
    return ref.watch(groceryRepositoryProvider).fetchItems();
  }

  Future<GroceryItem> add({
    required String name,
    required int quantity,
    required Category category,
  }) async {
    final current = await future;
    final item = await ref
        .read(groceryRepositoryProvider)
        .addItem(name: name, quantity: quantity, category: category);
    state = AsyncData([...current, item]);
    return item;
  }

  /// Removes the item from the list immediately, then deletes it remotely.
  /// Rolls the list back if the request fails.
  Future<void> remove(GroceryItem item) async {
    final previous = state.value ?? [];
    state = AsyncData(previous.where((i) => i.id != item.id).toList());
    try {
      await ref.read(groceryRepositoryProvider).deleteItem(item);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  /// Puts a removed item back at [index] (Undo).
  Future<void> restore(GroceryItem item, int index) async {
    final previous = state.value ?? [];
    state = AsyncData(
      [...previous]..insert(index.clamp(0, previous.length), item),
    );
    try {
      await ref.read(groceryRepositoryProvider).updateItem(item);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  // TODO: update.
}

final groceryListProvider =
    AsyncNotifierProvider<GroceryListNotifier, List<GroceryItem>>(
      GroceryListNotifier.new,
    );
