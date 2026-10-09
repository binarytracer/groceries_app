import 'package:material_ui/material_ui.dart';

enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
}

class Category {
  final String name;
  final Color color;

  Category(this.name, this.color);
}
