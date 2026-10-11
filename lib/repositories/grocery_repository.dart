import 'package:groceries_app/data/categories.dart';
import 'package:groceries_app/models/category.dart';
import 'package:groceries_app/models/grocery_item.dart';
import 'package:groceries_app/services/dto/grocery_item_dto.dart';
import 'package:groceries_app/services/grocery_api_service.dart';

/// Maps service DTOs to domain models. The only caller of the service.
class GroceryRepository {
  GroceryRepository(this._service);

  final GroceryApiService _service;

  GroceryItemDto _toDto(GroceryItem item) => GroceryItemDto(
    id: item.id,
    name: item.name,
    quantity: item.quantity,
    category: item.category.name,
  );

  Category _categoryByName(String name) => categories.values.firstWhere(
    (category) => category.name == name,
    orElse: () => categories[Categories.other]!,
  );

  GroceryItem _toModel(GroceryItemDto dto) => GroceryItem(
    id: dto.id,
    name: dto.name,
    quantity: dto.quantity,
    category: _categoryByName(dto.category),
  );

  Future<List<GroceryItem>> fetchItems() async {
    final data = await _service.getItems();
    return data.map(_toModel).toList();
  }

  Future<GroceryItem> addItem({
    required String name,
    required int quantity,
    required Category category,
  }) async {
    final draft = GroceryItem(
      id: '',
      name: name,
      quantity: quantity,
      category: category,
    );
    return _toModel(await _service.createItem(_toDto(draft)));
  }

  /// Also used to restore a deleted item (Undo) under its original id.
  Future<void> updateItem(GroceryItem item) =>
      _service.updateItem(_toDto(item));

  Future<void> deleteItem(GroceryItem item) => _service.deleteItem(item.id);
}
