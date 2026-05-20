import 'package:cortex_bank_mobile/core/utils/result.dart';
import 'package:cortex_bank_mobile/core/widgets/app_button.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:cortex_bank_mobile/core/widgets/app_dropdown_field.dart';
import 'package:cortex_bank_mobile/core/widgets/app_error_message.dart';
import 'package:cortex_bank_mobile/core/widgets/app_loading.dart';
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:cortex_bank_mobile/core/widgets/app_tabs.dart';
import 'package:cortex_bank_mobile/core/widgets/app_text_field.dart';
import 'package:cortex_bank_mobile/features/extrato/presentation/widgets/transaction_card.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/balance_summary.dart';
import 'package:cortex_bank_mobile/features/transaction/domain/entities/transaction.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/providers/transactions_notifier.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/state/transactions_state.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:cortex_bank_mobile/features/transaction/widgets/app_balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../../helpers/helpers.dart';

void main() {
  group('Design system goldens', () {
    goldenTest('app_button_primary', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(420, 120),
        child: AppButton(label: 'Continuar', onPressed: () {}),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_primary.png'),
      );
    });

    goldenTest('app_button_outlined', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(420, 120),
        child: AppButton(
          label: 'Cancelar',
          onPressed: () {},
          variant: ButtonVariant.outlined,
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_outlined.png'),
      );
    });

    goldenTest('app_text_field', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(420, 140),
        child: AppTextField(
          label: 'E-mail',
          hintText: 'voce@exemplo.com',
          controller: TextEditingController(),
        ),
      );

      await expectLater(
        find.byType(AppTextField),
        matchesGoldenFile('goldens/app_text_field.png'),
      );
    });

    goldenTest('app_dropdown_field', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(420, 140),
        child: AppDropdownField<int>(
          label: 'Categoria',
          value: 1,
          items: const [
            DropdownMenuItem(value: 1, child: Text('Alimentação')),
            DropdownMenuItem(value: 2, child: Text('Transporte')),
          ],
          onChanged: (_) {},
        ),
      );

      await expectLater(
        find.byType(AppDropdownField<int>),
        matchesGoldenFile('goldens/app_dropdown_field.png'),
      );
    });

    goldenTest('app_loading', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(200, 200),
        child: const AppLoading(),
        afterPump: (t) async {
          await t.pump();
        },
      );

      await expectLater(
        find.byType(AppLoading),
        matchesGoldenFile('goldens/app_loading.png'),
      );
    });

    goldenTest('app_error_message', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(420, 120),
        child: const AppErrorMessage(
          message: 'Não foi possível concluir a operação.',
        ),
      );

      await expectLater(
        find.byType(AppErrorMessage),
        matchesGoldenFile('goldens/app_error_message.png'),
      );
    });

    goldenTest('transaction_card', (tester) async {
      final tx = Transaction(
        id: 'g1',
        accountId: 'acc',
        type: TransactionType.debit,
        value: 42.5,
        date: DateTime(2024, 6, 15),
        to: 'Maria',
        from: null,
        status: TransactionStatus.completed,
        category: TransactionCategory.food,
        description: 'Almoço',
        receiptUrls: const [],
      );

      final fakeAuth = FakeAuthRepository()
        ..currentUserResult = Success(
          buildUser(username: 'João Silva', email: 'joao@example.com'),
        );
      final auth = AuthProvider(fakeAuth);
      await auth.loadCurrentUser();

      await pumpGoldenMaterialApp(
        tester,
        size: const Size(520, 220),
        home: Scaffold(
          body: ChangeNotifierProvider<AuthProvider>.value(
            value: auth,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: TransactionCard(transaction: tx, onDelete: () {}),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(TransactionCard),
        matchesGoldenFile('goldens/transaction_card.png'),
      );
    });

    goldenTest('app_balance_card', (tester) async {
      final repo = FakeTransactionsRepository()
        ..getBalanceSummaryResult = const Success(
          BalanceSummary(
            totalIncomeCents: 5000,
            totalExpenseCents: 2000,
            balanceCents: 3000,
          ),
        );
      final provider = TransactionsNotifier(repo);
      await provider.loadBalanceSummary();

      await pumpGoldenMaterialApp(
        tester,
        size: const Size(420, 220),
        routes: {
          '/extrato': (_) =>
              const Scaffold(body: Center(child: Text('Extrato'))),
        },
        home: Scaffold(
          body:
              StateNotifierProvider<
                TransactionsNotifier,
                TransactionsState
              >.value(
                value: provider,
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: AppBalanceCard(mostrarSaldoInicial: true),
                ),
              ),
        ),
      );

      await expectLater(
        find.byType(AppBalanceCard),
        matchesGoldenFile('goldens/app_balance_card.png'),
      );
    });

    goldenTest('app_button_secondary', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(420, 120),
        child: AppButton(
          label: 'Ver mais',
          onPressed: () {},
          variant: ButtonVariant.secondary,
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_secondary.png'),
      );
    });

    goldenTest('app_button_loading', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(420, 120),
        child: AppButton(label: 'Salvando', onPressed: () {}, loading: true),
        afterPump: (t) async {
          await t.pump();
          await t.pump(kGoldenButtonLoadingSettle);
        },
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_loading.png'),
      );
    });

    goldenTest('app_button_disabled', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(420, 120),
        child: AppButton(
          label: 'Indisponível',
          onPressed: () {},
          enabled: false,
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_disabled.png'),
      );
    });

    goldenTest('app_button_negative', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(420, 120),
        child: AppButton(
          label: 'Encerrar conta',
          onPressed: () {},
          variant: ButtonVariant.negative,
        ),
      );

      await expectLater(
        find.byType(AppButton),
        matchesGoldenFile('goldens/app_button_negative.png'),
      );
    });

    goldenTest('app_text_field_required', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(420, 140),
        child: AppTextField(
          label: 'Senha',
          showRequiredIndicator: true,
          controller: TextEditingController(),
        ),
      );

      await expectLater(
        find.byType(AppTextField),
        matchesGoldenFile('goldens/app_text_field_required.png'),
      );
    });

    goldenTest('app_tabs', (tester) async {
      await pumpGolden(
        tester,
        size: const Size(420, 300),
        child: AppTabs(
          titles: const ['Início', 'Extrato'],
          height: 140,
          children: const [
            Center(child: Text('Conteúdo da aba inicial')),
            Center(child: Text('Conteúdo do extrato')),
          ],
        ),
      );

      await expectLater(
        find.byType(AppTabs),
        matchesGoldenFile('goldens/app_tabs.png'),
      );
    });

    goldenTest('app_snackbar_success', (tester) async {
      late BuildContext ctx;
      await pumpGoldenMaterialApp(
        tester,
        size: const Size(420, 200),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              ctx = context;
              return const Center(child: Text('Conteúdo'));
            },
          ),
        ),
      );

      addTearDown(AppSnackBar.hide);

      AppSnackBar.success(
        ctx,
        'Operação concluída com sucesso.',
        duration: null,
      );
      await tester.pump();
      await tester.pump(kGoldenSnackbarSuccessSettle);

      await expectLater(
        find.byKey(AppSnackBar.successSurfaceKey),
        matchesGoldenFile('goldens/app_snackbar_success.png'),
      );
    });
  });
}
