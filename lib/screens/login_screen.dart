import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groceries_app/providers/auth_providers.dart';
import 'package:material_ui/material_ui.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var _username = '';
  var _password = '';
  var _isSigningIn = false;
  String? _error;

  Future<void> _signIn() async {
    bool areEntriesValid = _formKey.currentState!.validate();
    if (!areEntriesValid) return;

    _formKey.currentState!.save();

    setState(() {
      _isSigningIn = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).login(_username, _password);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                textInputAction: TextInputAction.next,
                autocorrect: false,
                onSaved: (value) => _username = value!.trim(),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your username'
                    : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) => _password = value!,
                onFieldSubmitted: (_) => _signIn(),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your password'
                    : null,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSigningIn ? null : _signIn,
                child: _isSigningIn
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
