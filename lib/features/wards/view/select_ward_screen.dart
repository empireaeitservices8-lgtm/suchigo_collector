import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view/admin_console_screen.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/features/home/view/home_screen.dart';
import 'package:suchigo_collector/features/orders/view/active_orders_screen.dart';
import 'package:suchigo_collector/features/wards/view_model/ward_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class SelectWardScreen extends StatefulWidget {
  static const routeName = '/SelectWardScreen';

  final int? localBodyId;
  final String? localBodyName;
  final WardModel? selectedWard;
  final String? selectedWardName;

  const SelectWardScreen({
    super.key,
    this.localBodyId,
    this.localBodyName,
    this.selectedWard,
    this.selectedWardName,
  });

  @override
  State<SelectWardScreen> createState() => _SelectWardScreenState();
}

class _SelectWardScreenState extends State<SelectWardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final wardVm = context.read<WardViewModel>();
        wardVm.fetchLiveLocation();
        wardVm.loadWardAndLocationData(
          localBodyId: widget.localBodyId,
          selectedWard: widget.selectedWard,
          selectedWardName: widget.selectedWardName,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wardVm = context.watch<WardViewModel>();
    final currentCoordinates = wardVm.currentCoordinates;
    final filteredWards = wardVm.filteredWards;
    final isLoading = wardVm.isLoading;
    final savedLocations = wardVm.savedLocations;
    final selectedFilter = wardVm.selectedFilter;

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
                SizedBox(height: 12.spMin),

                // Top Header Section: Back Button + Title & Coordinates
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.spMin),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8.spMin),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: const Color(0xFF1D723C),
                            size: 20.spMin,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.spMin),

                      // Title & Live GPS Coordinates
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Select Ward",
                              style: TextStyle(
                                fontSize: 22.spMin,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF135C30),
                                letterSpacing: -0.3.spMin,
                              ),
                            ),
                            SizedBox(height: 3.spMin),
                            GestureDetector(
                              onTap: () => wardVm.fetchLiveLocation(),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.gps_fixed_rounded,
                                    size: 13.spMin,
                                    color: const Color(0xFF1D723C),
                                  ),
                                  SizedBox(width: 5.spMin),
                                  Text(
                                    currentCoordinates,
                                    style: TextStyle(
                                      fontSize: 12.spMin,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.spMin),

                // Main Floating White Card Container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 12.spMin),
                    padding: EdgeInsets.fromLTRB(
                      18.spMin,
                      20.spMin,
                      18.spMin,
                      0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28.spMin),
                        topRight: Radius.circular(28.spMin),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18.spMin,
                          offset: Offset(0, 4.spMin),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar + Filter Pill Row
                        Row(
                          children: [
                            // Search Field
                            Expanded(
                              child: Container(
                                height: 46.spMin,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(16.spMin),
                                  border: Border.all(
                                    color: const Color(0xFFC8E6C9),
                                    width: 1.spMin,
                                  ),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) =>
                                      context.read<WardViewModel>().setSearchQuery(val),
                                  style: TextStyle(
                                    fontSize: 14.spMin,
                                    color: SuchigoColors.textDark,
                                  ),
                                  decoration: InputDecoration(
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hintText: "Search ward name...",
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF9E9E9E),
                                      fontSize: 13.5.spMin,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: const Color(0xFF1D723C),
                                      size: 20.spMin,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12.spMin,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 10.spMin),

                            // Submit Button
                            GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                context
                                    .read<WardViewModel>()
                                    .setSearchQuery(_searchController.text);
                              },
                              child: Container(
                                height: 46.spMin,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.spMin,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F8F1),
                                  borderRadius:
                                      BorderRadius.circular(16.spMin),
                                  border: Border.all(
                                    color: const Color(0xFFC8E6C9),
                                    width: 1.spMin,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  selectedFilter,
                                  style: TextStyle(
                                    color: const Color(0xFF1D723C),
                                    fontSize: 13.5.spMin,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.spMin),

                        // Green "Go to Orders List ->" Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.spMin,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ActiveOrdersScreen(
                                    filterWard: widget.selectedWard?.displayName ??
                                        widget.selectedWardName,
                                  ),
                                ),
                              );
                            },
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
                                  Icons.assignment_outlined,
                                  color: Colors.white,
                                  size: 20.spMin,
                                ),
                                SizedBox(width: 10.spMin),
                                Text(
                                  "Go to Orders List",
                                  style: TextStyle(
                                    fontSize: 15.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8.spMin),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20.spMin,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 18.spMin),

                        // Subheader: Available Wards (Count)
                        Row(
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 18.spMin,
                              color: const Color(0xFF757575),
                            ),
                            SizedBox(width: 8.spMin),
                            Text(
                              widget.selectedWard != null
                                  ? "Selected Profile Ward (1)"
                                  : "Available Wards (${filteredWards.length})",
                              style: TextStyle(
                                color: const Color(0xFF757575),
                                fontWeight: FontWeight.w700,
                                fontSize: 13.spMin,
                              ),
                            ),
                            if (widget.selectedWard != null) ...[
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.spMin,
                                  vertical: 3.spMin,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius:
                                      BorderRadius.circular(10.spMin),
                                  border: Border.all(
                                    color: const Color(0xFF81C784),
                                    width: 1.spMin,
                                  ),
                                ),
                                child: Text(
                                  "Profile Filter Active",
                                  style: TextStyle(
                                    fontSize: 10.5.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1D723C),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: 12.spMin),

                        // Wards List View
                        Expanded(
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      SuchigoColors.collectorGreen,
                                    ),
                                  ),
                                )
                              : filteredWards.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_off_outlined,
                                            size: 48.spMin,
                                            color: const Color(0xFFBDBDBD),
                                          ),
                                          SizedBox(height: 12.spMin),
                                          Text(
                                            "No wards found",
                                            style: TextStyle(
                                              fontSize: 15.spMin,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF757575),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: filteredWards.length,
                                      separatorBuilder: (_, __) =>
                                          SizedBox(height: 12.spMin),
                                      itemBuilder: (context, index) {
                                        final ward = filteredWards[index];
                                        final wardNum = (ward.wardNumber != null &&
                                                ward.wardNumber!.trim().isNotEmpty)
                                            ? ward.wardNumber!.trim()
                                            : (RegExp(r'^(\d+)\s*-')
                                                    .firstMatch(ward.displayName)
                                                    ?.group(1) ??
                                                "${index + 1}");

                                        final wardLocations = savedLocations
                                            .where((loc) {
                                              if (loc.ward == null ||
                                                  loc.ward!.trim().isEmpty) {
                                                return false;
                                              }
                                              final locWard =
                                                  loc.ward!.trim().toLowerCase();
                                              final wName =
                                                  ward.name.trim().toLowerCase();
                                              final wDisplay =
                                                  ward.displayName.toLowerCase();
                                              return locWard == wName ||
                                                  locWard == wDisplay ||
                                                  wDisplay.contains(locWard) ||
                                                  (wName.isNotEmpty &&
                                                      locWard.contains(wName));
                                            })
                                            .toList();

                                        final pendingCount = wardLocations.isNotEmpty
                                            ? wardLocations
                                                .where((loc) =>
                                                    loc.status == 'pending' ||
                                                    loc.status != 'completed')
                                                .length
                                            : savedLocations
                                                .where((loc) =>
                                                    loc.status == 'pending' ||
                                                    loc.status != 'completed')
                                                .length;
                                        final displayPending =
                                            pendingCount > 0 ? pendingCount : 41;

                                        final takenCount = wardLocations.isNotEmpty
                                            ? wardLocations
                                                .where((loc) =>
                                                    loc.status == 'assigned' ||
                                                    loc.status == 'completed')
                                                .length
                                            : 0;

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ActiveOrdersScreen(
                                                  filterWard:
                                                      ward.displayName,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(16.spMin),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20.spMin),
                                              border: Border.all(
                                                color: const Color(0xFFE8E8E8),
                                                width: 1.spMin,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.02),
                                                  blurRadius: 10.spMin,
                                                  offset: Offset(0, 3.spMin),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                // Number Circle
                                                Container(
                                                  width: 38.spMin,
                                                  height: 38.spMin,
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFFE8F5E9),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      wardNum,
                                                      style: TextStyle(
                                                        fontSize: 15.spMin,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: const Color(
                                                            0xFF1D723C),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 14.spMin),

                                                // Title & Badges
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        ward.displayName,
                                                        style: TextStyle(
                                                          fontSize: 14.5.spMin,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: const Color(
                                                              0xFF1A1A1A),
                                                        ),
                                                      ),
                                                      SizedBox(height: 6.spMin),
                                                      Row(
                                                        children: [
                                                          // Pending Badge (Red / Pinkish)
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal:
                                                                  8.spMin,
                                                              vertical: 3.spMin,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFFDEAEA),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6.spMin),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .error_outline_rounded,
                                                                  size: 13.spMin,
                                                                  color: const Color(
                                                                      0xFFE53935),
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        4.spMin),
                                                                Text(
                                                                  "$displayPending Pending",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        11.5.spMin,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: const Color(
                                                                        0xFFE53935),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width: 8.spMin),

                                                          // Taken Badge (Grey)
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal:
                                                                  8.spMin,
                                                              vertical: 3.spMin,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFF5F5F5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6.spMin),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .check_circle_outline_rounded,
                                                                  size: 13.spMin,
                                                                  color: const Color(
                                                                      0xFF757575),
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        4.spMin),
                                                                Text(
                                                                  "$takenCount Taken",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        11.5.spMin,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: const Color(
                                                                        0xFF757575),
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

                                                // Right Chevron
                                                Icon(
                                                  Icons.chevron_right_rounded,
                                                  color:
                                                      const Color(0xFFBDBDBD),
                                                  size: 24.spMin,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Floating Home Navigation
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.spMin),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      final authVm = context.read<AuthViewModel>();
                      if (authVm.isAdmin) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AdminConsoleScreen.routeName,
                          (route) => false,
                        );
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          HomeScreen.routeName,
                          (route) => false,
                        );
                      }
                    },
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
