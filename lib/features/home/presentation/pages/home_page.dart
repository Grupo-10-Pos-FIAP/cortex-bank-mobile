import 'package:cortex_bank_mobile/features/auth/presentation/pages/profile_tab_loader.dart';
import 'package:cortex_bank_mobile/features/contacts/state/contacts_provider.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/dashboard_page.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_tab_loader.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _dashboardEntranceVersion = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Carrega saldo e transações imediatamente
      context.read<TransactionsProvider>().loadBalanceSummary();
      context.read<TransactionsProvider>().loadTransactions();
      // Pré-carrega contatos em background para deixar pronto antes do usuário navegar
      context.read<ContactsProvider>().loadContacts();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == 0 && _currentIndex == 0) {
      setState(() => _dashboardEntranceVersion++);
      return;
    }
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeInOutCubic,
    );
  }

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
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          DashboardPage(entranceVersion: _dashboardEntranceVersion),
          const TransactionTabLoader(),
          const ProfileTabLoader(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
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
