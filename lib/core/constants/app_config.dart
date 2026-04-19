class AppConfig {
  // App Information
  static const String appName = 'JasaFix';
  static const String appVersion = '1.0.0';
  static const int appVersionCode = 1;
  
  // Company Information
  static const String companyName = 'JasaFix Indonesia';
  static const String supportEmail = 'support@jasafix.id';
  static const String supportPhone = '0812-3456-7890';
  static const String website = 'https://jasafix.id';
  
  // API Configuration (for later phases)
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api'; // Android emulator localhost
  static const String wsUrl = 'ws://10.0.2.2:6001'; // Laravel Reverb WebSocket
  
  // iOS Simulator alternative:
  // static const String apiBaseUrl = 'http://localhost:8000/api';
  // static const String wsUrl = 'ws://localhost:6001';
  
  static const int apiTimeoutSeconds = 30;
  
  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enablePushNotifications = false; // Phase 4
  static const bool enableChat = true;
  static const bool debugMode = true; // Set to false in production
  
  // Business Rules
  static const double taxPercent = 0.0;
  static const String currency = 'IDR';
  static const String currencySymbol = 'Rp';
  
  // UI Configuration
  static const int snackbarDurationSeconds = 3;
  static const int debounceMilliseconds = 500;
  static const int maxImageUploadMB = 5;
  
  // Prevent instantiation
  AppConfig._();
}