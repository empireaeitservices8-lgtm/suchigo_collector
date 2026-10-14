import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_collector/features/admin/view/manage_bags_screen.dart';
import 'package:suchigo_collector/features/admin/view/manage_waste_types_screen.dart';

class AdminSetupTab extends StatelessWidget {
  const AdminSetupTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 12.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            "System Setup & Configurations",
            style: TextStyle(
              fontSize: 16.5.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B4D3E),
            ),
          ),

          SizedBox(height: 16.spMin),

          // 2x2 Grid of Setup Cards
          Row(
            children: [
              // 1. Manage Bags
              Expanded(
                child: _buildSetupCard(
                  context: context,
                  icon: Icons.shopping_bag_outlined,
                  iconBgColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF1D723C),
                  title: "Manage Bags",
                  subtitle: "QR bag capacities & tariffs",
                  onTap: () {
                    Navigator.pushNamed(context, ManageBagsScreen.routeName);
                  },
                ),
              ),

              SizedBox(width: 14.spMin),

              // 2. Waste Categories
              Expanded(
                child: _buildSetupCard(
                  context: context,
                  icon: Icons.recycling_rounded,
                  iconBgColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF1D723C),
                  title: "Waste Categories",
                  subtitle: "Configure waste types",
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      ManageWasteTypesScreen.routeName,
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 14.spMin),

          Row(
            children: [
              // 3. Fleet & Vehicles
              Expanded(
                child: _buildSetupCard(
                  context: context,
                  icon: Icons.directions_bus_outlined,
                  iconBgColor: const Color(0xFFE0F2F1),
                  iconColor: const Color(0xFF00897B),
                  title: "Fleet & Vehicles",
                  subtitle: "Vehicle registry &\nassignments",
                  onTap: () {
                    _showFloatingMessage(
                      context: context,
                      icon: Icons.directions_bus_rounded,
                      title: "Fleet & Vehicles",
                      subtitle:
                          "Fleet management is configured via collector assignment.",
                    );
                  },
                ),
              ),

              SizedBox(width: 14.spMin),

              // 4. Wards & Local Bodies
              Expanded(
                child: _buildSetupCard(
                  context: context,
                  icon: Icons.map_outlined,
                  iconBgColor: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFFB8C00),
                  title: "Wards & Local Bodies",
                  subtitle: "Kalamassery & Kochi\nregion",
                  onTap: () {
                    _showFloatingMessage(
                      context: context,
                      icon: Icons.map_rounded,
                      title: "Wards & Local Bodies",
                      subtitle:
                          "Local body region: Kochi Corporation / Kalamassery",
                    );
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 20.spMin),

          // Status Card: "System Operations Active"
          Container(
            padding: EdgeInsets.all(18.spMin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.spMin),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10.spMin,
                  offset: Offset(0, 3.spMin),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44.spMin,
                  height: 44.spMin,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    color: const Color(0xFF1D723C),
                    size: 24.spMin,
                  ),
                ),
                SizedBox(width: 14.spMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "System Operations Active",
                        style: TextStyle(
                          fontSize: 14.5.spMin,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B4D3E),
                        ),
                      ),
                      SizedBox(height: 3.spMin),
                      Text(
                        "All collection endpoints and QR bag assignments are online.",
                        style: TextStyle(
                          fontSize: 12.spMin,
                          color: const Color(0xFF757575),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

  Widget _buildSetupCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140.spMin,
        padding: EdgeInsets.all(16.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.spMin),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10.spMin,
              offset: Offset(0, 3.spMin),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38.spMin,
              height: 38.spMin,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10.spMin),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22.spMin,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B4D3E),
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.spMin,
                    color: const Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFloatingMessage({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.fromLTRB(16.spMin, 0, 16.spMin, 16.spMin),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 3),
        content: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.spMin,
            vertical: 14.spMin,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF14291D),
            borderRadius: BorderRadius.circular(18.spMin),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16.spMin,
                offset: Offset(0, 6.spMin),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42.spMin,
                height: 42.spMin,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A2B),
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF26A69A),
                  size: 22.spMin,
                ),
              ),
              SizedBox(width: 14.spMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5.spMin,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 3.spMin),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFD0E1D4),
                        height: 1.25,
                      ),
                    ),
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
