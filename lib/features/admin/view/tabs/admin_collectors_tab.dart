import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view/widgets/admin_collector_detail_sheet.dart';
import 'package:suchigo_collector/features/admin/view/widgets/admin_collector_filter_sheet.dart';
import 'package:suchigo_collector/features/admin/view_model/admin_view_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class AdminCollectorsTab extends StatefulWidget {
  const AdminCollectorsTab({super.key});

  @override
  State<AdminCollectorsTab> createState() => _AdminCollectorsTabState();
}

class _AdminCollectorsTabState extends State<AdminCollectorsTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminVm = context.watch<AdminViewModel>();
    final collectors = adminVm.collectorStatsList;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 12.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar & Filter Button
          Row(
            children: [
              // Search Field
              Expanded(
                child: Container(
                  height: 48.spMin,
                  padding: EdgeInsets.symmetric(horizontal: 14.spMin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.spMin),
                    border: Border.all(
                      color: const Color(0xFFC8E6C9),
                      width: 1.spMin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: const Color(0xFF1D723C),
                        size: 22.spMin,
                      ),
                      SizedBox(width: 8.spMin),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            adminVm.setSearchQuery(val);
                          },
                          style: TextStyle(
                            fontSize: 14.spMin,
                            color: SuchigoColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            filled: false,
                            fillColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hintText: "Search by name, localbody, ward, ...",
                            hintStyle: TextStyle(
                              color: const Color(0xFF9E9E9E),
                              fontSize: 13.5.spMin,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            adminVm.setSearchQuery('');
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: const Color(0xFF9E9E9E),
                            size: 18.spMin,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 10.spMin),

              // Filter Button
              GestureDetector(
                onTap: () {
                  AdminCollectorFilterSheet.show(context);
                },
                child: Container(
                  width: 48.spMin,
                  height: 48.spMin,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF6EC),
                    borderRadius: BorderRadius.circular(16.spMin),
                    border: Border.all(
                      color: const Color(0xFFCDE8CE),
                      width: 1.spMin,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: const Color(0xFF1D723C),
                        size: 22.spMin,
                      ),
                      if (adminVm.dutyStatusFilter != 'All' ||
                          adminVm.vehicleFilter != 'All' ||
                          adminVm.selectedLocalBody != 'All' ||
                          adminVm.selectedWard != 'All' ||
                          adminVm.sortBy != 'Default')
                        Positioned(
                          top: 10.spMin,
                          right: 10.spMin,
                          child: Container(
                            width: 8.spMin,
                            height: 8.spMin,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 18.spMin),

          // 2. Section Title & Active Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Collector Analytics",
                style: TextStyle(
                  fontSize: 16.5.spMin,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B4D3E),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.spMin,
                  vertical: 4.spMin,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF3E0),
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
                child: Text(
                  "${adminVm.onDutyCount} Active",
                  style: TextStyle(
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D723C),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.spMin),

          // 3. Collectors List
          if (collectors.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32.spMin),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.spMin),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 40.spMin,
                    color: const Color(0xFF9E9E9E),
                  ),
                  SizedBox(height: 8.spMin),
                  Text(
                    "No collectors found",
                    style: TextStyle(
                      fontSize: 14.spMin,
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: collectors.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.spMin),
              itemBuilder: (context, index) {
                final item = collectors[index];
                final collector = item.collector;
                final initialLetter = (collector.name.isNotEmpty
                        ? collector.name[0]
                        : (collector.username.isNotEmpty
                            ? collector.username[0]
                            : 'C'))
                    .toLowerCase();

                return GestureDetector(
                  onTap: () {
                    AdminCollectorDetailSheet.show(context, item);
                  },
                  child: Container(
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
                    children: [
                      // Header Row: Avatar, Name, Phone & On Duty Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar Circle
                          Container(
                            width: 44.spMin,
                            height: 44.spMin,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initialLetter,
                              style: TextStyle(
                                fontSize: 18.spMin,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1D723C),
                              ),
                            ),
                          ),
                          SizedBox(width: 14.spMin),

                          // Name & Phone
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  collector.name.isNotEmpty
                                      ? collector.name
                                      : collector.username,
                                  style: TextStyle(
                                    fontSize: 15.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: SuchigoColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 2.spMin),
                                Text(
                                  collector.phone.isNotEmpty
                                      ? collector.phone
                                      : "7592964933",
                                  style: TextStyle(
                                    fontSize: 12.5.spMin,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF9E9E9E),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // On Duty / Off Duty Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.spMin,
                              vertical: 4.spMin,
                            ),
                            decoration: BoxDecoration(
                              color: item.isOnDuty
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12.spMin),
                            ),
                            child: Text(
                              item.isOnDuty ? "On Duty" : "Off Duty",
                              style: TextStyle(
                                fontSize: 11.5.spMin,
                                fontWeight: FontWeight.w700,
                                color: item.isOnDuty
                                    ? const Color(0xFF1D723C)
                                    : const Color(0xFF757575),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.spMin),

                      // 3 Stats Columns: Quantity, Revenue, Pickups
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Quantity
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Quantity",
                                  style: TextStyle(
                                    fontSize: 11.5.spMin,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF9E9E9E),
                                  ),
                                ),
                                SizedBox(height: 3.spMin),
                                Text(
                                  "${item.quantityKg.toStringAsFixed(1)} Kg",
                                  style: TextStyle(
                                    fontSize: 14.5.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: SuchigoColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Revenue
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Revenue",
                                  style: TextStyle(
                                    fontSize: 11.5.spMin,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF9E9E9E),
                                  ),
                                ),
                                SizedBox(height: 3.spMin),
                                Text(
                                  "₹${item.revenue.toInt()}",
                                  style: TextStyle(
                                    fontSize: 14.5.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: SuchigoColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Pickups
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pickups",
                                  style: TextStyle(
                                    fontSize: 11.5.spMin,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF9E9E9E),
                                  ),
                                ),
                                SizedBox(height: 3.spMin),
                                Text(
                                  "${item.pickups}",
                                  style: TextStyle(
                                    fontSize: 14.5.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: SuchigoColors.textDark,
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
              );
            },
            ),

          SizedBox(height: 90.spMin), // Floating bottom nav bar padding
        ],
      ),
    );
  }
}
