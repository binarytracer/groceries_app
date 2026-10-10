typedef Json = Map<String, Object?>;

/// The grocery item exactly as the API sends and receives it.
/// This is the only place raw JSON is read.
class GroceryItemDto {
  const GroceryItemDto({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  final String id;
  final String name;
  final int quantity;
  final String category;

  factory GroceryItemDto.fromJson(Json json) => GroceryItemDto(
    id: json['id'].toString(),
    name: json['name'] as String,
    quantity: int.parse(json['quantity'].toString()),
    category: json['category'] as String,
  );

  /// Request body. The id is not sent: it goes in the URL, or the API
  /// generates it.
  Json toJson() => {'name': name, 'quantity': quantity, 'category': category};
}
