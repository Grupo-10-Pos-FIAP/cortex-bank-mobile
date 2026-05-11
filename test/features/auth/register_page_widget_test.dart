import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

Widget _buildRegisterApp(AuthProvider provider) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: provider,
    child: MaterialApp(
      initialRoute: '/register',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
      },
    ),
  );
}

const _kFirst = Key('register.firstName');
const _kLast = Key('register.lastName');
const _kEmail = Key('register.email');
const _kPassword = Key('register.password');
const _kConfirm = Key('register.confirmPassword');
const _kSubmit = Key('register.submit');
const _kBack = Key('register.backToLogin');

Future<void> _tapSubmit(WidgetTester tester) async {
  await pumpSettleAnimations(tester);
  final submit = find.byKey(_kSubmit);
  final scroll = find.descendant(
    of: find.byType(RegisterPage),
    matching: find.byType(Scrollable),
  );
  await tester.dragUntilVisible(submit, scroll.first, const Offset(0, -80));
  await pumpSettleAnimations(tester);
  await tester.tap(submit);
}

void main() {
  tearDown(AppSnackBar.hide);

  group('RegisterPage', () {
    testWidgets('deve exibir todos os campos do formulário', (tester) async {
      final provider = AuthProvider(FakeAuthRepository());

      await tester.pumpWidget(_buildRegisterApp(provider));

      expect(find.byKey(_kFirst), findsOneWidget);
      expect(find.byKey(_kLast), findsOneWidget);
      expect(find.byKey(_kEmail), findsOneWidget);
      expect(find.byKey(_kPassword), findsOneWidget);
      expect(find.byKey(_kConfirm), findsOneWidget);
    });

    testWidgets('deve exibir validação obrigatória ao enviar vazio', (
      tester,
    ) async {
      final provider = AuthProvider(FakeAuthRepository());

      await tester.pumpWidget(_buildRegisterApp(provider));

      await _tapSubmit(tester);
      await pumpUntilFound(tester, find.text('Campo obrigatório'));

      expect(find.text('Campo obrigatório'), findsWidgets);
    });

    testWidgets('deve chamar signUp e voltar para login com dados válidos', (
      tester,
    ) async {
      final repo = FakeAuthRepository()..signUpResult = Success(buildUser());
      final provider = AuthProvider(repo);

      await tester.pumpWidget(_buildRegisterApp(provider));

      await tester.enterText(textFieldUnderKey(_kFirst), 'Gabrielle');
      await tester.enterText(textFieldUnderKey(_kLast), 'Martins');
      await tester.enterText(textFieldUnderKey(_kEmail), 'gabi@example.com');
      await tester.enterText(textFieldUnderKey(_kPassword), '12345678');
      await tester.enterText(textFieldUnderKey(_kConfirm), '12345678');
      await _tapSubmit(tester);
      await pumpUntilFound(tester, find.byType(LoginPage));

      expect(repo.signUpCalls, 1);
      expect(find.byType(LoginPage), findsOneWidget);

      await dismissTestSnackBars(tester);
    });

    testWidgets('deve voltar para login ao tocar em voltar', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(FakeAuthRepository()),
          child: MaterialApp(
            home: const LoginPage(),
            routes: {'/register': (_) => const RegisterPage()},
          ),
        ),
      );

      await tester.tap(find.text('Criar conta'));
      await pumpUntilFound(tester, find.byKey(_kFirst));

      await tester.ensureVisible(find.byKey(_kBack));
      await tester.pump();
      await tester.tap(find.byKey(_kBack));
      await pumpUntilFound(tester, find.byType(LoginPage));

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
