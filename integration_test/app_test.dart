import 'package:cortex_bank_mobile/app.dart';
import 'package:cortex_bank_mobile/core/di/injection.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/pages/extrato_page.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/home_page.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/contacts/domain/repositories/i_contacts_repository.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/repositories/i_transactions_repository.dart';
import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import '../test/helpers/helpers.dart';
import 'integration_theme.dart';

bool _valueFieldMeetsMinBRL(WidgetTester tester) {
  final inner = find.descendant(
    of: find.byKey(const Key('transaction.form.value')),
    matching: find.byType(TextFormField),
  );
  final matches = inner.evaluate();
  if (matches.length != 1) return false;
  final state = tester.state<FormFieldState<String>>(inner);
  final v = state.value;
  if (v == null || v.trim().isEmpty) return false;
  return validateMinTransferValueBRL(v) == null;
}

Future<void> _pumpTestApp(
  WidgetTester tester, {
  required FakeAuthRepository authRepo,
  required FakeTransactionsRepository txRepo,
  FakeContactsRepository? contactsRepo,
}) async {
  await getIt.reset();
  getIt.registerSingleton<IContactsRepository>(
    contactsRepo ?? FakeContactsRepository(),
  );
  getIt.registerSingleton<ITransactionsRepository>(txRepo);

  final auth = AuthProvider(authRepo);
  await auth.loadCurrentUser();
  await tester.pumpWidget(
    MultiProvider(
      providers: [ChangeNotifierProvider<AuthProvider>.value(value: auth)],
      child: App(
        enableConnectivityWrapper: false,
        theme: integrationTestTheme(),
      ),
    ),
  );
  await tester.pump();
  await pumpUntilFound(tester, find.byType(LoginPage));
  await pumpSettleShort(tester);
}

Future<void> _login(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(textFieldUnderKey(const Key('login.email')), email);
  await tester.enterText(
    textFieldUnderKey(const Key('login.password')),
    password,
  );
  await tester.tap(find.byKey(const Key('login.submit')));
  await pumpUntilFound(tester, find.byType(HomePage));
  await pumpSettleShort(tester);
}

Future<void> _fillAndSubmitCreditTransaction(
  WidgetTester tester, {
  required String description,
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final titularMesma = find.byKey(
    const ValueKey<String>('transaction.form.titularidade.0'),
  );
  await tester.ensureVisible(titularMesma);
  await pumpAfterLayoutStep(tester);
  await tester.tap(titularMesma);
  await pumpAfterLayoutStep(tester);

  final typeDropdown = find.descendant(
    of: find.byKey(const Key('transaction.form.type')),
    matching: find.byType(DropdownButtonFormField<String>),
  );
  await tester.dragUntilVisible(
    typeDropdown,
    find.byKey(const Key('transaction.form.page')),
    const Offset(0, -120),
  );
  await pumpAfterLayoutStep(tester);
  await tester.ensureVisible(typeDropdown);
  await pumpAfterLayoutStep(tester);
  await tester.tap(typeDropdown, warnIfMissed: false);
  await pumpAfterLayoutStep(tester);
  final tipoCredito = find.byKey(
    const Key('transaction.form.type.item.credito'),
  );
  await pumpUntilFound(tester, tipoCredito);
  await tester.ensureVisible(tipoCredito);
  await pumpAfterLayoutStep(tester);
  await tester.tap(tipoCredito, warnIfMissed: false);
  await pumpAfterLayoutStep(tester);

  await tester.enterText(
    find.byKey(const Key('transaction.form.value')),
    '100',
  );
  await pumpUntil(
    tester,
    () => _valueFieldMeetsMinBRL(tester),
    timeout: const Duration(seconds: 5),
    reason:
        'Campo valor: aguardar máscara BRL e debounce de validação antes da categoria.',
  );

  final categoryDropdown = find.descendant(
    of: find.byKey(const Key('transaction.form.category')),
    matching: find.byType(DropdownButtonFormField<String>),
  );
  await tester.dragUntilVisible(
    categoryDropdown,
    find.byKey(const Key('transaction.form.page')),
    const Offset(0, -120),
  );
  await pumpAfterLayoutStep(tester);
  await tester.ensureVisible(categoryDropdown);
  await pumpAfterLayoutStep(tester);
  await tester.tap(categoryDropdown, warnIfMissed: false);
  await pumpAfterLayoutStep(tester);
  final categoriaAlimentacao = find.byKey(
    const ValueKey<String>('transaction.form.category.item.food'),
  );
  await pumpUntilFound(tester, categoriaAlimentacao);
  await tester.ensureVisible(categoriaAlimentacao);
  await pumpAfterLayoutStep(tester);
  await tester.tap(categoriaAlimentacao, warnIfMissed: false);
  await pumpAfterLayoutStep(tester);

  await tester.enterText(
    find.byKey(const Key('transaction.form.description')),
    description,
  );
  await pumpAfterLayoutStep(tester);

  await tester.ensureVisible(find.byKey(const Key('transaction.form.submit')));
  await pumpAfterLayoutStep(tester);
  await tester.tap(find.byKey(const Key('transaction.form.submit')));
  await pumpAfterLayoutStep(tester);

  await tester.tap(find.byKey(const Key('transaction.form.dialog.confirm')));
  await pumpUntil(
    tester,
    () => find.byType(Dialog).evaluate().isEmpty,
    timeout: const Duration(seconds: 15),
  );
  await pumpSettleShort(tester);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Jornadas críticas', () {
    testWidgets('login, home e abertura do formulário de transação', (
      tester,
    ) async {
      final txRepo = FakeTransactionsRepository()
        ..getBalanceSummaryResult = const Success(
          BalanceSummary(
            totalIncomeCents: 1000,
            totalExpenseCents: 500,
            balanceCents: 500,
          ),
        );

      final authRepo = FakeAuthRepository()
        ..currentUserResult = const Success(null)
        ..signInResult = Success(
          buildUser(uid: 'acc-1', username: 'Ana Teste', email: 'ana@test.com'),
        );

      await _pumpTestApp(tester, authRepo: authRepo, txRepo: txRepo);

      expect(find.byType(LoginPage), findsOneWidget);

      await _login(tester, email: 'ana@test.com', password: 'senha1234');

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Saldo'), findsWidgets);

      await tester.tap(find.text('Transação'));
      await pumpUntilFound(
        tester,
        find.byKey(const Key('transaction.form.page')),
      );
      await pumpSettleShort(tester);

      expect(find.byKey(const Key('transaction.form.page')), findsOneWidget);
    });

    testWidgets('cadastro com sucesso retorna à tela de login', (tester) async {
      final authRepo = FakeAuthRepository()
        ..currentUserResult = const Success(null)
        ..signUpResult = Success(buildUser());

      final txRepo = FakeTransactionsRepository();

      await _pumpTestApp(tester, authRepo: authRepo, txRepo: txRepo);

      await tester.tap(find.text('Criar conta'));
      await pumpUntilFound(tester, find.byKey(const Key('register.firstName')));

      await tester.enterText(
        textFieldUnderKey(const Key('register.firstName')),
        'Nome',
      );
      await tester.enterText(
        textFieldUnderKey(const Key('register.lastName')),
        'Sobrenome',
      );
      await tester.enterText(
        textFieldUnderKey(const Key('register.email')),
        'novo@test.com',
      );
      await tester.enterText(
        textFieldUnderKey(const Key('register.password')),
        '12345678',
      );
      await tester.enterText(
        textFieldUnderKey(const Key('register.confirmPassword')),
        '12345678',
      );

      await tester.ensureVisible(find.byKey(const Key('register.submit')));
      await pumpAfterLayoutStep(tester);
      await tester.tap(find.byKey(const Key('register.submit')));
      await pumpUntilFound(tester, find.byType(LoginPage));

      expect(authRepo.signUpCalls, 1);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('login e logout retornam à tela de login', (tester) async {
      final authRepo = FakeAuthRepository()
        ..currentUserResult = const Success(null)
        ..signInResult = Success(
          buildUser(uid: 'acc-2', username: 'Beto', email: 'beto@test.com'),
        )
        ..signOutResult = const Success(null);

      final txRepo = FakeTransactionsRepository();

      await _pumpTestApp(tester, authRepo: authRepo, txRepo: txRepo);

      await tester.enterText(
        textFieldUnderKey(const Key('login.email')),
        'beto@test.com',
      );
      await tester.enterText(
        textFieldUnderKey(const Key('login.password')),
        '12345678',
      );
      await tester.tap(find.byKey(const Key('login.submit')));
      await pumpUntilFound(tester, find.byType(HomePage));
      await pumpSettleShort(tester);

      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.text('Perfil'));
      await pumpUntilFound(tester, find.text('Sair da conta'));

      final sairDaConta = find.text('Sair da conta');
      await tester.ensureVisible(sairDaConta);
      await pumpAfterLayoutStep(tester);
      await tester.tap(sairDaConta, warnIfMissed: false);
      await pumpUntilFound(tester, find.byType(LoginPage));
      await pumpSettleShort(tester);

      expect(authRepo.signOutCalls, 1);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('fluxo crédito, extrato e exclusão chama o repositório', (
      tester,
    ) async {
      final txRepo = FakeTransactionsRepository()
        ..mirrorTimelineInMemory = true
        ..getBalanceSummaryResult = const Success(
          BalanceSummary(
            totalIncomeCents: 1000,
            totalExpenseCents: 500,
            balanceCents: 500,
          ),
        )
        ..addResult = const Success('tx-repo-1');

      final authRepo = FakeAuthRepository()
        ..currentUserResult = const Success(null)
        ..signInResult = Success(
          buildUser(
            uid: 'acc-1',
            username: 'Ana Teste',
            email: 'ana@test.com',
            branchCode: '0001',
            accountNumber: '12345-6',
          ),
        );

      await _pumpTestApp(tester, authRepo: authRepo, txRepo: txRepo);
      await _login(tester, email: 'ana@test.com', password: 'senha1234');

      await tester.tap(find.text('Transação'));
      await pumpUntilFound(
        tester,
        find.byKey(const Key('transaction.form.page')),
      );
      await pumpSettleShort(tester);

      const desc = 'Jornada integração — almoço';
      await _fillAndSubmitCreditTransaction(tester, description: desc);

      expect(txRepo.addCalls, 1);

      await tester.tap(find.text('Início'));
      await pumpUntilFound(tester, find.byType(HomePage));
      await pumpSettleShort(tester);

      await tester.tap(
        find
            .ancestor(
              of: find.descendant(
                of: find.byKey(const Key('dashboard.scroll')),
                matching: find.text('Saldo'),
              ),
              matching: find.byType(InkWell),
            )
            .first,
      );
      await pumpUntilFound(tester, find.byType(ExtratoPage));
      await pumpSettleShort(tester);

      expect(find.byType(ExtratoPage), findsOneWidget);
      expect(find.textContaining(desc), findsOneWidget);

      await tester.tap(find.byKey(const Key('extrato.transaction.delete')));
      await pumpUntilFound(
        tester,
        find.byKey(const Key('extrato.transaction.delete.confirm')),
      );
      await tester.tap(
        find.byKey(const Key('extrato.transaction.delete.confirm')),
      );
      await pumpUntil(
        tester,
        () => find.textContaining(desc).evaluate().isEmpty,
        timeout: const Duration(seconds: 15),
      );
      await pumpSettleShort(tester);

      expect(txRepo.deleteCalls, 1);
      expect(find.textContaining(desc), findsNothing);
    });

    testWidgets('aba contatos: adicionar e favoritar chama o repositório', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(900, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final contactsRepo = FakeContactsRepository()
        ..addResult = const Success('c-1')
        ..updateFavoriteResult = const Success(null);

      final txRepo = FakeTransactionsRepository()
        ..getBalanceSummaryResult = const Success(
          BalanceSummary(
            totalIncomeCents: 1000,
            totalExpenseCents: 500,
            balanceCents: 500,
          ),
        );

      final authRepo = FakeAuthRepository()
        ..currentUserResult = const Success(null)
        ..signInResult = Success(buildUser(uid: 'u1', username: 'Zé'));

      await _pumpTestApp(
        tester,
        authRepo: authRepo,
        txRepo: txRepo,
        contactsRepo: contactsRepo,
      );
      await _login(tester, email: 'ze@test.com', password: '12345678');

      await tester.tap(find.text('Transação'));
      await pumpUntilFound(
        tester,
        find.byKey(const Key('transaction.form.page')),
      );
      await pumpSettleShort(tester);

      await tester.tap(find.text('Contatos'));
      await pumpUntilFound(tester, find.text('Adicionar contato'));
      await pumpSettleShort(tester);

      final addContact = find.text('Adicionar contato');
      await tester.ensureVisible(addContact);
      await pumpAfterLayoutStep(tester);
      await tester.tap(addContact);
      await pumpUntilFound(tester, find.byType(AlertDialog));

      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Fulano Tester',
      );
      await tester.tap(find.text('Salvar'));
      await pumpUntil(
        tester,
        () => find.byType(AlertDialog).evaluate().isEmpty,
        timeout: const Duration(seconds: 10),
        reason: 'Diálogo de adicionar contato deve fechar após salvar.',
      );

      expect(contactsRepo.addCalls, 1);

      final favoriteFinder = find.byKey(
        const ValueKey<String>('contact-favorite-c-1'),
      );
      final formScrollable = find.descendant(
        of: find.byKey(const Key('transaction.form.page')),
        matching: find.byType(Scrollable),
      );
      await tester.dragUntilVisible(
        favoriteFinder,
        formScrollable.first,
        const Offset(0, -200),
      );
      await pumpAfterLayoutStep(tester);
      await tester.ensureVisible(favoriteFinder);
      await pumpAfterLayoutStep(tester);
      await tester.tap(favoriteFinder);
      await pumpUntil(
        tester,
        () => contactsRepo.updateFavoriteCalls >= 1,
        timeout: const Duration(seconds: 10),
        reason: 'Favoritar contato deve concluir a chamada ao repositório.',
      );

      expect(contactsRepo.updateFavoriteCalls, 1);
      expect(contactsRepo.lastUpdateFavoriteValue, true);
    });

    testWidgets('recarregar auth com usuário nulo limpa sessão', (
      tester,
    ) async {
      final authRepo = FakeAuthRepository()
        ..currentUserResult = const Success(null)
        ..signInResult = Success(buildUser());

      final txRepo = FakeTransactionsRepository();

      await _pumpTestApp(tester, authRepo: authRepo, txRepo: txRepo);
      await _login(tester, email: 'a@b.com', password: '12345678');

      expect(find.byType(HomePage), findsOneWidget);

      authRepo.currentUserResult = const Success(null);
      final ctx = tester.element(find.byKey(const Key('home.scaffold')));
      final auth = Provider.of<AuthProvider>(ctx, listen: false);
      await auth.loadCurrentUser(force: true);
      await pumpSettleShort(tester);

      expect(auth.user, isNull);
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
