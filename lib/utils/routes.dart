import 'package:flutter/material.dart';
import 'package:suchigo_collector/features/admin/view/admin_console_screen.dart';
import 'package:suchigo_collector/features/admin/view/manage_bags_screen.dart';
import 'package:suchigo_collector/features/admin/view/manage_waste_types_screen.dart';
import 'package:suchigo_collector/features/auth/view/login_screen.dart';
import 'package:suchigo_collector/features/auth/view/register_screen.dart';
import 'package:suchigo_collector/features/history/view/collection_history_screen.dart';
import 'package:suchigo_collector/features/home/view/home_screen.dart';
import 'package:suchigo_collector/features/onboarding/view/onboarding_screen.dart';
import 'package:suchigo_collector/features/orders/view/active_orders_screen.dart';
import 'package:suchigo_collector/features/orders/view/navigation_screen.dart';
import 'package:suchigo_collector/features/orders/view/update_status_screen.dart';
import 'package:suchigo_collector/features/orders/view/waste_configuration_screen.dart';
import 'package:suchigo_collector/features/splashscreen/view/splashscreen.dart';
import 'package:suchigo_collector/features/wards/view/select_ward_screen.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/utils/connection_failed_screen.dart';

Map<String, Widget Function(BuildContext context)> appRoutes() => {
      SplashScreen.routeName: (context) => const SplashScreen(),
      OnboardingScreen.routeName: (context) => const OnboardingScreen(),
      LoginScreen.routeName: (context) => const LoginScreen(),
      RegisterScreen.routeName: (context) => const RegisterScreen(),
      HomeScreen.routeName: (context) => const HomeScreen(),
      AdminConsoleScreen.routeName: (context) => const AdminConsoleScreen(),
      SelectWardScreen.routeName: (context) => const SelectWardScreen(),
      ActiveOrdersScreen.routeName: (context) => const ActiveOrdersScreen(),
      ManageBagsScreen.routeName: (context) => const ManageBagsScreen(),
      ManageWasteTypesScreen.routeName: (context) =>
          const ManageWasteTypesScreen(),
      CollectionHistoryScreen.routeName: (context) =>
          const CollectionHistoryScreen(),
    };

Widget? _getScreen(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreen.routeName:
      return const SplashScreen();
    case OnboardingScreen.routeName:
      return const OnboardingScreen();
    case LoginScreen.routeName:
      return const LoginScreen();
    case RegisterScreen.routeName:
      return const RegisterScreen();
    case HomeScreen.routeName:
      return const HomeScreen();
    case AdminConsoleScreen.routeName:
      return const AdminConsoleScreen();
    case SelectWardScreen.routeName:
      final args = settings.arguments;
      if (args is Map<String, dynamic>) {
        return SelectWardScreen(
          localBodyId: args['localBodyId'] as int?,
          localBodyName: args['localBodyName'] as String?,
          selectedWard: args['selectedWard'] as WardModel?,
          selectedWardName: args['selectedWardName'] as String?,
        );
      }
      return const SelectWardScreen();
    case ActiveOrdersScreen.routeName:
      final args = settings.arguments;
      if (args is String) {
        return ActiveOrdersScreen(filterWard: args);
      }
      return const ActiveOrdersScreen();
    case ManageBagsScreen.routeName:
      return const ManageBagsScreen();
    case ManageWasteTypesScreen.routeName:
      return const ManageWasteTypesScreen();
    case UpdateStatusScreen.routeName:
      final order = settings.arguments as LocationPickupModel;
      return UpdateStatusScreen(order: order);
    case NavigationScreen.routeName:
      final order = settings.arguments as LocationPickupModel;
      return NavigationScreen(order: order);
    case WasteConfigurationScreen.routeName:
      final order = settings.arguments as LocationPickupModel;
      return WasteConfigurationScreen(order: order);
    case CollectionHistoryScreen.routeName:
      return const CollectionHistoryScreen();
    case ConnectionFailedScreen.routeName:
      ConnectionFailedScreenParams params =
          settings.arguments as ConnectionFailedScreenParams;
      return ConnectionFailedScreen(
        param: params,
      );
    default:
      return null;
  }
}

RouteFactory onAppGenerateRoute() => (settings) {
      Widget? screen = _getScreen(settings);
      if (screen != null) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, a, __, c) {
            return FadeTransition(opacity: a, child: c);
          },
        );
      }
      return null;
    };
