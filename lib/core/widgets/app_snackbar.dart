import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

class AppSnackBar {
  static OverlayEntry? _currentEntry;

  static void _showOverlay(
    BuildContext context,
    Widget child,
    Duration? duration,
  ) {
    // 1. AJUSTE: Remove o anterior antes de mostrar o novo
    hide();

    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _TopSnackBar(entry: entry, child: child, duration: duration);
      },
    );

    // 2. AJUSTE: Salva a referência na variável estática
    _currentEntry = entry;

    overlay.insert(entry);
  }

  static void hide() {
    // 3. AJUSTE: Agora _currentEntry terá um valor e poderá ser removido
    try {
      _currentEntry?.remove();
    } catch (e) {
      // Evita erro caso o entry já tenha sido removido pelo timer interno
    }
    _currentEntry = null;
  }

  static void show(
    BuildContext context,
    String message, {
    Duration? duration = const Duration(seconds: 3),
  }) {
    _showOverlay(
      context,
      _SnackContent(
        backgroundColor: AppDesignTokens.colorFeedbackInfo,
        message: message,
      ),
      duration,
    );
  }

  static void success(
    BuildContext context,
    String message, {
    Duration? duration = const Duration(seconds: 3),
  }) {
    _showOverlay(
      context,
      _SnackContent(
        backgroundColor: AppDesignTokens.colorFeedbackSuccess,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        message: message,
      ),
      duration,
    );
  }
  
  static void warning(
    BuildContext context,
    String message, {
    Duration? duration = const Duration(seconds: 3),
  }) {
    _showOverlay(
      context,
      _SnackContent(
        backgroundColor: AppDesignTokens.colorFeedbackWarning,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        message: message,
      ),
      duration,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    Duration? duration = const Duration(seconds: 3),
  }) {
    _showOverlay(
      context,
      _SnackContent(
        backgroundColor: AppDesignTokens.colorFeedbackError,
        icon: const Icon(Icons.error, color: Colors.white),
        message: message,
      ),
      duration,
    );
  }
}

class _TopSnackBar extends StatefulWidget {
  const _TopSnackBar({
    required this.entry,
    required this.child,
    this.duration, // Nova prop recebida aqui
  });

  final OverlayEntry entry;
  final Widget child;
  final Duration? duration;

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offset = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Só inicia o timer de remoção se a duração não for nula
    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted) {
          _controller.reverse().then((_) => widget.entry.remove());
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 20,
      right: 20,
      child: SafeArea(
        child: SlideTransition(position: _offset, child: widget.child),
      ),
    );
  }
}

class _SnackContent extends StatelessWidget {
  const _SnackContent({
    required this.backgroundColor,
    this.icon,
    required this.message,
  });

  final Color backgroundColor;
  final Widget? icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 12)],
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
