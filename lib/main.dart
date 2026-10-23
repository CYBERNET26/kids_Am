import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: KidsAmApp(),
    ),
  );
}

class KidsAmApp extends StatelessWidget {
  const KidsAmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kids Am - Aprende y Juega',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.playfulTheme,
      routerConfig: appRouter,
    );
  }
}
