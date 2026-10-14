import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_collector/features/auth/view/login_screen.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class OnboardingScreen extends StatelessWidget {
  static const routeName = '/OnboardingScreen';

  const OnboardingScreen({super.key});

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full Image Content (Leaf bg, Logo, Scooter Mascot, Title & Subtitle)
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_content.png',
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
            ),
          ),

          // Interactive Controls Overlay
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.spMin),
              child: Column(
                children: [
                  SizedBox(height: 8.spMin),

                  // Top-Right "Skip" Button
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => _navigateToLogin(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.spMin,
                          vertical: 8.spMin,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.spMin),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10.spMin,
                              offset: Offset(0, 2.spMin),
                            ),
                          ],
                        ),
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            color: SuchigoColors.collectorGreen,
                            fontSize: 14.spMin,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Bottom "Get started" Button
                  SizedBox(
                    width: double.infinity,
                    height: 54.spMin,
                    child: ElevatedButton(
                      onPressed: () => _navigateToLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SuchigoColors.onboardingButtonBg,
                        foregroundColor: SuchigoColors.darkGreenText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.spMin),
                        ),
                      ),
                      child: Text(
                        "Get started",
                        style: TextStyle(
                          fontSize: 16.spMin,
                          fontWeight: FontWeight.w700,
                          color: SuchigoColors.darkGreenText,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 18.spMin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
