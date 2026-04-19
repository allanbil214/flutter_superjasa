import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/app_state.dart';
import 'core/constants/app_config.dart';

void main() {
  // Print app info in debug mode
  if (AppConfig.debugMode) {
    print('🚀 Starting ${AppConfig.appName} v${AppConfig.appVersion}');
    print('📱 Debug Mode: ${AppConfig.debugMode}');
    print('🌐 API URL: ${AppConfig.apiBaseUrl}');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const JasafixApp(),
    ),
  );
}