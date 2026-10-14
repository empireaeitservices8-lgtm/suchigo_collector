import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/RegisterScreen';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _usernameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty &&
      _confirmPasswordController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authVm = context.watch<AuthViewModel>();
    final isCollector = authVm.registerSelectedRole == UserRole.collector;

    return Scaffold(
      backgroundColor: SuchigoColors.loginTopBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16.spMin),

              // Top Mascot Illustration
              Container(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.22,
                  maxWidth: 260.spMin,
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.spMin),
                child: Image.asset(
                  'assets/images/login_mascot_exact.png',
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 8.spMin),

              // Floating Rounded White Card
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(20.spMin, 0, 20.spMin, 20.spMin),
                padding: EdgeInsets.fromLTRB(22.spMin, 24.spMin, 22.spMin, 24.spMin),
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
                    // "Create Account"
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 24.spMin,
                        fontWeight: FontWeight.w800,
                        color: SuchigoColors.textDark,
                        letterSpacing: -0.2.spMin,
                      ),
                    ),

                    SizedBox(height: 4.spMin),

                    // "Register to continue"
                    Text(
                      "Register to continue",
                      style: TextStyle(
                        fontSize: 13.5.spMin,
                        fontWeight: FontWeight.w400,
                        color: SuchigoColors.textSub,
                      ),
                    ),

                    SizedBox(height: 18.spMin),

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
                                authVm.setRegisterRole(UserRole.collector);
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
                                authVm.setRegisterRole(UserRole.adminPortal);
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

                    SizedBox(height: 16.spMin),

                    // Full Name Field
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => authVm.notifyFormChanged(),
                      style: TextStyle(
                        fontSize: 15.spMin,
                        color: SuchigoColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Full Name",
                        hintStyle: TextStyle(
                          color: const Color(0xFFBDBDBD),
                          fontSize: 14.5.spMin,
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
                          Icons.badge_outlined,
                          color: const Color(0xFF1D723C),
                          size: 22.spMin,
                        ),
                      ),
                    ),

                    SizedBox(height: 12.spMin),

                    // Username Field
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

                    SizedBox(height: 12.spMin),

                    // Phone / Email Field
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => authVm.notifyFormChanged(),
                      style: TextStyle(
                        fontSize: 15.spMin,
                        color: SuchigoColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Phone Number",
                        hintStyle: TextStyle(
                          color: const Color(0xFFBDBDBD),
                          fontSize: 14.5.spMin,
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
                          Icons.phone_outlined,
                          color: const Color(0xFF1D723C),
                          size: 22.spMin,
                        ),
                      ),
                    ),

                    SizedBox(height: 12.spMin),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: authVm.obscureRegisterPassword,
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
                            authVm.toggleObscureRegisterPassword();
                          },
                          child: Icon(
                            authVm.obscureRegisterPassword
                                ? Icons.lock_outline_rounded
                                : Icons.lock_open_rounded,
                            color: const Color(0xFF1D723C),
                            size: 22.spMin,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12.spMin),

                    // Confirm Password Field
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: authVm.obscureRegisterConfirmPassword,
                      onChanged: (_) => authVm.notifyFormChanged(),
                      style: TextStyle(
                        fontSize: 15.spMin,
                        color: SuchigoColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        hintStyle: TextStyle(
                          color: const Color(0xFFBDBDBD),
                          fontSize: 14.5.spMin,
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
                            authVm.toggleObscureRegisterConfirmPassword();
                          },
                          child: Icon(
                            authVm.obscureRegisterConfirmPassword
                                ? Icons.lock_outline_rounded
                                : Icons.lock_open_rounded,
                            color: const Color(0xFF1D723C),
                            size: 22.spMin,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.spMin),

                    // Rounded Pill Register Button
                    SizedBox(
                      width: 220.spMin,
                      height: 50.spMin,
                      child: ElevatedButton(
                        onPressed: _isFormValid ? () {} : null,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Register",
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
