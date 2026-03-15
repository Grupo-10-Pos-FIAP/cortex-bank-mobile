import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cortex_bank_mobile/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen(
      _handleConnectivity,
    );
  }

  void _handleConnectivity(List<ConnectivityResult> result) {
    if (!mounted) return;

    final isOffline = result.contains(ConnectivityResult.none);

    if (isOffline) {
      _wasOffline = true;
      // Exibe o erro e mantém na tela (duration: null)
      AppSnackBar.error(context, 'Você está offline.', duration: null);
    } else {
      // Só entra aqui se estava offline antes e agora a lista não contém .none
      if (_wasOffline) {
        _wasOffline = false;

        // CORREÇÃO: Usa o seu método de fechar o Overlay, não o do Flutter
        AppSnackBar.hide();

        AppSnackBar.success(context, 'Conexão restabelecida!');
      }
    }
  }


  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
