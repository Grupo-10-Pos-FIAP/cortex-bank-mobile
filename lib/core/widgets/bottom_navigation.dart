import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NavegacaoPrincipal());
  }
}

class NavegacaoPrincipal extends StatefulWidget {
  const NavegacaoPrincipal({super.key});

  @override
  State<NavegacaoPrincipal> createState() => _NavegacaoPrincipalState();
}

class _NavegacaoPrincipalState extends State<NavegacaoPrincipal> {
  int _indiceAtual = 0;

  // Lista das páginas que serão exibidas
  final List<Widget> _paginas = [
    const Center(child: Text('Página Home', style: TextStyle(fontSize: 24))),
    const Center(
      child: Text('Página de Transações', style: TextStyle(fontSize: 24)),
    ),
    const Center(
      child: Text('Página de Perfil', style: TextStyle(fontSize: 24)),
    ),
  ];

  void _aoTocar(int index) {
    setState(() {
      _indiceAtual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      // Exibe a página de acordo com o índice selecionado
      body: _paginas[_indiceAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAtual,
        onTap: _aoTocar,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: 'Transações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
