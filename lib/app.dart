import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_config.dart';
import 'core/routing/app_router.dart';
import 'providers/app_state.dart';

class JasafixApp extends StatelessWidget {
  const JasafixApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: AppConfig.debugMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppConfig.enableDarkMode ? AppTheme.darkTheme : null,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.createRouter(appState),
    );
  }
}