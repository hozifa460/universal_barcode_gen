// AppConstants: app-wide constant values.
// All Hive box names, route paths, and key strings live here.

class AppConstants {
  AppConstants._();

  // App identity
  static const String appName = 'Universal Barcode & QR Generator';
  static const String appNameAr = 'مولّد الباركود و QR الشامل';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Hive box names
  static const String historyBox = 'history_box';
  static const String foldersBox = 'folders_box';
  static const String tagsBox = 'tags_box';
  static const String favoritesBox = 'favorites_box';
  static const String presetsBox = 'presets_box';
  static const String scanHistoryBox = 'scan_history_box';
  static const String templatesBox = 'templates_box';
  static const String settingsBox = 'settings_box';

  // SharedPreferences keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefLocale = 'locale';
  static const String prefDefaultEcLevel = 'default_ec_level';
  static const String prefClipboardMonitor = 'clipboard_monitor';
  static const String prefAutoOpenUrls = 'auto_open_urls';

  // Route paths
  static const String routeHome = '/';
  static const String routeGenerator = '/generator';
  static const String routeScanner = '/scanner';
  static const String routeHistory = '/history';
  static const String routeBatch = '/batch';
  static const String routeConverter = '/converter';
  static const String routeSettings = '/settings';
  static const String routeFolderDetail = '/folder';
  static const String routeScanHistory = '/scan-history';

  // Limits
  static const int maxHistoryItems = 5000;
  static const int maxBatchItems = 1000;
  static const int maxQrContentLength = 2953; // QR Version 40 max binary
  static const int maxQrVersion = 40;
  static const int defaultQrSize = 1024;
  static const int maxExportResolution = 8192; // 8K
  static const int minQrSize = 128;
  static const int defaultMargin = 4; // modules
  static const double defaultBorderRadius = 8.0;

  // Animation durations
  static const Duration shortAnim = Duration(milliseconds: 150);
  static const Duration medAnim = Duration(milliseconds: 300);
  static const Duration longAnim = Duration(milliseconds: 500);

  // Supported locales (BCP-47)
  static const List<String> supportedLocales = ['en', 'ar'];
}
