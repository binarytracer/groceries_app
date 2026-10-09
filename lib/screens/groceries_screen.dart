import 'package:groceries_app/models/grocery_item.dart';
import 'package:groceries_app/widgets/new_item.dart';
import 'package:material_ui/material_ui.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final List<GroceryItem> _groceryItems = [];

  void _addItem(BuildContext context) async {
    final newItem = await Navigator.of(context)
        .push<GroceryItem>(MaterialPageRoute(builder: (context) => NewItem()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(child: Text('No items added yet.'));

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        padding: EdgeInsets.only(left: 16),
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          background: Container(
            color: Colors.red,
            child: Icon(Icons.delete, color: Colors.white),
          ),
          key: Key(_groceryItems[index].id),
          onDismissed: (direction) {
            final removedItem = _groceryItems[index];
            setState(() {
              _groceryItems.removeAt(index);
            });

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Item deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    setState(() {
                      _groceryItems.insert(
                        index.clamp(0, _groceryItems.length),
                        removedItem,
                      );
                    });
                  },
                ),
              ),
            );
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [
          IconButton(onPressed: () => _addItem(context), icon: Icon(Icons.add)),
        ],
      ),

      body: content,
    );
  }
}
