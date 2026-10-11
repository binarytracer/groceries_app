import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groceries_app/models/category.dart';
import 'package:groceries_app/models/grocery_item.dart';
import 'package:groceries_app/providers/auth_providers.dart';
import 'package:groceries_app/repositories/grocery_repository.dart';
import 'package:groceries_app/services/api_client.dart';
import 'package:groceries_app/services/grocery_api_service.dart';

final dioProvider = Provider<Dio>(
  (ref) => createApiClient(ref.watch(authSessionProvider)),
);

final groceryApiServiceProvider = Provider<GroceryApiService>(
  (ref) => GroceryApiService(ref.watch(dioProvider)),
);

final groceryRepositoryProvider = Provider<GroceryRepository>(
  (ref) => GroceryRepository(ref.watch(groceryApiServiceProvider)),
);

/// The grocery list. UI talks only to this, never to the repository.
class GroceryListNotifier extends AsyncNotifier<List<GroceryItem>> {
  @override
  Future<List<GroceryItem>> build() async {
    // Start over for a different user: refetch after signing in again.
    ref.watch(authProvider.select((auth) => auth.value ?? false));
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
