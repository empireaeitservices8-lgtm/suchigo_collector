import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view/widgets/assign_vehicle_dialog.dart';
import 'package:suchigo_collector/features/auth/view/login_screen.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/features/history/view/collection_history_screen.dart';
import 'package:suchigo_collector/features/wards/view/select_ward_screen.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/features/home/view_model/home_view_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/HomeScreen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeViewModel>().fetchDistricts();
      }
    });
  }

  void _handleSaveProfile() async {
    final homeVm = context.read<HomeViewModel>();
    if (homeVm.selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a District"),
          backgroundColor: SuchigoColors.collectorGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (homeVm.selectedLocalBody == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a Local Body"),
          backgroundColor: SuchigoColors.collectorGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (homeVm.selectedWard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a Ward"),
          backgroundColor: SuchigoColors.collectorGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await homeVm.saveProfile();
    if (mounted) {
      if (success) {
        _showProfileSavedSuccessSheet();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error saving profile"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showProfileSavedSuccessSheet() {
    final homeVm = context.read<HomeViewModel>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 12,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.spMin)),
      ),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(22.spMin, 12.spMin, 22.spMin, 28.spMin),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.spMin)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator pill
              Center(
                child: Container(
                  width: 44.spMin,
                  height: 4.5.spMin,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E4D6),
                    borderRadius: BorderRadius.circular(3.spMin),
                  ),
                ),
              ),
              SizedBox(height: 20.spMin),

              // Highlighted Glowing Circular Check Badge
              Container(
                width: 70.spMin,
                height: 70.spMin,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF81C784),
                    width: 2.5.spMin,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D723C).withValues(alpha: 0.18),
                      blurRadius: 20.spMin,
                      offset: Offset(0, 6.spMin),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: const Color(0xFF1D723C),
                    size: 42.spMin,
                  ),
                ),
              ),
              SizedBox(height: 16.spMin),

              // Sheet Title
              Text(
                "Profile Saved Successfully",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.spMin,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF135C30),
                  letterSpacing: -0.3.spMin,
                ),
              ),
              SizedBox(height: 8.spMin),

              // Sheet Subtitle
              Text(
                "Your active region and service configuration have been updated.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.spMin,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF616161),
                  height: 1.35,
                ),
              ),
              SizedBox(height: 20.spMin),

              // Highlighted Region Summary Box
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.spMin,
                  vertical: 14.spMin,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F1),
                  borderRadius: BorderRadius.circular(20.spMin),
                  border: Border.all(
                    color: const Color(0xFFC8E6C9),
                    width: 1.2.spMin,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSavedSummaryRow(
                      icon: Icons.map_outlined,
                      label: "DISTRICT",
                      value: homeVm.selectedDistrict?.name ?? "Ernakulam",
                    ),
                    Divider(
                      color: const Color(0xFFE0E0E0),
                      height: 16.spMin,
                      thickness: 0.8.spMin,
                    ),
                    _buildSavedSummaryRow(
                      icon: Icons.location_city_outlined,
                      label: "LOCAL BODY",
                      value: homeVm.selectedLocalBody?.name ?? "Alangad",
                    ),
                    Divider(
                      color: const Color(0xFFE0E0E0),
                      height: 16.spMin,
                      thickness: 0.8.spMin,
                    ),
                    _buildSavedSummaryRow(
                      icon: Icons.location_on_outlined,
                      label: "WARD DETAILS",
                      value: homeVm.selectedWard?.displayName ??
                          "1 - NEERICODE WEST",
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.spMin),

              // Done Button
              SizedBox(
                width: double.infinity,
                height: 50.spMin,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D723C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.spMin),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20.spMin,
                      ),
                      SizedBox(width: 8.spMin),
                      Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 15.spMin,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17.spMin,
          color: const Color(0xFF1D723C),
        ),
        SizedBox(width: 10.spMin),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.spMin,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF757575),
            letterSpacing: 0.4.spMin,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF135C30),
            ),
          ),
        ),
      ],
    );
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
    final authVm = context.watch<AuthViewModel>();
    final homeVm = context.watch<HomeViewModel>();
    final collector = authVm.collector;
    final collectorName = collector?.name.isNotEmpty == true
        ? collector!.name
        : (collector?.username.isNotEmpty == true
            ? collector!.username
            : "shyam");

    // Vehicle name & number formatting
    String vehicleDisplay = "Tata Ace (KL 07 AB 1239)";
    if (authVm.vehicle != null && authVm.vehicle!.vehicleName.isNotEmpty) {
      vehicleDisplay =
          "${authVm.vehicle!.vehicleName} (${authVm.vehicle!.vehicleNumber})";
    } else if (collector?.vehicleName != null &&
        collector!.vehicleName!.isNotEmpty) {
      final number = collector.vehicleNumber ?? '';
      vehicleDisplay = number.isNotEmpty
          ? "${collector.vehicleName} ($number)"
          : collector.vehicleName!;
    }

    // Bag status formatting
    final bagCount = authVm.bagStatus?.bagCount ?? 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF2),
      body: Stack(
        children: [
          // Background organic curved light green circle at top right
          Positioned(
            top: -120.spMin,
            right: -80.spMin,
            child: Container(
              width: 320.spMin,
              height: 320.spMin,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE4F2DF),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.spMin),

                        // Header Section [Collector Console | Logout & On Duty]
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.spMin),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left: Title & Welcome message
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Collector Console",
                                    style: TextStyle(
                                      fontSize: 22.spMin,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF135C30),
                                      letterSpacing: -0.3.spMin,
                                    ),
                                  ),
                                  SizedBox(height: 12.spMin),
                                  Text(
                                    "Welcome Back,",
                                    style: TextStyle(
                                      fontSize: 13.spMin,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF757575),
                                    ),
                                  ),
                                  Text(
                                    collectorName,
                                    style: TextStyle(
                                      fontSize: 22.spMin,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF135C30),
                                      letterSpacing: -0.2.spMin,
                                    ),
                                  ),
                                ],
                              ),

                              // Right: Logout button & On Duty badge
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Logout Button (Circular pale peach container)
                                  GestureDetector(
                                    onTap: _handleLogout,
                                    child: Container(
                                      width: 44.spMin,
                                      height: 44.spMin,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFBEBE8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.logout_rounded,
                                        color: const Color(0xFFD84A38),
                                        size: 20.spMin,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 14.spMin),

                                  // On Duty Badge
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.spMin,
                                      vertical: 5.spMin,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F8F1),
                                      borderRadius:
                                          BorderRadius.circular(20.spMin),
                                      border: Border.all(
                                        color: const Color(0xFFC8E6C9),
                                        width: 1.spMin,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 7.spMin,
                                          height: 7.spMin,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF2E7D32),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 6.spMin),
                                        Text(
                                          "On Duty",
                                          style: TextStyle(
                                            fontSize: 11.5.spMin,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1B5E20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.spMin),

                        // Card 1: Profile & Region Configuration
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 18.spMin),
                          padding: EdgeInsets.fromLTRB(
                            20.spMin,
                            20.spMin,
                            20.spMin,
                            20.spMin,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.spMin),
                            border: Border.all(
                              color: homeVm.isProfileRecentlySaved
                                  ? const Color(0xFF81C784)
                                  : const Color(0xFFE8F5E9),
                              width: homeVm.isProfileRecentlySaved ? 1.5.spMin : 1.spMin,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: homeVm.isProfileRecentlySaved
                                    ? const Color(0xFF1D723C)
                                        .withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16.spMin,
                                offset: Offset(0, 4.spMin),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                children: [
                                  Container(
                                    width: 36.spMin,
                                    height: 36.spMin,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius:
                                          BorderRadius.circular(10.spMin),
                                    ),
                                    child: Icon(
                                      Icons.badge_outlined,
                                      color: const Color(0xFF1D723C),
                                      size: 20.spMin,
                                    ),
                                  ),
                                  SizedBox(width: 12.spMin),
                                  Text(
                                    "Profile & Region Configuration",
                                    style: TextStyle(
                                      fontSize: 15.spMin,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF135C30),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.spMin),

                              // Item 1: DISTRICT (Inline Dropdown)
                              _buildDropdownRow<DistrictModel>(
                                icon: Icons.map_outlined,
                                label: "DISTRICT",
                                value: homeVm.selectedDistrict,
                                hintText: homeVm.isLoadingDistricts
                                    ? "Loading Districts..."
                                    : "Select District",
                                items: homeVm.districts.map((d) {
                                  return DropdownMenuItem<DistrictModel>(
                                    value: d,
                                    child: Text(
                                      d.name,
                                      style: TextStyle(
                                        fontSize: 14.spMin,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF212121),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (DistrictModel? selected) {
                                  context
                                      .read<HomeViewModel>()
                                      .selectDistrict(selected);
                                },
                              ),

                              _buildDivider(),

                              // Item 2: LOCALBODY (Inline Dropdown)
                              _buildDropdownRow<LocalBodyModel>(
                                icon: Icons.location_city_outlined,
                                label: "LOCALBODY",
                                value: homeVm.selectedLocalBody,
                                hintText: homeVm.selectedDistrict == null
                                    ? "Select District first"
                                    : (homeVm.isLoadingLocalBodies
                                        ? "Loading Local Bodies..."
                                        : "Select Local Body"),
                                items: homeVm.localBodies.map((lb) {
                                  return DropdownMenuItem<LocalBodyModel>(
                                    value: lb,
                                    child: Text(
                                      lb.name,
                                      style: TextStyle(
                                        fontSize: 14.spMin,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF212121),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: homeVm.selectedDistrict == null
                                    ? null
                                    : (LocalBodyModel? selected) {
                                        context
                                            .read<HomeViewModel>()
                                            .selectLocalBody(selected);
                                      },
                              ),

                              _buildDivider(),

                              // Item 3: WARD DETAILS (Inline Dropdown with Ward Name)
                              _buildDropdownRow<WardModel>(
                                icon: Icons.location_on_outlined,
                                label: "WARD DETAILS",
                                value: homeVm.selectedWard,
                                onClear: homeVm.selectedWard != null
                                    ? () async {
                                        await context
                                            .read<HomeViewModel>()
                                            .selectWard(null);
                                        Fluttertoast.showToast(
                                          msg: "Showing all wards",
                                          toastLength: Toast.LENGTH_SHORT,
                                          backgroundColor:
                                              const Color(0xFF1D723C),
                                          textColor: Colors.white,
                                        );
                                      }
                                    : null,
                                hintText: homeVm.selectedLocalBody == null
                                    ? "Select Local Body first"
                                    : (homeVm.isLoadingWards
                                        ? "Loading Wards..."
                                        : "All Wards (Tap to select specific ward)"),
                                items: homeVm.wards.map((w) {
                                  return DropdownMenuItem<WardModel>(
                                    value: w,
                                    child: Text(
                                      w.displayName,
                                      style: TextStyle(
                                        fontSize: 14.spMin,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF212121),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: homeVm.selectedLocalBody == null
                                    ? null
                                    : (WardModel? selected) async {
                                        await context
                                            .read<HomeViewModel>()
                                            .selectWard(selected);
                                        if (selected != null) {
                                          Fluttertoast.showToast(
                                            msg:
                                                "Ward selected: ${selected.displayName}",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor:
                                                const Color(0xFF1D723C),
                                            textColor: Colors.white,
                                            fontSize: 14.0,
                                          );
                                        }
                                      },
                              ),

                              _buildDivider(),

                              // Item 4: ASSIGNED VEHICLE
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  final col = collector ??
                                      authVm.collector ??
                                      CollectorModel(
                                        id: authVm.authResponse?.collector?.id ?? 0,
                                        username: collectorName,
                                        name: collectorName,
                                        email: authVm.collector?.email ?? "",
                                        phone: authVm.collector?.phone ?? "",
                                        vehicleName:
                                            authVm.vehicle?.vehicleName,
                                        vehicleNumber:
                                            authVm.vehicle?.vehicleNumber,
                                      );
                                  AssignVehicleDialog.show(
                                    context,
                                    collector: col,
                                    onVehicleAssigned: () {
                                      authVm.fetchCollectorVehicle();
                                    },
                                  );
                                },
                                child: _buildStaticRow(
                                  icon: Icons.local_shipping_outlined,
                                  label: "ASSIGNED VEHICLE",
                                  value: vehicleDisplay,
                                  isHighlightedValue: false,
                                ),
                              ),

                              _buildDivider(),

                              // Item 5: BAGS AVAILABLE
                              _buildStaticRow(
                                icon: Icons.shopping_bag_outlined,
                                label: "BAGS AVAILABLE",
                                value: "$bagCount Bags",
                                isHighlightedValue: true,
                              ),

                              SizedBox(height: 20.spMin),

                              // Save Profile Changes Button
                              SizedBox(
                                width: double.infinity,
                                height: 50.spMin,
                                child: ElevatedButton(
                                  onPressed: homeVm.isSavingProfile
                                      ? null
                                      : _handleSaveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1D723C),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xFF1D723C)
                                            .withValues(alpha: 0.7),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16.spMin),
                                    ),
                                  ),
                                  child: homeVm.isSavingProfile
                                      ? SizedBox(
                                          width: 22.spMin,
                                          height: 22.spMin,
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline_rounded,
                                              color: Colors.white,
                                              size: 20.spMin,
                                            ),
                                            SizedBox(width: 8.spMin),
                                            Text(
                                              "Save Profile Changes",
                                              style: TextStyle(
                                                fontSize: 14.5.spMin,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 22.spMin),

                        // Section Title: Operations Hub
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.spMin),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Operations Hub",
                                style: TextStyle(
                                  fontSize: 18.spMin,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF135C30),
                                  letterSpacing: -0.2.spMin,
                                ),
                              ),
                              SizedBox(height: 3.spMin),
                              Text(
                                "Launch routes and view collection progress",
                                style: TextStyle(
                                  fontSize: 12.spMin,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12.spMin),

                        // Card 2: Sanitary Orders (Active)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 18.spMin),
                          padding: EdgeInsets.all(20.spMin),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.spMin),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16.spMin,
                                offset: Offset(0, 4.spMin),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    width: 44.spMin,
                                    height: 44.spMin,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.recycling_rounded,
                                      color: const Color(0xFF1D723C),
                                      size: 24.spMin,
                                    ),
                                  ),
                                  SizedBox(width: 14.spMin),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Sanitary Orders",
                                          style: TextStyle(
                                            fontSize: 16.spMin,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF135C30),
                                          ),
                                        ),
                                        SizedBox(height: 3.spMin),
                                        Text(
                                          "Manage household organic and domestic waste routes",
                                          style: TextStyle(
                                            fontSize: 11.5.spMin,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF757575),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.spMin),

                              // Button 1: View Active Wards & Orders (Filled Green)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SelectWardScreen(
                                        localBodyId: homeVm.selectedLocalBody?.id,
                                        localBodyName: homeVm.selectedLocalBody?.name,
                                        selectedWard: homeVm.selectedWard,
                                        selectedWardName: homeVm.selectedWard?.name,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 48.spMin,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.spMin),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1D723C),
                                    borderRadius:
                                        BorderRadius.circular(16.spMin),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.explore_outlined,
                                        color: Colors.white,
                                        size: 20.spMin,
                                      ),
                                      SizedBox(width: 10.spMin),
                                      Expanded(
                                        child: Text(
                                          "View Active Wards & Orders",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.spMin,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.white,
                                        size: 22.spMin,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 10.spMin),

                              // Button 2: View Collection History (Outlined Green)
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    CollectionHistoryScreen.routeName,
                                  );
                                },
                                child: Container(
                                  height: 48.spMin,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.spMin),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFF1D723C),
                                      width: 1.5.spMin,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(16.spMin),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.history_rounded,
                                        color: const Color(0xFF1D723C),
                                        size: 20.spMin,
                                      ),
                                      SizedBox(width: 10.spMin),
                                      Expanded(
                                        child: Text(
                                          "View Collection History",
                                          style: TextStyle(
                                            color: const Color(0xFF1D723C),
                                            fontSize: 14.spMin,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: const Color(0xFF1D723C),
                                        size: 22.spMin,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // Card 3: Scrap Orders (Disabled)
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            18.spMin,
                            0,
                            18.spMin,
                            24.spMin,
                          ),
                          padding: EdgeInsets.all(20.spMin),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.spMin),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16.spMin,
                                offset: Offset(0, 4.spMin),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    width: 44.spMin,
                                    height: 44.spMin,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF5F5F5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.settings_outlined,
                                      color: const Color(0xFF9E9E9E),
                                      size: 24.spMin,
                                    ),
                                  ),
                                  SizedBox(width: 14.spMin),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Scrap Orders",
                                              style: TextStyle(
                                                fontSize: 16.spMin,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF757575),
                                              ),
                                            ),
                                            SizedBox(width: 8.spMin),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.spMin,
                                                vertical: 2.spMin,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEEEEEE),
                                                borderRadius:
                                                    BorderRadius.circular(10.spMin),
                                              ),
                                              child: Text(
                                                "Disabled",
                                                style: TextStyle(
                                                  fontSize: 10.spMin,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF757575),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 3.spMin),
                                        Text(
                                          "Manage recyclable items, plastics, and metallic scrap",
                                          style: TextStyle(
                                            fontSize: 11.5.spMin,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF9E9E9E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.spMin),

                              // Button 1 (Disabled Filled Grey)
                              Container(
                                height: 48.spMin,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.spMin),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.circular(16.spMin),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.explore_outlined,
                                      color: const Color(0xFF757575),
                                      size: 20.spMin,
                                    ),
                                    SizedBox(width: 10.spMin),
                                    Expanded(
                                      child: Text(
                                        "View Active Wards & Orders",
                                        style: TextStyle(
                                          color: const Color(0xFF757575),
                                          fontSize: 14.spMin,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: const Color(0xFF757575),
                                      size: 22.spMin,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 10.spMin),

                              // Button 2 (Disabled Outlined Grey)
                              Container(
                                height: 48.spMin,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.spMin),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 1.5.spMin,
                                  ),
                                  borderRadius: BorderRadius.circular(16.spMin),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.history_rounded,
                                      color: const Color(0xFF9E9E9E),
                                      size: 20.spMin,
                                    ),
                                    SizedBox(width: 10.spMin),
                                    Expanded(
                                      child: Text(
                                        "View Collection History",
                                        style: TextStyle(
                                          color: const Color(0xFF9E9E9E),
                                          fontSize: 14.spMin,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                            ],
                          ),
                        ),

                        SizedBox(height: 20.spMin),
                      ],
                    ),
                  ),
                ),

                // Bottom Floating Pill Navigation
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.spMin),
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 26.spMin,
                      vertical: 8.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(24.spMin),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home_rounded,
                          color: const Color(0xFF1D723C),
                          size: 20.spMin,
                        ),
                        SizedBox(width: 8.spMin),
                        Text(
                          "Home",
                          style: TextStyle(
                            color: const Color(0xFF1D723C),
                            fontSize: 13.5.spMin,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow<T>({
    required IconData icon,
    required String label,
    required T? value,
    required String hintText,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    VoidCallback? onClear,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.spMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF9E9E9E),
            size: 20.spMin,
          ),
          SizedBox(width: 14.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.spMin,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9E9E9E),
                    letterSpacing: 0.6.spMin,
                  ),
                ),
                SizedBox(height: 6.spMin),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<T>(
                          value: value,
                          isExpanded: true,
                          isDense: true,
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16.spMin),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: const Color(0xFF9E9E9E),
                            size: 22.spMin,
                          ),
                          hint: Text(
                            hintText,
                            style: TextStyle(
                              fontSize: 14.spMin,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFBDBDBD),
                            ),
                          ),
                          items: items,
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                    if (onClear != null && value != null)
                      GestureDetector(
                        onTap: onClear,
                        child: Padding(
                          padding: EdgeInsets.only(left: 6.spMin),
                          child: Icon(
                            Icons.cancel_outlined,
                            size: 18.spMin,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticRow({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlightedValue = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.spMin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF9E9E9E),
            size: 20.spMin,
          ),
          SizedBox(width: 14.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.spMin,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9E9E9E),
                    letterSpacing: 0.6.spMin,
                  ),
                ),
                SizedBox(height: 6.spMin),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                    color: isHighlightedValue
                        ? const Color(0xFF1D723C)
                        : const Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: const Color(0xFFF0F0F0),
      height: 20.spMin,
      thickness: 1.spMin,
    );
  }
}
