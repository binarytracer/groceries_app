import 'package:flutter/services.dart';
import 'package:groceries_app/data/categories.dart';
import 'package:groceries_app/models/grocery_item.dart';
import 'package:material_ui/material_ui.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories.entries.first.value.name;

  void _saveItem() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    // return the new item to the previous screen with data
    Navigator.of(context).pop(
      GroceryItem(
        id: DateTime.now().toIso8601String(),
        name: _enteredName,
        quantity: _enteredQuantity,
        category: categories.entries
            .firstWhere((entry) => entry.value.name == _selectedCategory)
            .value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => a.value.name.compareTo(b.value.name));

    return Scaffold(
      appBar: AppBar(title: Text('Add a new item')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                maxLength: 20,
                onSaved: (value) {
                  _enteredName = value!;
                },
                validator: (value) {
                  final isNotValid =
                      value == null ||
                      value.isEmpty ||
                      value.trim().length < 2 ||
                      value.trim().length > 20;

                  if (isNotValid) {
                    return 'Invalid name';
                  }

                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 4,
                      initialValue: '1',
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        counterText: '',
                      ),
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                      validator: (value) {
                        final isNotValid =
                            value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0;

                        if (isNotValid) {
                          return 'Invalid quantity';
                        }

                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(labelText: 'Category'),
                      initialValue: _selectedCategory,
                      items: [
                        for (final category in sortedCategories)
                          DropdownMenuItem(
                            value: category.value.name,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                SizedBox(width: 8),
                                Text(category.value.name),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _formKey.currentState?.reset();
                      },
                      child: Text('Reset'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveItem,
                      child: Text('Add Item'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
