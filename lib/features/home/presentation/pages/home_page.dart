import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_form_page.dart';
import 'package:cortex_bank_mobile/features/transaction/widgets/app_balance_card.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const _HomeTabContent(),
    const TransactionFormPage(),
    const Center(child: Text('Perfil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignTokens.colorBgDefault,
      appBar: AppBar(
        title: const Text(
          'CortexBank',
          style: TextStyle(
            color: AppDesignTokens.colorPrimary,
            fontWeight: AppDesignTokens.fontWeightBold,
          ),
        ),
        backgroundColor: AppDesignTokens.colorWhite,
        elevation: 0, 
        centerTitle: false,
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.repeat), label: 'Transação'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// Conteúdo da aba Início: card de saldo clicável que abre a tela de Extrato.
class _HomeTabContent extends StatefulWidget {
  const _HomeTabContent();

  @override
  State<_HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<_HomeTabContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsProvider>().loadBalanceSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionsProvider>();
    final saldo = (tx.balanceSummary?.totalIncomeCents ?? 0) / 100.0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDesignTokens.spacingMd),
      child: AppBalanceCard(
        mostrarSaldoInicial: true,
        saldo: saldo,
        onTap: () => Navigator.pushNamed(context, AppRoutes.extrato),
      ),
    );
  }
}
