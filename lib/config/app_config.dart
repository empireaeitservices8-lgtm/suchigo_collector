import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:suchigo_collector/utils/enums.dart';

class AppConfig {
  static const appName = "Suchigo Collector";
  static const bundleId = "com.suchiGo.collector";
  static const designWidth = 375;
  static const designHeight = 812;

  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
  GlobalKey bottomNavigationKey = GlobalKey();

  // In release builds (flutter build apk / appbundle), kDebugMode is automatically false.
  // Set to false to disable the logger floating icon and API overlay.
  static bool isDebugMode = kDebugMode;

  static EnumBuildEnvironment server = EnumBuildEnvironment.dg;

  // Backend API Base URL
  static String apiBaseUrl = "https://suchigo.pythonanywhere.com/api/";
}
