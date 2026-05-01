import 'package:cortex_bank_mobile/features/home/presentation/widgets/entry_exit_chart.dart';
import 'package:cortex_bank_mobile/features/transaction/widgets/app_balance_card.dart';
import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/features/home/presentation/widgets/balance_evolution_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.entranceVersion = 0});

  /// Incrementado pela [HomePage] ao focar a aba Início para repetir a animação das seções.
  final int entranceVersion;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sectionController;
  late final Animation<double> _section1;
  late final Animation<double> _section2;
  late final Animation<double> _section3;

  @override
  void initState() {
    super.initState();
    _sectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _section1 = CurvedAnimation(
      parent: _sectionController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _section2 = CurvedAnimation(
      parent: _sectionController,
      curve: const Interval(0.12, 0.62, curve: Curves.easeOutCubic),
    );
    _section3 = CurvedAnimation(
      parent: _sectionController,
      curve: const Interval(0.28, 0.88, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _replaySectionEntrance();
    });
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entranceVersion != widget.entranceVersion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _replaySectionEntrance();
      });
    }
  }

  void _replaySectionEntrance() {
    _sectionController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _sectionController.dispose();
    super.dispose();
  }

  Widget _staggeredSection({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _staggeredSection(
            animation: _section1,
            child: AppBalanceCard(mostrarSaldoInicial: true),
          ),
          _staggeredSection(
            animation: _section2,
            child: const BalanceEvolutionChart(),
          ),
          _staggeredSection(
            animation: _section3,
            child: const EntryExitChart(),
          ),
        ],
      ),
    );
  }
}
