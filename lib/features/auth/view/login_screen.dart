import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view/admin_console_screen.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/features/home/view/home_screen.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/LoginScreen';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get _isFormValid =>
      _usernameController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your username and password"),
          backgroundColor: SuchigoColors.collectorGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.login(
      username: username,
      password: password,
      role: authVm.loginSelectedRole == UserRole.collector ? 'collector' : 'admin',
    );

    if (!mounted) return;

    if (success) {
      final name = authVm.collector?.name ?? username;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome back, $name! Login successful."),
          backgroundColor: SuchigoColors.collectorGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (authVm.loginSelectedRole == UserRole.adminPortal || authVm.isAdmin || username.toLowerCase() == 'admin') {
        Navigator.pushReplacementNamed(context, AdminConsoleScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authVm.errorMessage ?? "Login failed. Please check credentials.",
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authVm = context.watch<AuthViewModel>();
    final isCollector = authVm.loginSelectedRole == UserRole.collector;
    final isEnabled = _isFormValid && !authVm.isLoading;

    return Scaffold(
      backgroundColor: SuchigoColors.loginTopBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 100.spMin),

              // Top Mascot Illustration (Tightly positioned above card)
              Container(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.28,
                  maxWidth: 320.spMin,
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.spMin),
                child: Image.asset(
                  'assets/images/login_mascot_exact.png',
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 80.spMin),

              // Floating Rounded White Card
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(20.spMin, 0, 20.spMin, 24.spMin),
                padding:
                    EdgeInsets.fromLTRB(22.spMin, 26.spMin, 22.spMin, 28.spMin),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.spMin),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 18.spMin,
                      offset: Offset(0, 4.spMin),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // "Welcome Back"
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 24.spMin,
                        fontWeight: FontWeight.w800,
                        color: SuchigoColors.textDark,
                        letterSpacing: -0.2.spMin,
                      ),
                    ),

                    SizedBox(height: 6.spMin),

                    // "Login to continue"
                    Text(
                      "Login to continue",
                      style: TextStyle(
                        fontSize: 13.5.spMin,
                        fontWeight: FontWeight.w400,
                        color: SuchigoColors.textSub,
                      ),
                    ),

                    SizedBox(height: 22.spMin),

                    // Segmented Switch [Collector | Admin Portal]
                    Container(
                      height: 48.spMin,
                      padding: EdgeInsets.all(4.spMin),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24.spMin),
                      ),
                      child: Row(
                        children: [
                          // Collector Tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                authVm.setLoginRole(UserRole.collector);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isCollector
                                      ? SuchigoColors.collectorGreen
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.spMin),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Collector",
                                  style: TextStyle(
                                    fontSize: 14.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: isCollector
                                        ? Colors.white
                                        : SuchigoColors.textAdmin,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Admin Portal Tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                authVm.setLoginRole(UserRole.adminPortal);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isCollector
                                      ? SuchigoColors.collectorGreen
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.spMin),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Admin Portal",
                                  style: TextStyle(
                                    fontSize: 14.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: !isCollector
                                        ? Colors.white
                                        : SuchigoColors.textAdmin,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 18.spMin),

                    // Username Input Field
                    TextField(
                      controller: _usernameController,
                      onChanged: (_) => authVm.notifyFormChanged(),
                      style: TextStyle(
                        fontSize: 15.spMin,
                        color: SuchigoColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Username",
                        hintStyle: TextStyle(
                          color: const Color(0xFFBDBDBD),
                          fontSize: 14.5.spMin,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.spMin,
                          vertical: 16.spMin,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.spMin),
                          borderSide: BorderSide(
                            color: const Color(0xFFE8F5E9),
                            width: 1.2.spMin,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.spMin),
                          borderSide: BorderSide(
                            color: const Color(0xFFE8F5E9),
                            width: 1.2.spMin,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.spMin),
                          borderSide: BorderSide(
                            color: const Color(0xFFE8F5E9),
                            width: 1.2.spMin,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.spMin),
                          borderSide: BorderSide(
                            color: const Color(0xFF1D723C),
                            width: 1.5.spMin,
                          ),
                        ),
                        suffixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: const Color(0xFF1D723C),
                          size: 22.spMin,
                        ),
                      ),
                    ),

                    SizedBox(height: 14.spMin),

                    // Password Input Field
                    TextField(
                      controller: _passwordController,
                      obscureText: authVm.obscureLoginPassword,
                      onChanged: (_) => authVm.notifyFormChanged(),
                      style: TextStyle(
                        fontSize: 15.spMin,
                        color: SuchigoColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(
                          color: const Color(0xFFBDBDBD),
                          fontSize: 14.5.spMin,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.spMin,
                          vertical: 16.spMin,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.spMin),
                          borderSide: BorderSide(
                            color: const Color(0xFFE8F5E9),
                            width: 1.2.spMin,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.spMin),
                          borderSide: BorderSide(
                            color: const Color(0xFFE8F5E9),
                            width: 1.2.spMin,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.spMin),
                          borderSide: BorderSide(
                            color: const Color(0xFFE8F5E9),
                            width: 1.2.spMin,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.spMin),
                          borderSide: BorderSide(
                            color: const Color(0xFF1D723C),
                            width: 1.5.spMin,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            authVm.toggleObscureLoginPassword();
                          },
                          child: Icon(
                            authVm.obscureLoginPassword
                                ? Icons.lock_outline_rounded
                                : Icons.lock_open_rounded,
                            color: const Color(0xFF1D723C),
                            size: 22.spMin,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.spMin),

                    // Rounded Pill Login Button
                    SizedBox(
                      width: 220.spMin,
                      height: 50.spMin,
                      child: ElevatedButton(
                        onPressed: isEnabled ? _handleLogin : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormValid
                              ? SuchigoColors.collectorGreen
                              : const Color(0xFFE0E0E0),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE0E0E0),
                          disabledForegroundColor: Colors.white70,
                          elevation: _isFormValid ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.spMin),
                          ),
                        ),
                        child: authVm.isLoading
                            ? SizedBox(
                                width: 20.spMin,
                                height: 20.spMin,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2.spMin,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 16.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8.spMin),
                                  Icon(
                                    Icons.arrow_circle_right_rounded,
                                    color: Colors.white,
                                    size: 22.spMin,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 8.spMin),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
