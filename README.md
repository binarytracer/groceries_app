<p align="center">
  <img src="assets/icon/icon.png" alt="Shopmate icon" width="120">
</p>

# Shopmate

A Flutter practice project focused on **form handling**, built around a groceries list app (repository: `groceries_app`). CI workflow based on meal-app.

## Form handling

The "Add a new item" screen ([lib/widgets/new_item.dart](lib/widgets/new_item.dart)) uses Flutter's built-in form tools, with no third-party form package:

- `Form` with a `GlobalKey<FormState>` to validate, save and reset all fields at once
- `TextFormField` for the name, with a `validator` (2 to 20 characters) and `maxLength`
- `TextFormField` for the quantity, with a numeric keyboard, a digits-only input formatter and a positive-number validator
- `DropdownButtonFormField` for the category, with a color marker on each option
- `onSaved` to collect the values, then `Navigator.pop` to return the new `GroceryItem` to the list screen
- A **Reset** button (`FormState.reset()`) and an **Add Item** button that only submits when the form is valid

## Other features

- View your grocery list, with a colored category marker and quantity per item
- Swipe an item away to delete it
- Tap **Undo** in the snackbar to restore a deleted item to its original position

## Screenshot

<table>
  <tr>
    <td width="33%"><img src="docs/screenshot.png" alt="Your Groceries screen" width="100%"></td>
    <td width="33%"><img src="docs/screenshot-new-item.png" alt="Add a new item screen with category picker" width="100%"></td>
    <td width="33%"><img src="docs/screenshot-dismiss.png" alt="Swiping an item to delete it" width="100%"></td>
  </tr>
</table>

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
