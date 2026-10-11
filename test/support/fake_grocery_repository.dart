import 'package:groceries_app/models/category.dart';
import 'package:groceries_app/models/grocery_item.dart';
import 'package:groceries_app/repositories/grocery_repository.dart';

/// In-memory stand-in for the real repository, so tests never touch HTTP.
class FakeGroceryRepository implements GroceryRepository {
  FakeGroceryRepository([List<GroceryItem> initial = const []])
    : items = [...initial];

  final List<GroceryItem> items;
  var _nextId = 0;

  /// Set to make every call fail, to test error handling.
  Exception? failWith;

  /// Failures take a little time, like a real request. A failure that lands
  /// before the next frame would roll the list back while a swiped
  /// `Dismissible` is still in the tree.
  Future<void> _maybeFail() async {
    if (failWith != null) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      throw failWith!;
    }
  }

  @override
  Future<List<GroceryItem>> fetchItems() async {
    await _maybeFail();
    return [...items];
  }

  @override
  Future<GroceryItem> addItem({
    required String name,
    required int quantity,
    required Category category,
  }) async {
    await _maybeFail();
    final item = GroceryItem(
      id: 'fake-${_nextId++}',
      name: name,
      quantity: quantity,
      category: category,
    );
    items.add(item);
    return item;
  }

  @override
  Future<void> updateItem(GroceryItem item) async {
    await _maybeFail();
    items
      ..removeWhere((i) => i.id == item.id)
      ..add(item);
  }

  @override
  Future<void> deleteItem(GroceryItem item) async {
    await _maybeFail();
    items.removeWhere((i) => i.id == item.id);
  }
}
