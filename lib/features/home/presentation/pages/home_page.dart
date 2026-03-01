import 'package:cortex_bank_mobile/features/home/presentation/pages/dashboard_page.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/features/transaction/presentation/pages/transaction_form_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    DashboardPage(),
    TransactionFormPage(),
    Center(child: Text('Perfil')),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
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
