import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:groceries_app/main.dart';
import 'package:groceries_app/providers/auth_providers.dart';
import 'package:groceries_app/providers/grocery_providers.dart';
import 'package:groceries_app/services/auth_api_service.dart';
import 'package:groceries_app/services/auth_interceptor.dart';
import 'package:groceries_app/services/auth_session.dart';
import 'package:material_ui/material_ui.dart';

import 'support/fake_auth.dart';
import 'support/fake_grocery_repository.dart';

/// A Dio whose "server" accepts only `Bearer access-2`, so the first token
/// handed out by login (`access-1`) is already expired.
Dio fakeServerDio(AuthSession session, List<String?> seenTokens) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'));
  dio.interceptors
    ..add(AuthInterceptor(session, dio))
    ..add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = options.headers['Authorization'] as String?;
          seenTokens.add(token);
          if (token == 'Bearer access-2') {
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: 'ok'),
            );
          } else {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(requestOptions: options, statusCode: 401),
              ),
              true, // let the error interceptors see it, like a real 401
            );
          }
        },
      ),
    );
  return dio;
}

Future<void> pumpApp(
  WidgetTester tester, {
  FakeTokenStorage? storage,
  FakeAuthApiService? api,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(storage ?? FakeTokenStorage()),
        authApiServiceProvider.overrideWithValue(api ?? FakeAuthApiService()),
        groceryRepositoryProvider.overrideWithValue(FakeGroceryRepository()),
      ],
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> signIn(WidgetTester tester, String user, String pass) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Username'), user);
  await tester.enterText(find.widgetWithText(TextFormField, 'Password'), pass);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
  await tester.pumpAndSettle();
}

void main() {
  group('AuthSession', () {
    test('login keeps the refresh token in storage', () async {
      final storage = FakeTokenStorage();
      final session = AuthSession(storage, FakeAuthApiService());

      await session.login('admin', 'secret');

      expect(session.accessToken, 'access-1');
      expect(storage.refreshToken, 'refresh-1');
    });

    test('restore is false with no stored token, and true with one', () async {
      final api = FakeAuthApiService();
      expect(await AuthSession(FakeTokenStorage(), api).restore(), isFalse);

      final session = AuthSession(FakeTokenStorage('refresh-0'), api);
      expect(await session.restore(), isTrue);
      expect(session.accessToken, isNotNull);
    });

    test('a rejected refresh token is cleared', () async {
      final storage = FakeTokenStorage('garbage');
      final session = AuthSession(storage, FakeAuthApiService());

      expect(await session.refresh(), isFalse);
      expect(storage.refreshToken, isNull);
    });

    test('a network failure keeps the stored token', () async {
      final storage = FakeTokenStorage('refresh-0');
      final api = FakeAuthApiService()..networkDown = true;

      await expectLater(
        AuthSession(storage, api).restore(),
        throwsA(isA<AuthException>()),
      );
      expect(storage.refreshToken, 'refresh-0');
    });

    test('concurrent refreshes share one request', () async {
      final api = FakeAuthApiService();
      final session = AuthSession(FakeTokenStorage('refresh-0'), api);

      await Future.wait([session.refresh(), session.refresh()]);

      expect(api.refreshCalls, 1);
    });
  });

  group('AuthInterceptor', () {
    test('on a 401 it refreshes once and retries with the new token', () async {
      final api = FakeAuthApiService();
      final session = AuthSession(FakeTokenStorage(), api);
      await session.login('admin', 'secret'); // access-1: expired
      final seen = <String?>[];

      final response = await fakeServerDio(session, seen).get<String>('/');

      expect(response.data, 'ok');
      expect(seen, ['Bearer access-1', 'Bearer access-2']);
      expect(api.refreshCalls, 1);
    });

    test(
      'when the refresh is rejected it signals the session expired',
      () async {
        final storage = FakeTokenStorage('garbage');
        final session = AuthSession(storage, FakeAuthApiService());
        var expired = false;
        session.onExpired = () => expired = true;

        await expectLater(
          fakeServerDio(session, []).get<String>('/'),
          throwsA(isA<DioException>()),
        );
        expect(expired, isTrue);
      },
    );
  });

  group('Sign in flow', () {
    testWidgets('shows the login screen when nobody is signed in', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.text('Sign in'), findsWidgets);
      expect(find.text('Your Groceries'), findsNothing);
    });

    testWidgets('wrong credentials show an error and stay on login', (
      tester,
    ) async {
      await pumpApp(tester);

      await signIn(tester, 'admin', 'nope');

      expect(find.text('Invalid username or password.'), findsOneWidget);
      expect(find.text('Your Groceries'), findsNothing);
    });

    testWidgets('right credentials open the list, sign out returns', (
      tester,
    ) async {
      final storage = FakeTokenStorage();
      await pumpApp(tester, storage: storage);

      await signIn(
        tester,
        FakeAuthApiService.username,
        FakeAuthApiService.password,
      );
      expect(find.text('Your Groceries'), findsOneWidget);
      expect(storage.refreshToken, isNotNull);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text('Your Groceries'), findsNothing);
      expect(storage.refreshToken, isNull);
    });

    testWidgets('a stored session skips the login screen', (tester) async {
      await pumpApp(tester, storage: FakeTokenStorage('refresh-0'));

      expect(find.text('Your Groceries'), findsOneWidget);
    });
  });
}
