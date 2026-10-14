import 'package:suchigo_collector/config/app_config.dart';
import 'package:suchigo_collector/utils/enums.dart';

class UrlHelpers {
  static EnumBuildEnvironment get server => AppConfig.server;

  static String get baseURL {
    return AppConfig.apiBaseUrl;
  }

  static String get key {
    return '';
  }

  static String get baseUrlApi {
    return AppConfig.apiBaseUrl;
  }
}
