import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groceries_app/providers/auth_providers.dart';
import 'package:groceries_app/screens/groceries_screen.dart';
import 'package:groceries_app/screens/login_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Shows the list when signed in, the login screen otherwise.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(authProvider)
        .when(
          loading: () =>
              Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, _) => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error.toString()),
                  TextButton(
                    onPressed: () => ref.invalidate(authProvider),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (signedIn) =>
              signedIn ? const GroceryListScreen() : const LoginScreen(),
        );
  }
}
