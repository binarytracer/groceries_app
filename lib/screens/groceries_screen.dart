import 'package:groceries_app/data/dummy_items.dart';
import 'package:groceries_app/widgets/new_item.dart';
import 'package:material_ui/material_ui.dart';

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  void _addItem(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewItem()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [
          IconButton(onPressed: () => _addItem(context), icon: Icon(Icons.add)),
        ],
      ),

      body: ListView.builder(
        padding: EdgeInsets.only(left: 16),
        itemCount: groceryItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: groceryItems[index].category.color,
            ),
            trailing: Text(groceryItems[index].quantity.toString()),
          );
        },
      ),
    );
  }
}
