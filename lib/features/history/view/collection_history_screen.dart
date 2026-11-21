import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/features/history/view_model/history_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class CollectionHistoryScreen extends StatefulWidget {
  static const routeName = '/CollectionHistoryScreen';

  const CollectionHistoryScreen({super.key});

  @override
  State<CollectionHistoryScreen> createState() =>
      _CollectionHistoryScreenState();
}

class _CollectionHistoryScreenState extends State<CollectionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _wasteCategories = [
    "All",
    "Sanitary Pad",
    "Medical Waste",
    "Diapers",
    "Hair",
    "Scrap/Other",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authVm = context.read<AuthViewModel>();
        final collectorId = authVm.collector?.id ?? 24;
        context
            .read<HistoryViewModel>()
            .fetchCollectionRecords(collectorId: collectorId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isFrom) async {
    final historyVm = context.read<HistoryViewModel>();
    final initialDate = isFrom ? historyVm.fromDate : historyVm.toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SuchigoColors.collectorGreen,
              onPrimary: Colors.white,
              onSurface: SuchigoColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isFrom) {
        historyVm.setFromDate(picked);
      } else {
        historyVm.setToDate(picked);
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  String _formatDisplayDate(String rawDate) {
    final trimmed = rawDate.trim();
    try {
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        return DateFormat('dd MMM yyyy').format(parsed);
      }
    } catch (_) {}
    return trimmed;
  }

  void _showFilterSortBottomSheet() {
    final historyVm = context.read<HistoryViewModel>();
    String tempPayment = historyVm.selectedPaymentMethod;
    String tempWasteCategory = historyVm.selectedWasteCategory;
    String tempSortBy = historyVm.selectedSortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24.spMin),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                20.spMin,
                12.spMin,
                20.spMin,
                MediaQuery.of(context).padding.bottom + 20.spMin,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle Pill
                  Center(
                    child: Container(
                      width: 46.spMin,
                      height: 4.5.spMin,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(3.spMin),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.spMin),

                  // Header Row: Filter & Sort History + Reset All
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filter & Sort History",
                        style: TextStyle(
                          fontSize: 18.spMin,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF135C30),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            tempPayment = "All";
                            tempWasteCategory = "All";
                            tempSortBy = "Default";
                          });
                        },
                        child: Text(
                          "Reset All",
                          style: TextStyle(
                            fontSize: 14.spMin,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFE53935),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.spMin),
                  Divider(
                    color: const Color(0xFFEEEEEE),
                    thickness: 1.spMin,
                    height: 1.spMin,
                  ),
                  SizedBox(height: 16.spMin),

                  // Section 1: Payment Method
                  Text(
                    "Payment Method",
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  SizedBox(height: 10.spMin),
                  Row(
                    children: [
                      _buildChip(
                        label: "All",
                        isSelected: tempPayment == "All",
                        onTap: () => setModalState(() => tempPayment = "All"),
                      ),
                      SizedBox(width: 10.spMin),
                      _buildChip(
                        label: "Cash",
                        isSelected: tempPayment == "Cash",
                        onTap: () => setModalState(() => tempPayment = "Cash"),
                      ),
                      SizedBox(width: 10.spMin),
                      _buildChip(
                        label: "Online",
                        isSelected: tempPayment == "Online",
                        onTap: () =>
                            setModalState(() => tempPayment = "Online"),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.spMin),

                  // Section 2: Waste Category
                  Text(
                    "Waste Category",
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  SizedBox(height: 10.spMin),
                  Container(
                    width: double.infinity,
                    height: 48.spMin,
                    padding: EdgeInsets.symmetric(horizontal: 14.spMin),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FAF5),
                      borderRadius: BorderRadius.circular(12.spMin),
                      border: Border.all(
                        color: const Color(0xFFC8E6C9),
                        width: 1.spMin,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tempWasteCategory,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: const Color(0xFF1D723C),
                          size: 24.spMin,
                        ),
                        dropdownColor: Colors.white,
                        style: TextStyle(
                          fontSize: 14.spMin,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212121),
                        ),
                        items: _wasteCategories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => tempWasteCategory = val);
                          }
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20.spMin),

                  // Section 3: Sort By
                  Text(
                    "Sort By",
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  SizedBox(height: 10.spMin),
                  Row(
                    children: [
                      _buildChip(
                        label: "Default",
                        isSelected: tempSortBy == "Default",
                        onTap: () =>
                            setModalState(() => tempSortBy = "Default"),
                      ),
                      SizedBox(width: 8.spMin),
                      _buildChip(
                        label: "Newest First",
                        isSelected: tempSortBy == "Newest First",
                        onTap: () =>
                            setModalState(() => tempSortBy = "Newest First"),
                      ),
                      SizedBox(width: 8.spMin),
                      _buildChip(
                        label: "Oldest First",
                        isSelected: tempSortBy == "Oldest First",
                        onTap: () =>
                            setModalState(() => tempSortBy = "Oldest First"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.spMin),
                  Row(
                    children: [
                      _buildChip(
                        label: "Amount (High to Low)",
                        isSelected: tempSortBy == "Amount (High to Low)",
                        onTap: () => setModalState(
                            () => tempSortBy = "Amount (High to Low)"),
                      ),
                      SizedBox(width: 8.spMin),
                      _buildChip(
                        label: "Quantity (High to Low)",
                        isSelected: tempSortBy == "Quantity (High to Low)",
                        onTap: () => setModalState(
                            () => tempSortBy = "Quantity (High to Low)"),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.spMin),

                  // Apply Filters Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.spMin,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<HistoryViewModel>().setFilters(
                              paymentMethod: tempPayment,
                              wasteCategory: tempWasteCategory,
                              sortBy: tempSortBy,
                            );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D723C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.spMin),
                        ),
                      ),
                      child: Text(
                        "Apply Filters",
                        style: TextStyle(
                          fontSize: 15.spMin,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3.spMin,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 8.spMin),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF8FCF8),
          borderRadius: BorderRadius.circular(10.spMin),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF1D723C) : const Color(0xFFDCEAD9),
            width: isSelected ? 1.4.spMin : 1.spMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_rounded,
                size: 15.spMin,
                color: const Color(0xFF1D723C),
              ),
              SizedBox(width: 4.spMin),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5.spMin,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF1D723C)
                    : const Color(0xFF424242),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final historyVm = context.watch<HistoryViewModel>();
    final collector = authVm.collector;
    final providerName = collector?.name.isNotEmpty == true
        ? collector!.name
        : (collector?.username.isNotEmpty == true ? collector!.username : "");
    final providerMobile =
        collector?.phone.isNotEmpty == true ? collector!.phone : "";

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
                SizedBox(height: 6.spMin),

                // Top Header: Back Button + Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.spMin),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(4.spMin),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: const Color(0xFF1D723C),
                            size: 24.spMin,
                          ),
                        ),
                      ),
                      SizedBox(width: 14.spMin),
                      Text(
                        "Bio-Waste Collections",
                        style: TextStyle(
                          fontSize: 20.spMin,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF135C30),
                          letterSpacing: -0.3.spMin,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.spMin),

                // // Filter Collections Card
                // Container(
                //   margin: EdgeInsets.symmetric(horizontal: 16.spMin),
                //   padding: EdgeInsets.all(16.spMin),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(22.spMin),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withValues(alpha: 0.04),
                //         blurRadius: 14.spMin,
                //         offset: Offset(0, 4.spMin),
                //       ),
                //     ],
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       // Header Row
                //       Row(
                //         children: [
                //           Icon(
                //             Icons.calendar_month_outlined,
                //             color: const Color(0xFF1D723C),
                //             size: 20.spMin,
                //           ),
                //           SizedBox(width: 8.spMin),
                //           Text(
                //             "Filter Collections",
                //             style: TextStyle(
                //               fontSize: 15.spMin,
                //               fontWeight: FontWeight.w800,
                //               color: const Color(0xFF135C30),
                //             ),
                //           ),
                //         ],
                //       ),

                //       SizedBox(height: 12.spMin),

                //       // FROM & TO Date Pickers
                //       Row(
                //         children: [
                //           // FROM Date
                //           Expanded(
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text(
                //                   "FROM",
                //                   style: TextStyle(
                //                     fontSize: 10.spMin,
                //                     fontWeight: FontWeight.w700,
                //                     color: const Color(0xFF757575),
                //                     letterSpacing: 0.5.spMin,
                //                   ),
                //                 ),
                //                 SizedBox(height: 4.spMin),
                //                 GestureDetector(
                //                   onTap: () => _pickDate(true),
                //                   child: Container(
                //                     height: 42.spMin,
                //                     padding: EdgeInsets.symmetric(
                //                         horizontal: 10.spMin),
                //                     decoration: BoxDecoration(
                //                       color: const Color(0xFFF9F9F9),
                //                       borderRadius:
                //                           BorderRadius.circular(12.spMin),
                //                       border: Border.all(
                //                         color: const Color(0xFFE0E0E0),
                //                         width: 1.spMin,
                //                       ),
                //                     ),
                //                     child: Row(
                //                       children: [
                //                         Icon(
                //                           Icons.calendar_today_outlined,
                //                           size: 15.spMin,
                //                           color: const Color(0xFF1D723C),
                //                         ),
                //                         SizedBox(width: 8.spMin),
                //                         Text(
                //                           _formatDate(historyVm.fromDate),
                //                           style: TextStyle(
                //                             fontSize: 13.spMin,
                //                             fontWeight: FontWeight.w700,
                //                             color: const Color(0xFF212121),
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),

                //           Padding(
                //             padding: EdgeInsets.only(
                //               top: 14.spMin,
                //               left: 8.spMin,
                //               right: 8.spMin,
                //             ),
                //             child: Icon(
                //               Icons.arrow_forward_rounded,
                //               size: 16.spMin,
                //               color: const Color(0xFF9E9E9E),
                //             ),
                //           ),

                //           // TO Date
                //           Expanded(
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text(
                //                   "TO",
                //                   style: TextStyle(
                //                     fontSize: 10.spMin,
                //                     fontWeight: FontWeight.w700,
                //                     color: const Color(0xFF757575),
                //                     letterSpacing: 0.5.spMin,
                //                   ),
                //                 ),
                //                 SizedBox(height: 4.spMin),
                //                 GestureDetector(
                //                   onTap: () => _pickDate(false),
                //                   child: Container(
                //                     height: 42.spMin,
                //                     padding: EdgeInsets.symmetric(
                //                         horizontal: 10.spMin),
                //                     decoration: BoxDecoration(
                //                       color: const Color(0xFFF9F9F9),
                //                       borderRadius:
                //                           BorderRadius.circular(12.spMin),
                //                       border: Border.all(
                //                         color: const Color(0xFFE0E0E0),
                //                         width: 1.spMin,
                //                       ),
                //                     ),
                //                     child: Row(
                //                       children: [
                //                         Icon(
                //                           Icons.calendar_today_outlined,
                //                           size: 15.spMin,
                //                           color: const Color(0xFF1D723C),
                //                         ),
                //                         SizedBox(width: 8.spMin),
                //                         Text(
                //                           _formatDate(historyVm.toDate),
                //                           style: TextStyle(
                //                             fontSize: 13.spMin,
                //                             fontWeight: FontWeight.w700,
                //                             color: const Color(0xFF212121),
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),

                //       SizedBox(height: 14.spMin),

                //       // APPLY FILTER Button
                //       SizedBox(
                //         width: double.infinity,
                //         height: 44.spMin,
                //         child: ElevatedButton(
                //           onPressed: () {
                //             final authVm = context.read<AuthViewModel>();
                //             final collectorId = authVm.collector?.id ?? 24;
                //             context
                //                 .read<HistoryViewModel>()
                //                 .fetchCollectionRecords(
                //                     collectorId: collectorId);
                //           },
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: const Color(0xFF1D723C),
                //             foregroundColor: Colors.white,
                //             elevation: 0,
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(12.spMin),
                //             ),
                //           ),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               Icon(
                //                 Icons.filter_alt_rounded,
                //                 color: Colors.white,
                //                 size: 18.spMin,
                //               ),
                //               SizedBox(width: 6.spMin),
                //               Text(
                //                 "APPLY FILTER",
                //                 style: TextStyle(
                //                   fontSize: 13.spMin,
                //                   fontWeight: FontWeight.w800,
                //                   color: Colors.white,
                //                   letterSpacing: 0.6.spMin,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                SizedBox(height: 14.spMin),

                // Horizontal Tab Bar: Overview | Daily Summary | Completed Records
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.spMin),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE0E0E0),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTabItem(0, "Overview", historyVm.selectedTabIndex),
                      _buildTabItem(
                          1, "Daily Summary", historyVm.selectedTabIndex),
                      _buildTabItem(
                          2, "Completed Records", historyVm.selectedTabIndex),
                    ],
                  ),
                ),

                SizedBox(height: 14.spMin),

                // Tab Content Area
                Expanded(
                  child: historyVm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              SuchigoColors.collectorGreen,
                            ),
                          ),
                        )
                      : _buildSelectedTabContent(
                          providerName, providerMobile, historyVm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent(
      String providerName, String providerMobile, HistoryViewModel historyVm) {
    switch (historyVm.selectedTabIndex) {
      case 0:
        return _buildOverviewTab(providerName, providerMobile, historyVm);
      case 1:
        return _buildDailySummaryTab(historyVm);
      case 2:
      default:
        return _buildCompletedRecordsTab(historyVm);
    }
  }

  // TAB 1: OVERVIEW
  Widget _buildOverviewTab(
      String providerName, String providerMobile, HistoryViewModel historyVm) {
    final overview = historyVm.overview;
    final collector = historyVm.collector;
    final effectiveName = collector?.name.isNotEmpty == true
        ? collector!.name
        : (providerName.isNotEmpty
            ? providerName
            : (collector?.username ?? ""));
    final effectivePhone = collector?.phone.isNotEmpty == true
        ? collector!.phone
        : (providerMobile.isNotEmpty ? providerMobile : "");
    final vehicleDisplay = collector?.vehicleName?.isNotEmpty == true
        ? "${collector!.vehicleName}${collector.vehicleNumber?.isNotEmpty == true ? ' (${collector.vehicleNumber})' : ''}"
        : null;

    final totalKg = overview.totalQuantityKg;
    final totalAmount = overview.totalAmountCollected;
    final totalOrders = overview.totalOrders > 0
        ? overview.totalOrders
        : historyVm.allRecords.length;

    final capacity =
        overview.vehicleCapacityKg > 0 ? overview.vehicleCapacityKg : 500.0;
    final usedCapacity = overview.vehicleCapacityUsedKg > 0
        ? overview.vehicleCapacityUsedKg
        : totalKg;
    final double capacityProgress =
        capacity > 0 ? (usedCapacity / capacity).clamp(0.0, 1.0) : 0.0;

    // Dynamic category breakdown computation
    final records = historyVm.allRecords;
    double getQty(String cat) {
      if (overview.categoryQuantities.containsKey(cat)) {
        return overview.categoryQuantities[cat]!;
      }
      return records.where((r) {
        final wt = r.wasteType?.toLowerCase() ?? '';
        final idesc = r.itemsDescription?.toLowerCase() ?? '';
        final c = cat.toLowerCase();
        return wt.contains(c) || idesc.contains(c);
      }).fold(0.0, (sum, r) => sum + r.quantityKg);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 4.spMin),
      child: Column(
        children: [
          // Card 1: Provider Summary Details
          Container(
            padding:
                EdgeInsets.fromLTRB(20.spMin, 18.spMin, 20.spMin, 18.spMin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.spMin),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14.spMin,
                  offset: Offset(0, 4.spMin),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildOverviewRow("Provider Name", effectiveName),
                _buildDivider(),
                _buildOverviewRow("Provider Mobile", effectivePhone),
                if (collector?.email != null &&
                    collector!.email.isNotEmpty) ...[
                  _buildDivider(),
                  _buildOverviewRow("Email", collector.email),
                ],
                if (collector?.vehicleName != null &&
                    collector!.vehicleName!.isNotEmpty) ...[
                  _buildDivider(),
                  _buildOverviewRow("Vehicle Name", collector.vehicleName!),
                ],
                if (collector?.vehicleNumber != null &&
                    collector!.vehicleNumber!.isNotEmpty) ...[
                  _buildDivider(),
                  _buildOverviewRow("Vehicle Number", collector.vehicleNumber!),
                ],
                _buildDivider(),
                _buildOverviewRow(
                    "Total Quantity", "${totalKg.toStringAsFixed(2)} Kg"),
                _buildDivider(),
                _buildOverviewRow(
                    "Total Amount", "₹${totalAmount.toStringAsFixed(2)}"),
                _buildDivider(),
                _buildOverviewRow("Total Orders", "$totalOrders"),
              ],
            ),
          ),

          SizedBox(height: 16.spMin),

          // Card 2: Vehicle Capacity Limit
          // Container(
          //   padding: EdgeInsets.all(18.spMin),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(24.spMin),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withValues(alpha: 0.04),
          //         blurRadius: 14.spMin,
          //         offset: Offset(0, 4.spMin),
          //       ),
          //     ],
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       // Header
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             "Vehicle capacity limit",
          //             style: TextStyle(
          //               fontSize: 14.5.spMin,
          //               fontWeight: FontWeight.w800,
          //               color: const Color(0xFF212121),
          //             ),
          //           ),
          //           Text(
          //             "${usedCapacity.toStringAsFixed(2)} of ${capacity.toStringAsFixed(0)} Kg used",
          //             style: TextStyle(
          //               fontSize: 13.spMin,
          //               fontWeight: FontWeight.w700,
          //               color: const Color(0xFF1D723C),
          //             ),
          //           ),
          //         ],
          //       ),

          //       SizedBox(height: 12.spMin),

          //       // Progress Bar
          //       Container(
          //         height: 12.spMin,
          //         width: double.infinity,
          //         decoration: BoxDecoration(
          //           color: const Color(0xFFEFEFEF),
          //           borderRadius: BorderRadius.circular(6.spMin),
          //         ),
          //         child: FractionallySizedBox(
          //           alignment: Alignment.centerLeft,
          //           widthFactor: capacityProgress,
          //           child: Container(
          //             decoration: BoxDecoration(
          //               color: capacityProgress >= 0.9
          //                   ? const Color(0xFFE53935)
          //                   : const Color(0xFF1D723C),
          //               borderRadius: BorderRadius.circular(6.spMin),
          //             ),
          //           ),
          //         ),
          //       ),

          //       SizedBox(height: 16.spMin),

          //       // Waste Categories Legend
          //       Wrap(
          //         spacing: 16.spMin,
          //         runSpacing: 10.spMin,
          //         children: [
          //           _buildLegendItem(
          //             color: const Color(0xFFE57373),
          //             label:
          //                 "Sanitary Pad (${getQty('Sanitary Pad').toStringAsFixed(1)} Kg)",
          //           ),
          //           _buildLegendItem(
          //             color: const Color(0xFFFFB74D),
          //             label:
          //                 "Medical Waste (${getQty('Medical Waste').toStringAsFixed(1)} Kg)",
          //           ),
          //           _buildLegendItem(
          //             color: const Color(0xFFFFF176),
          //             label:
          //                 "Diapers (${getQty('Diaper').toStringAsFixed(1)} Kg)",
          //           ),
          //           _buildLegendItem(
          //             color: const Color(0xFF4DB6AC),
          //             label: "Hair (${getQty('Hair').toStringAsFixed(1)} Kg)",
          //           ),
          //           _buildLegendItem(
          //             color: const Color(0xFF90A4AE),
          //             label:
          //                 "Scrap/Other (${getQty('Scrap').toStringAsFixed(1)} Kg)",
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),

          //SizedBox(height: 20.spMin),
        ],
      ),
    );
  }

  // TAB 2: DAILY SUMMARY
  Widget _buildDailySummaryTab(HistoryViewModel historyVm) {
    final dailySummary = historyVm.dailySummary;
    final totalKg = historyVm.overview.totalQuantityKg > 0
        ? historyVm.overview.totalQuantityKg
        : dailySummary.fold<double>(
            0.0, (sum, item) => sum + item.totalQuantityKg);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 8.spMin),
      child: Column(
        children: [
          SizedBox(height: 8.spMin),

          // Top Header Total
          Text(
            "${totalKg.toStringAsFixed(2)} Kg Collected",
            style: TextStyle(
              fontSize: 17.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF135C30),
              letterSpacing: -0.2.spMin,
            ),
          ),

          SizedBox(height: 18.spMin),

          if (dailySummary.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 20.spMin, vertical: 32.spMin),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.spMin),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14.spMin,
                    offset: Offset(0, 4.spMin),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 38.spMin,
                    color: const Color(0xFFBDBDBD),
                  ),
                  SizedBox(height: 10.spMin),
                  Text(
                    "No daily summary available",
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dailySummary.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.spMin),
              itemBuilder: (context, index) {
                final item = dailySummary[index];
                return Container(
                  padding: EdgeInsets.all(16.spMin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.spMin),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14.spMin,
                        offset: Offset(0, 4.spMin),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.spMin),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10.spMin),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: const Color(0xFF1D723C),
                              size: 18.spMin,
                            ),
                          ),
                          SizedBox(width: 10.spMin),
                          Expanded(
                            child: Text(
                              item.date.isNotEmpty
                                  ? item.date
                                  : "Day ${index + 1}",
                              style: TextStyle(
                                fontSize: 15.spMin,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF212121),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.spMin,
                              vertical: 4.spMin,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12.spMin),
                            ),
                            child: Text(
                              "${item.totalOrders} Orders",
                              style: TextStyle(
                                fontSize: 11.5.spMin,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1D723C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.spMin),
                      Divider(color: const Color(0xFFF0F0F0), height: 1.spMin),
                      SizedBox(height: 12.spMin),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryMetric(
                            "QUANTITY",
                            "${item.totalQuantityKg.toStringAsFixed(2)} Kg",
                            Icons.scale_rounded,
                          ),
                          _buildSummaryMetric(
                            "AMOUNT",
                            "₹${item.totalAmount.toStringAsFixed(2)}",
                            Icons.currency_rupee_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

          SizedBox(height: 20.spMin),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16.spMin, color: const Color(0xFF1D723C)),
        SizedBox(width: 6.spMin),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.spMin,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF757575),
                letterSpacing: 0.3.spMin,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.5.spMin,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF212121),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // TAB 3: COMPLETED RECORDS
  Widget _buildCompletedRecordsTab(HistoryViewModel historyVm) {
    return Column(
      children: [
        // Search Bar + Filter Icon Row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.spMin),
          child: Row(
            children: [
              // Expanded(
              //   child: Container(
              //     height: 46.spMin,
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(16.spMin),
              //       border: Border.all(
              //         color: const Color(0xFFC8E6C9),
              //         width: 1.spMin,
              //       ),
              //     ),
              //     child: TextField(
              //       controller: _searchController,
              //       onChanged: (val) =>
              //           context.read<HistoryViewModel>().setSearchQuery(val),
              //       style: TextStyle(
              //         fontSize: 14.spMin,
              //         color: SuchigoColors.textDark,
              //       ),
              //       decoration: InputDecoration(
              //         filled: false,
              //         fillColor: Colors.transparent,
              //         hoverColor: Colors.transparent,
              //         focusColor: Colors.transparent,
              //         hintText: "Search by customer name or ID...",
              //         hintStyle: TextStyle(
              //           color: const Color(0xFF9E9E9E),
              //           fontSize: 13.spMin,
              //           fontWeight: FontWeight.w400,
              //         ),
              //         prefixIcon: Icon(
              //           Icons.search_rounded,
              //           color: const Color(0xFF1D723C),
              //           size: 20.spMin,
              //         ),
              //         border: InputBorder.none,
              //         enabledBorder: InputBorder.none,
              //         focusedBorder: InputBorder.none,
              //         disabledBorder: InputBorder.none,
              //         errorBorder: InputBorder.none,
              //         contentPadding: EdgeInsets.symmetric(
              //           vertical: 12.spMin,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(width: 10.spMin),
              // GestureDetector(
              //   onTap: _showFilterSortBottomSheet,
              //   child: Container(
              //     width: 46.spMin,
              //     height: 46.spMin,
              //     decoration: BoxDecoration(
              //       color: (historyVm.selectedPaymentMethod != "All" ||
              //               historyVm.selectedWasteCategory != "All" ||
              //               historyVm.selectedSortBy != "Default")
              //           ? const Color(0xFFE8F5E9)
              //           : Colors.white,
              //       borderRadius: BorderRadius.circular(16.spMin),
              //       border: Border.all(
              //         color: (historyVm.selectedPaymentMethod != "All" ||
              //                 historyVm.selectedWasteCategory != "All" ||
              //                 historyVm.selectedSortBy != "Default")
              //             ? const Color(0xFF1D723C)
              //             : const Color(0xFFE0E0E0),
              //         width: 1.spMin,
              //       ),
              //     ),
              //     child: Icon(
              //       Icons.filter_list_rounded,
              //       color: const Color(0xFF1D723C),
              //       size: 22.spMin,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),

        SizedBox(height: 20.spMin),

        // Completed List or Empty State
        Expanded(
          child: historyVm.completedRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 44.spMin,
                        color: const Color(0xFFBDBDBD),
                      ),
                      SizedBox(height: 10.spMin),
                      Text(
                        "No completed collections found",
                        style: TextStyle(
                          fontSize: 14.5.spMin,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.spMin, vertical: 8.spMin),
                  itemCount: historyVm.completedRecords.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.spMin),
                  itemBuilder: (context, index) {
                    final record = historyVm.completedRecords[index];
                    final displayName = record.name.trim().isNotEmpty
                        ? record.name.trim()
                        : "Customer #${record.id}";
                    final localBodyStr = (record.localBody != null &&
                            record.localBody!.trim().isNotEmpty)
                        ? record.localBody!.trim()
                        : "";
                    final isCash =
                        (record.paymentMethod?.toLowerCase() ?? '') == 'cash';
                    final paymentMethodStr =
                        (record.paymentMethod?.isNotEmpty == true)
                            ? record.paymentMethod!.toUpperCase()
                            : "CASH";
                    final weightStr =
                        "${record.quantityKg.toStringAsFixed(record.quantityKg.truncateToDouble() == record.quantityKg ? 0 : 1)} kg";
                    final totalAmountStr =
                        "₹${record.amount.toStringAsFixed(2)}";
                    final bagRateStr =
                        (record.bagRate != null && record.bagRate! > 0)
                            ? "₹${record.bagRate!.toStringAsFixed(2)}"
                            : "₹10.00";
                    final pickupDateStr = (record.pickupDate != null &&
                            record.pickupDate!.trim().isNotEmpty)
                        ? _formatDisplayDate(record.pickupDate!)
                        : "Today";
                    final locationIdStr = "ORD-${record.id}";

                    return Container(
                      padding: EdgeInsets.all(16.spMin),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.spMin),
                        border: Border.all(
                          color: const Color(0xFFE8F5E9),
                          width: 1.2.spMin,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10.spMin,
                            offset: Offset(0, 3.spMin),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Customer Name + Location ID Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 16.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.spMin),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.spMin,
                                  vertical: 5.spMin,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8.spMin),
                                ),
                                child: Text(
                                  locationIdStr,
                                  style: TextStyle(
                                    fontSize: 12.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1D723C),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10.spMin),

                          // 2. Local Body Row (without ward name & without pickup Id)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.spMin,
                              vertical: 7.spMin,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FBF9),
                              borderRadius: BorderRadius.circular(10.spMin),
                              border: Border.all(
                                color: const Color(0xFFE0EFE0),
                                width: 1.spMin,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_balance_outlined,
                                  size: 15.spMin,
                                  color: const Color(0xFF1D723C),
                                ),
                                SizedBox(width: 6.spMin),
                                Expanded(
                                  child: Text(
                                    localBodyStr,
                                    style: TextStyle(
                                      fontSize: 12.5.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2E7D32),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12.spMin),
                          Divider(
                            color: const Color(0xFFF0F0F0),
                            thickness: 1.spMin,
                            height: 1.spMin,
                          ),
                          SizedBox(height: 10.spMin),

                          // 3. Four-Tile Key Metrics: Pickup Date, Weight, Bag Rate, Total Amount
                          Row(
                            children: [
                              // Pickup Date
                              Expanded(
                                child: _buildDetailTile(
                                  icon: Icons.calendar_today_rounded,
                                  label: "PICKUP DATE",
                                  value: pickupDateStr,
                                  iconColor: const Color(0xFF1D723C),
                                  bgColor: const Color(0xFFE8F5E9),
                                ),
                              ),
                              SizedBox(width: 10.spMin),
                              // Weight
                              Expanded(
                                child: _buildDetailTile(
                                  icon: Icons.scale_rounded,
                                  label: "WEIGHT",
                                  value: weightStr,
                                  iconColor: const Color(0xFF1976D2),
                                  bgColor: const Color(0xFFE3F2FD),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10.spMin),

                          Row(
                            children: [
                              // Bag Rate
                              Expanded(
                                child: _buildDetailTile(
                                  icon: Icons.shopping_bag_outlined,
                                  label: "BAG RATE",
                                  value: bagRateStr,
                                  iconColor: const Color(0xFF7B1FA2),
                                  bgColor: const Color(0xFFF3E5F5),
                                ),
                              ),
                              SizedBox(width: 10.spMin),
                              // Total Amount
                              Expanded(
                                child: _buildDetailTile(
                                  icon: Icons.currency_rupee_rounded,
                                  label: "TOTAL AMOUNT",
                                  value: totalAmountStr,
                                  valueColor: const Color(0xFF1D723C),
                                  iconColor: const Color(0xFF1D723C),
                                  bgColor: const Color(0xFFE8F5E9),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.spMin),

                          // 4. Payment Method & Status
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.spMin,
                              vertical: 8.spMin,
                            ),
                            decoration: BoxDecoration(
                              color: isCash
                                  ? const Color(0xFFFFF8E1)
                                  : const Color(0xFFE8F4FD),
                              borderRadius: BorderRadius.circular(10.spMin),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isCash
                                          ? Icons.payments_outlined
                                          : Icons.credit_card_rounded,
                                      size: 16.spMin,
                                      color: isCash
                                          ? const Color(0xFFE65100)
                                          : const Color(0xFF1565C0),
                                    ),
                                    SizedBox(width: 6.spMin),
                                    Text(
                                      "Payment: $paymentMethodStr",
                                      style: TextStyle(
                                        fontSize: 12.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: isCash
                                            ? const Color(0xFFE65100)
                                            : const Color(0xFF1565C0),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 14.spMin,
                                      color: const Color(0xFF1D723C),
                                    ),
                                    SizedBox(width: 4.spMin),
                                    Text(
                                      (record.status?.isNotEmpty == true)
                                          ? record.status!.toUpperCase()
                                          : "COMPLETED",
                                      style: TextStyle(
                                        fontSize: 11.5.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1D723C),
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
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.spMin,
        vertical: 8.spMin,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10.spMin),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1.spMin,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5.spMin),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 14.spMin,
              color: iconColor,
            ),
          ),
          SizedBox(width: 8.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5.spMin,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9E9E9E),
                    letterSpacing: 0.3.spMin,
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? const Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.spMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF757575),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9.spMin,
          height: 9.spMin,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.spMin),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.spMin,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF616161),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: const Color(0xFFF0F0F0),
      height: 1.spMin,
      thickness: 1.spMin,
    );
  }

  Widget _buildTabItem(int index, String title, int selectedTabIndex) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        context.read<HistoryViewModel>().setTabIndex(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.spMin, horizontal: 8.spMin),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF1D723C) : Colors.transparent,
              width: 2.5.spMin,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13.5.spMin,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color:
                isSelected ? const Color(0xFF1D723C) : const Color(0xFF757575),
          ),
        ),
      ),
    );
  }
}
