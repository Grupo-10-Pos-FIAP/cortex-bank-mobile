import 'package:cortex_bank_mobile/core/code_splitting/deferred_page_loader.dart';
import 'package:flutter/material.dart';
import 'package:cortex_bank_mobile/features/auth/presentation/pages/profile_page.dart'
    deferred as profile_page;

class ProfileTabLoader extends StatelessWidget {
  const ProfileTabLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return DeferredPageLoader(
      loadLibrary: profile_page.loadLibrary,
      builder: () => profile_page.ProfilePage(),
    );
  }
}
