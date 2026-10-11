import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groceries_app/data/categories.dart';
import 'package:groceries_app/models/category.dart';
import 'package:groceries_app/providers/grocery_providers.dart';
import 'package:material_ui/material_ui.dart';

class NewItem extends ConsumerStatefulWidget {
  const NewItem({super.key});

  @override
  ConsumerState<NewItem> createState() => _NewItemState();
}

class _NewItemState extends ConsumerState<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  Category _selectedCategory = categories.values.first;
  var _isSaving = false;

  Future<void> _saveItem() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();
    setState(() => _isSaving = true);

    try {
      final item = await ref
          .read(groceryListProvider.notifier)
          .add(
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory,
          );

      if (!mounted) return;
      Navigator.of(context).pop(item);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
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
                    child: DropdownButtonFormField<Category>(
                      decoration: InputDecoration(labelText: 'Category'),
                      initialValue: _selectedCategory,
                      items: [
                        for (final category in sortedCategories)
                          DropdownMenuItem(
                            value: category.value,
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
                      onPressed: _isSaving ? null : _saveItem,
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
