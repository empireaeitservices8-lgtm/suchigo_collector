import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view_model/admin_view_model.dart';
import 'package:suchigo_collector/features/auth/view/login_screen.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  void _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.spMin),
        ),
        title: Text(
          "Logout",
          style: TextStyle(
            fontSize: 18.spMin,
            fontWeight: FontWeight.w800,
            color: SuchigoColors.textDark,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: TextStyle(
            fontSize: 14.spMin,
            color: SuchigoColors.textAdmin,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: 14.spMin,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              "Logout",
              style: TextStyle(
                fontSize: 14.spMin,
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await context.read<AuthViewModel>().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final adminVm = context.watch<AdminViewModel>();
    final collector = authVm.collector;

    final displayName = collector?.name.isNotEmpty == true
        ? collector!.name
        : (collector?.username.isNotEmpty == true
            ? collector!.username
            : "Administrator");
    final displayEmail = collector?.email.isNotEmpty == true
        ? collector!.email
        : "admin@suchigo.com";

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 12.spMin),
      child: Column(
        children: [
          // 1. Main Profile Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.spMin, vertical: 24.spMin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.spMin),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 12.spMin,
                  offset: Offset(0, 4.spMin),
                ),
              ],
            ),
            child: Column(
              children: [
                // Circular Avatar
                Container(
                  width: 84.spMin,
                  height: 84.spMin,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    color: const Color(0xFF1D723C),
                    size: 44.spMin,
                  ),
                ),

                SizedBox(height: 14.spMin),

                // Name
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 20.spMin,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B4D3E),
                  ),
                ),

                SizedBox(height: 8.spMin),

                // Super Admin Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.spMin,
                    vertical: 5.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D723C),
                    borderRadius: BorderRadius.circular(16.spMin),
                  ),
                  child: Text(
                    "Super Admin • Operations",
                    style: TextStyle(
                      fontSize: 12.spMin,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.spMin),
                  child: Divider(
                    color: const Color(0xFFEEEEEE),
                    height: 1.spMin,
                  ),
                ),

                // Info Rows: Email, Local Body, Session Role
                _buildInfoRow(
                  icon: Icons.mail_outline_rounded,
                  label: "Email",
                  value: displayEmail,
                ),

                SizedBox(height: 14.spMin),

                _buildInfoRow(
                  icon: Icons.location_city_outlined,
                  label: "Local Body",
                  value: "Kochi Corp / Kalamassery",
                ),

                SizedBox(height: 14.spMin),

                _buildInfoRow(
                  icon: Icons.shield_outlined,
                  label: "Session Role",
                  value: "System Administrator",
                ),
              ],
            ),
          ),

          SizedBox(height: 16.spMin),

          // 2. Action Options Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.spMin),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 12.spMin,
                  offset: Offset(0, 4.spMin),
                ),
              ],
            ),
            child: Column(
              children: [
                // Item 1: Sync & Refresh System Data
                InkWell(
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Syncing system data..."),
                        backgroundColor: SuchigoColors.collectorGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    await adminVm.refreshData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("System data refreshed successfully!"),
                          backgroundColor: SuchigoColors.collectorGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.spMin),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.spMin,
                      vertical: 18.spMin,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          color: const Color(0xFF1D723C),
                          size: 24.spMin,
                        ),
                        SizedBox(width: 14.spMin),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sync & Refresh System Data",
                                style: TextStyle(
                                  fontSize: 14.5.spMin,
                                  fontWeight: FontWeight.w800,
                                  color: SuchigoColors.textDark,
                                ),
                              ),
                              SizedBox(height: 2.spMin),
                              Text(
                                "Reload collector records & statistics",
                                style: TextStyle(
                                  fontSize: 11.5.spMin,
                                  color: const Color(0xFF757575),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: const Color(0xFF9E9E9E),
                          size: 22.spMin,
                        ),
                      ],
                    ),
                  ),
                ),

                Divider(
                  color: const Color(0xFFF0F0F0),
                  height: 1.spMin,
                ),

                // Item 2: Logout Admin Console
                InkWell(
                  onTap: () => _handleLogout(context),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24.spMin),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.spMin,
                      vertical: 18.spMin,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: const Color(0xFFE53935),
                          size: 24.spMin,
                        ),
                        SizedBox(width: 14.spMin),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Logout Admin Console",
                                style: TextStyle(
                                  fontSize: 14.5.spMin,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFE53935),
                                ),
                              ),
                              SizedBox(height: 2.spMin),
                              Text(
                                "Sign out of current administrator session",
                                style: TextStyle(
                                  fontSize: 11.5.spMin,
                                  color: const Color(0xFF757575),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: const Color(0xFFE53935),
                          size: 22.spMin,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 90.spMin), // Floating bottom nav bar padding
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.spMin,
          color: const Color(0xFF757575),
        ),
        SizedBox(width: 10.spMin),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.spMin,
            color: const Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w700,
            color: SuchigoColors.textDark,
          ),
        ),
      ],
    );
  }
}
