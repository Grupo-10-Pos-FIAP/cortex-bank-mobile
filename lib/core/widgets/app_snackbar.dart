import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/shared/theme/app_design_tokens.dart';

/// lightweight utility that shows snackbars at the top of the screen
/// with a slide‑down animation. For more complex scenarios you might use an
/// external package, but this implementation keeps the dependency list
/// minimal by building an [OverlayEntry] and animating it manually.
class AppSnackBar {
  static void _showOverlay(BuildContext context, Widget child) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _TopSnackBar(entry: entry, child: child);
      },
    );

    overlay.insert(entry);
  }

  static void show(BuildContext context, String message) {
    _showOverlay(
      context,
      _SnackContent(
        backgroundColor: AppDesignTokens.colorFeedbackInfo,
        icon: null,
        message: message,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    _showOverlay(
      context,
      _SnackContent(
        backgroundColor: AppDesignTokens.colorFeedbackSuccess,
        icon: const Icon(
          Icons.check_circle,
          color: AppDesignTokens.colorContentInverse,
        ),
        message: message,
      ),
    );
  }

  static void error(BuildContext context, String message) {
    _showOverlay(
      context,
      _SnackContent(
        backgroundColor: AppDesignTokens.colorFeedbackError,
        icon: const Icon(
          Icons.error,
          color: AppDesignTokens.colorContentInverse,
        ),
        message: message,
      ),
    );
  }
}

/// internal widget that animates from the top and removes itself after a short
/// delay.
class _TopSnackBar extends StatefulWidget {
  const _TopSnackBar({required this.entry, required this.child});

  final OverlayEntry entry;
  final Widget child;

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
    Future.delayed(const Duration(seconds: 3), () {
      _controller.reverse().then((_) => widget.entry.remove());
    });
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
