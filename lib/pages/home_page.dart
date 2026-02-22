import 'package:cortex_bank_mobile/core/theme/app_design_tokens.dart';
import 'package:cortex_bank_mobile/features/transaction/pages/transaction_form_page.dart';
import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/features/extrato/pages/extrato_page.dart';
import 'package:cortex_bank_mobile/features/transaction/pages/transaction_new_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ExtratoPage(),
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
