import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:suchigo_collector/config/app_config.dart';
import 'package:suchigo_collector/l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';

import 'features/admin/view_model/admin_view_model.dart';
import 'features/auth/view_model/auth_view_model.dart';
import 'features/history/view_model/history_view_model.dart';
import 'features/home/view_model/home_view_model.dart';
import 'features/orders/view_model/order_view_model.dart';
import 'features/orders/view_model/waste_configuration_view_model.dart';
import 'features/wards/view_model/ward_view_model.dart';
import 'features/splashscreen/view/splashscreen.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/interceptors.dart';
import 'utils/localization.dart';
import 'utils/routes.dart';
import 'utils/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LanguageProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => AdminViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => WardViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => HistoryViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => WasteConfigurationViewModel(),
        ),
      ],
      builder: (context, child) => ScreenUtilInit(
        designSize: Size(
          AppConfig.designWidth.toDouble(),
          AppConfig.designHeight.toDouble(),
        ),
        builder: (context, child) => AdaptiveTheme(
          initial: AdaptiveThemeMode.light,
          light: appLightTheme,
          dark: appDarkTheme,
          builder: (theme, darkTheme) {
            return MaterialApp(
              navigatorKey: AppConfig.navKey,
              title: AppConfig.appName,
              debugShowCheckedModeBanner: false,
              themeMode: context.watch<ThemeProvider>().themeMode,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
                Locale('ja', ''),
              ],
              theme: themedForLocale(
                theme,
                context.watch<LanguageProvider>().locale,
              ),
              darkTheme: themedForLocale(
                darkTheme,
                context.watch<LanguageProvider>().locale,
              ),
              locale: context.watch<LanguageProvider>().locale,
              initialRoute: SplashScreen.routeName,
              onGenerateRoute: onAppGenerateRoute(),
              routes: appRoutes(),
              builder: (context, child) {
                LanguageProvider.initContext(context);
                Localization.init(context);

                if (!kDebugMode || !AppConfig.isDebugMode) {
                  return child!;
                }

                return AppStackInterceptorBuilder(child: child!);
              },
            );
          },
        ),
      ),
    );
  }
}
