import 'dart:async';

import 'package:cortex_bank_mobile/core/errors/failure.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/features/auth/domain/entities/user.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

Widget _buildLoginScaffold(AuthProvider provider) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: provider,
    child: MaterialApp(
      initialRoute: '/login',
      routes: {
        '/': (_) => const Scaffold(body: Text('Home gate opened')),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
      },
    ),
  );
}

const _emailKey = Key('login.email');
const _passwordKey = Key('login.password');
const _submitKey = Key('login.submit');
const _registerKey = Key('login.register');

void main() {
  tearDown(AppSnackBar.hide);

  group('LoginPage', () {
    testWidgets('deve exibir email, senha, enviar e link para cadastro', (
      tester,
    ) async {
      final provider = AuthProvider(FakeAuthRepository());

      await tester.pumpWidget(_buildLoginScaffold(provider));

      expect(find.byKey(_emailKey), findsOneWidget);
      expect(find.byKey(_passwordKey), findsOneWidget);
      expect(find.byKey(_submitKey), findsOneWidget);
      expect(find.byKey(_registerKey), findsOneWidget);
    });

    testWidgets('deve exibir erro de validação ao enviar sem email', (
      tester,
    ) async {
      final repo = FakeAuthRepository();
      final provider = AuthProvider(repo);

      await tester.pumpWidget(_buildLoginScaffold(provider));

      await tester.tap(find.byKey(_submitKey));
      await pumpUntilFound(tester, find.text('Email é obrigatório'));

      expect(find.text('Email é obrigatório'), findsOneWidget);
      expect(repo.signInCalls, 0);
    });

    testWidgets('deve exibir erro ao enviar com email inválido', (
      tester,
    ) async {
      final repo = FakeAuthRepository();
      final provider = AuthProvider(repo);

      await tester.pumpWidget(_buildLoginScaffold(provider));

      await tester.enterText(textFieldUnderKey(_emailKey), 'not-an-email');
      await tester.enterText(textFieldUnderKey(_passwordKey), '12345678');
      await tester.tap(find.byKey(_submitKey));
      await pumpUntilFound(tester, find.text('Digite um email válido'));

      expect(find.text('Digite um email válido'), findsOneWidget);
      expect(repo.signInCalls, 0);
    });

    testWidgets(
      'deve chamar signIn e navegar para home com email e senha válidos',
      (tester) async {
        final repo = FakeAuthRepository()..signInResult = Success(buildUser());
        final provider = AuthProvider(repo);

        await tester.pumpWidget(_buildLoginScaffold(provider));

        await tester.enterText(
          textFieldUnderKey(_emailKey),
          'gabi@example.com',
        );
        await tester.enterText(textFieldUnderKey(_passwordKey), '12345678');
        await tester.tap(find.byKey(_submitKey));

        await pumpUntilFound(tester, find.text('Home gate opened'));

        expect(repo.signInCalls, 1);
        expect(repo.lastSignInEmail, 'gabi@example.com');
        expect(find.text('Home gate opened'), findsOneWidget);

        await dismissTestSnackBars(tester);
      },
    );

    testWidgets('deve exibir banner com mensagem quando signIn falhar', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..signInResult = FailureResult(
          const Failure(message: 'Credenciais inválidas'),
        );
      final provider = AuthProvider(repo);

      await tester.pumpWidget(_buildLoginScaffold(provider));

      await tester.enterText(textFieldUnderKey(_emailKey), 'gabi@example.com');
      await tester.enterText(textFieldUnderKey(_passwordKey), '12345678');
      await tester.tap(find.byKey(_submitKey));
      await pumpUntilFound(tester, find.text('Credenciais inválidas'));

      expect(find.text('Credenciais inválidas'), findsOneWidget);
    });

    testWidgets('deve exibir estado de carregamento durante signIn', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..signInCompleter = Completer<Result<User>>();
      final provider = AuthProvider(repo);

      await tester.pumpWidget(_buildLoginScaffold(provider));

      await tester.enterText(textFieldUnderKey(_emailKey), 'gabi@example.com');
      await tester.enterText(textFieldUnderKey(_passwordKey), '12345678');
      await tester.tap(find.byKey(_submitKey));
      await tester.pump();

      expect(find.byKey(_submitKey), findsNothing);

      repo.signInCompleter!.complete(Success(buildUser()));
      await pumpUntilFound(tester, find.text('Home gate opened'));

      await dismissTestSnackBars(tester);
    });

    testWidgets('deve navegar para RegisterPage ao tocar em cadastro', (
      tester,
    ) async {
      final provider = AuthProvider(FakeAuthRepository());

      await tester.pumpWidget(_buildLoginScaffold(provider));

      await tester.tap(find.byKey(_registerKey));
      await pumpUntilFound(tester, find.byType(RegisterPage));

      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('deve exibir botão de enviar sem loading no estado inicial', (
      tester,
    ) async {
      final provider = AuthProvider(FakeAuthRepository());

      await tester.pumpWidget(_buildLoginScaffold(provider));

      final button = tester.widget<AppButton>(find.byKey(_submitKey));
      expect(button.loading, false);
    });
  });
}
