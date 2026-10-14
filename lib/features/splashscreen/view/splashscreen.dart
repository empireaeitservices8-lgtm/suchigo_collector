import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view/admin_console_screen.dart';
import 'package:suchigo_collector/features/auth/view/login_screen.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/features/home/view/home_screen.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/SplashScreen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() {
    _timer = Timer(const Duration(milliseconds: 2000), () async {
      if (!mounted) return;

      final authVm = context.read<AuthViewModel>();
      final hasActiveSession = await authVm.checkSavedSession();

      if (!mounted) return;

      if (hasActiveSession) {
        if (authVm.isAdmin) {
          Navigator.pushReplacementNamed(context, AdminConsoleScreen.routeName);
        } else {
          Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        }
      } else {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Centered Exact SuchiGo Logo
              Image.asset(
                'assets/images/suchigo_logo_exact.png',
                width: 220.spMin,
                fit: BoxFit.contain,
              ),

              const Spacer(flex: 1),

              // Green Circular Spinner
              SizedBox(
                width: 40.spMin,
                height: 40.spMin,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5.spMin,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    SuchigoColors.collectorGreen,
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
