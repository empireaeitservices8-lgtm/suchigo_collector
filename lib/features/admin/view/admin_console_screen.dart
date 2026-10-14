import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view/tabs/admin_collectors_tab.dart';
import 'package:suchigo_collector/features/admin/view/tabs/admin_overview_tab.dart';
import 'package:suchigo_collector/features/admin/view/tabs/admin_profile_tab.dart';
import 'package:suchigo_collector/features/admin/view/tabs/admin_setup_tab.dart';
import 'package:suchigo_collector/features/admin/view_model/admin_view_model.dart';
import 'package:suchigo_collector/features/auth/view/login_screen.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class AdminConsoleScreen extends StatefulWidget {
  static const routeName = '/AdminConsoleScreen';

  const AdminConsoleScreen({super.key});

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  final List<Widget> _tabs = const [
    AdminOverviewTab(),
    AdminCollectorsTab(),
    AdminSetupTab(),
    AdminProfileTab(),
  ];

  String _getSubtitle(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return "Overview & Analytics";
      case 1:
        return "Collector Operations";
      case 2:
        return "System Setup & Configs";
      case 3:
        return "Admin Account & Security";
      default:
        return "Overview & Analytics";
    }
  }

  void _handleLogout() async {
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

    if (shouldLogout == true && mounted) {
      await context.read<AuthViewModel>().logout();
      if (mounted) {
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
    final adminVm = context.watch<AdminViewModel>();
    final currentTab = adminVm.selectedTabIndex;

    return Scaffold(
      backgroundColor: SuchigoColors.adminBackground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Top App Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.spMin,
                    vertical: 12.spMin,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Admin Console",
                              style: TextStyle(
                                fontSize: 22.spMin,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1B4D3E),
                                letterSpacing: -0.3.spMin,
                              ),
                            ),
                            SizedBox(height: 2.spMin),
                            Text(
                              _getSubtitle(currentTab),
                              style: TextStyle(
                                fontSize: 13.spMin,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7A8B7E),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Action 1: Refresh Button
                      GestureDetector(
                        onTap: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Refreshing system records..."),
                              backgroundColor: SuchigoColors.collectorGreen,
                              duration: Duration(milliseconds: 900),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          await adminVm.refreshData();
                        },
                        child: Container(
                          width: 42.spMin,
                          height: 42.spMin,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            color: const Color(0xFF1D723C),
                            size: 26.spMin,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.spMin),

                      // Right Action 2: Logout Button (Pale Peach Circle)
                      GestureDetector(
                        onTap: _handleLogout,
                        child: Container(
                          width: 44.spMin,
                          height: 44.spMin,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            color: const Color(0xFFE53935),
                            size: 20.spMin,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Tab Content Body
                Expanded(
                  child: IndexedStack(
                    index: currentTab,
                    children: _tabs,
                  ),
                ),
              ],
            ),

            // 3. Floating Bottom Navigation Bar
            Positioned(
              left: 16.spMin,
              right: 16.spMin,
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 14.spMin,
              child: Container(
                height: 62.spMin,
                padding: EdgeInsets.symmetric(horizontal: 10.spMin),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32.spMin),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20.spMin,
                      offset: Offset(0, 6.spMin),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Tab 0: Overview
                    _buildNavItem(
                      index: 0,
                      label: "Overview",
                      icon: Icons.dashboard_rounded,
                      inactiveIcon: Icons.dashboard_outlined,
                      isActive: currentTab == 0,
                      onTap: () => adminVm.setTab(0),
                    ),

                    // Tab 1: Collectors (with badge "15")
                    _buildNavItem(
                      index: 1,
                      label: "Collectors",
                      icon: Icons.people_alt_rounded,
                      inactiveIcon: Icons.people_alt_rounded,
                      isActive: currentTab == 1,
                      badgeText: "${adminVm.onDutyCount}",
                      onTap: () => adminVm.setTab(1),
                    ),

                    // Tab 2: Setup
                    _buildNavItem(
                      index: 2,
                      label: "Setup",
                      icon: Icons.tune_rounded,
                      inactiveIcon: Icons.tune_rounded,
                      isActive: currentTab == 2,
                      onTap: () => adminVm.setTab(2),
                    ),

                    // Tab 3: Profile
                    _buildNavItem(
                      index: 3,
                      label: "Profile",
                      icon: Icons.admin_panel_settings_rounded,
                      inactiveIcon: Icons.admin_panel_settings_rounded,
                      isActive: currentTab == 3,
                      onTap: () => adminVm.setTab(3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData inactiveIcon,
    required bool isActive,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    if (isActive) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.spMin,
            vertical: 9.spMin,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFDFF3E0),
            borderRadius: BorderRadius.circular(20.spMin),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: const Color(0xFF1D723C),
                size: 20.spMin,
              ),
              SizedBox(width: 8.spMin),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5.spMin,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1D723C),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 8.spMin),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              inactiveIcon,
              color: const Color(0xFF9E9E9E),
              size: 24.spMin,
            ),
            if (badgeText != null)
              Positioned(
                top: -4.spMin,
                right: -6.spMin,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.spMin,
                    vertical: 1.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D723C),
                    borderRadius: BorderRadius.circular(10.spMin),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16.spMin,
                    minHeight: 16.spMin,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 9.5.spMin,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
