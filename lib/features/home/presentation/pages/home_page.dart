import 'package:cortex_bank_mobile/features/auth/presentation/pages/profile_page.dart';
import 'package:cortex_bank_mobile/features/home/presentation/pages/dashboard_page.dart';
import 'package:cortex_bank_mobile/features/transaction/state/transactions_provider.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_form_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _lastPageIndex = 0;
  int _dashboardEntranceVersion = 0;
  late final AnimationController _tabSwitchController;
  late final Animation<double> _tabContentOpacity;

  @override
  void initState() {
    super.initState();
    _tabSwitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _tabContentOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _tabSwitchController,
        curve: Curves.easeOut,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsProvider>().loadBalanceSummary();
      context.read<TransactionsProvider>().loadTransactions();
    });
  }

  @override
  void dispose() {
    _tabSwitchController.dispose();
    super.dispose();
  }

  Future<void> _onTabSelected(int index) async {
    if (_tabSwitchController.isAnimating) return;
    if (index == 0 && _currentIndex == 0) {
      setState(() => _dashboardEntranceVersion++);
      return;
    }
    if (index == _currentIndex) return;
    await _tabSwitchController.forward();
    if (!mounted) return;
    setState(() {
      if (index == 0 && _lastPageIndex != 0) {
        _dashboardEntranceVersion++;
      }
      _currentIndex = index;
      _lastPageIndex = index;
    });
    await _tabSwitchController.reverse();
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
      body: FadeTransition(
        opacity: _tabContentOpacity,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardPage(entranceVersion: _dashboardEntranceVersion),
            const TransactionFormPage(),
            const ProfilePage(),
          ],
        ),
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
