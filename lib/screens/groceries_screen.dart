import 'package:material_ui/material_ui.dart';

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grocery List')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Item 1',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          Text(
            'Item 2',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          Text(
            'Item 3',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          TextButton(onPressed: () {}, child: Text('Add Item')),
        ],
      ),
    );
  }
}
