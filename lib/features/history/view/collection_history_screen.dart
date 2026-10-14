import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/features/history/view_model/history_view_model.dart';
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
        context.read<HistoryViewModel>().fetchCollectionRecords();
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
            color: isSelected
                ? const Color(0xFF1D723C)
                : const Color(0xFFDCEAD9),
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
        : (collector?.username.isNotEmpty == true
            ? collector!.username
            : "shyam");
    final providerMobile = collector?.phone.isNotEmpty == true
        ? collector!.phone
        : "7012432589";

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

                // Filter Collections Card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.spMin),
                  padding: EdgeInsets.all(16.spMin),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.spMin),
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
                      // Header Row
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            color: const Color(0xFF1D723C),
                            size: 20.spMin,
                          ),
                          SizedBox(width: 8.spMin),
                          Text(
                            "Filter Collections",
                            style: TextStyle(
                              fontSize: 15.spMin,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF135C30),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.spMin),

                      // FROM & TO Date Pickers
                      Row(
                        children: [
                          // FROM Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "FROM",
                                  style: TextStyle(
                                    fontSize: 10.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF757575),
                                    letterSpacing: 0.5.spMin,
                                  ),
                                ),
                                SizedBox(height: 4.spMin),
                                GestureDetector(
                                  onTap: () => _pickDate(true),
                                  child: Container(
                                    height: 42.spMin,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.spMin),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F9F9),
                                      borderRadius:
                                          BorderRadius.circular(12.spMin),
                                      border: Border.all(
                                        color: const Color(0xFFE0E0E0),
                                        width: 1.spMin,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 15.spMin,
                                          color: const Color(0xFF1D723C),
                                        ),
                                        SizedBox(width: 8.spMin),
                                        Text(
                                          _formatDate(historyVm.fromDate),
                                          style: TextStyle(
                                            fontSize: 13.spMin,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF212121),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(
                              top: 14.spMin,
                              left: 8.spMin,
                              right: 8.spMin,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16.spMin,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),

                          // TO Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "TO",
                                  style: TextStyle(
                                    fontSize: 10.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF757575),
                                    letterSpacing: 0.5.spMin,
                                  ),
                                ),
                                SizedBox(height: 4.spMin),
                                GestureDetector(
                                  onTap: () => _pickDate(false),
                                  child: Container(
                                    height: 42.spMin,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.spMin),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F9F9),
                                      borderRadius:
                                          BorderRadius.circular(12.spMin),
                                      border: Border.all(
                                        color: const Color(0xFFE0E0E0),
                                        width: 1.spMin,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 15.spMin,
                                          color: const Color(0xFF1D723C),
                                        ),
                                        SizedBox(width: 8.spMin),
                                        Text(
                                          _formatDate(historyVm.toDate),
                                          style: TextStyle(
                                            fontSize: 13.spMin,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF212121),
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

                      SizedBox(height: 14.spMin),

                      // APPLY FILTER Button
                      SizedBox(
                        width: double.infinity,
                        height: 44.spMin,
                        child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<HistoryViewModel>()
                                .fetchCollectionRecords();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D723C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.spMin),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_alt_rounded,
                                color: Colors.white,
                                size: 18.spMin,
                              ),
                              SizedBox(width: 6.spMin),
                              Text(
                                "APPLY FILTER",
                                style: TextStyle(
                                  fontSize: 13.spMin,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.6.spMin,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
        return _buildDailySummaryTab();
      case 2:
      default:
        return _buildCompletedRecordsTab(historyVm);
    }
  }

  // TAB 1: OVERVIEW
  Widget _buildOverviewTab(
      String providerName, String providerMobile, HistoryViewModel historyVm) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 4.spMin),
      child: Column(
        children: [
          // Card 1: Provider Summary Details
          Container(
            padding: EdgeInsets.fromLTRB(20.spMin, 18.spMin, 20.spMin, 18.spMin),
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
                _buildOverviewRow("Provider Name", providerName),
                _buildDivider(),
                _buildOverviewRow("Provider Mobile", providerMobile),
                _buildDivider(),
                _buildOverviewRow("Total Quantity", "0.00 Kg"),
                _buildDivider(),
                _buildOverviewRow("Total Amount", "₹0.00"),
                _buildDivider(),
                _buildOverviewRow(
                    "Total Orders", "${historyVm.allRecords.length}"),
              ],
            ),
          ),

          SizedBox(height: 16.spMin),

          // Card 2: Vehicle Capacity Limit
          Container(
            padding: EdgeInsets.all(18.spMin),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Vehicle capacity limit",
                      style: TextStyle(
                        fontSize: 14.5.spMin,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    Text(
                      "0.00 of 500 Kg used",
                      style: TextStyle(
                        fontSize: 13.spMin,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D723C),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.spMin),

                // Empty / Filled Progress bar
                Container(
                  height: 12.spMin,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(6.spMin),
                  ),
                ),

                SizedBox(height: 16.spMin),

                // Waste Categories Legend
                Wrap(
                  spacing: 16.spMin,
                  runSpacing: 10.spMin,
                  children: [
                    _buildLegendItem(
                      color: const Color(0xFFE57373),
                      label: "Sanitary Pad (0.0 Kg)",
                    ),
                    _buildLegendItem(
                      color: const Color(0xFFFFB74D),
                      label: "Medical Waste (0.0 Kg)",
                    ),
                    _buildLegendItem(
                      color: const Color(0xFFFFF176),
                      label: "Diapers (0.0 Kg)",
                    ),
                    _buildLegendItem(
                      color: const Color(0xFF4DB6AC),
                      label: "Hair (0.0 Kg)",
                    ),
                    _buildLegendItem(
                      color: const Color(0xFF90A4AE),
                      label: "Scrap/Other (0.0 Kg)",
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.spMin),
        ],
      ),
    );
  }

  // TAB 2: DAILY SUMMARY
  Widget _buildDailySummaryTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 8.spMin),
      child: Column(
        children: [
          SizedBox(height: 8.spMin),

          // Top Header Total
          Text(
            "0.00 Kg Collected",
            style: TextStyle(
              fontSize: 17.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF135C30),
              letterSpacing: -0.2.spMin,
            ),
          ),

          SizedBox(height: 18.spMin),

          // Daily Summary Card
          Container(
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
                    Icon(
                      Icons.description_rounded,
                      color: const Color(0xFF1D723C),
                      size: 24.spMin,
                    ),
                    SizedBox(width: 10.spMin),
                    Text(
                      "Daily Summary",
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF212121),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 36.spMin,
                      height: 36.spMin,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: const Color(0xFF1D723C),
                        size: 18.spMin,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.spMin),
                Text(
                  "No daily data available",
                  style: TextStyle(
                    fontSize: 13.5.spMin,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.spMin),
        ],
      ),
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
              Expanded(
                child: Container(
                  height: 46.spMin,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.spMin),
                    border: Border.all(
                      color: const Color(0xFFC8E6C9),
                      width: 1.spMin,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        context.read<HistoryViewModel>().setSearchQuery(val),
                    style: TextStyle(
                      fontSize: 14.spMin,
                      color: SuchigoColors.textDark,
                    ),
                    decoration: InputDecoration(
                      filled: false,
                      fillColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hintText: "Search by customer name or pho...",
                      hintStyle: TextStyle(
                        color: const Color(0xFF9E9E9E),
                        fontSize: 13.spMin,
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
              GestureDetector(
                onTap: _showFilterSortBottomSheet,
                child: Container(
                  width: 46.spMin,
                  height: 46.spMin,
                  decoration: BoxDecoration(
                    color: (historyVm.selectedPaymentMethod != "All" ||
                            historyVm.selectedWasteCategory != "All" ||
                            historyVm.selectedSortBy != "Default")
                        ? const Color(0xFFE8F5E9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16.spMin),
                    border: Border.all(
                      color: (historyVm.selectedPaymentMethod != "All" ||
                              historyVm.selectedWasteCategory != "All" ||
                              historyVm.selectedSortBy != "Default")
                          ? const Color(0xFF1D723C)
                          : const Color(0xFFE0E0E0),
                      width: 1.spMin,
                    ),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    color: const Color(0xFF1D723C),
                    size: 22.spMin,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20.spMin),

        // Completed List or Empty State
        Expanded(
          child: historyVm.completedRecords.isEmpty
              ? Center(
                  child: Text(
                    "No completed collections found",
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9E9E9E),
                    ),
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
                    return Container(
                      padding: EdgeInsets.all(14.spMin),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.spMin),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10.spMin,
                            offset: Offset(0, 3.spMin),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                record.name,
                                style: TextStyle(
                                  fontSize: 15.spMin,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF212121),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.spMin,
                                  vertical: 3.spMin,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8.spMin),
                                ),
                                child: Text(
                                  record.status ?? "Completed",
                                  style: TextStyle(
                                    fontSize: 11.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1D723C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (record.contactNumber != null) ...[
                            SizedBox(height: 4.spMin),
                            Text(
                              record.contactNumber!,
                              style: TextStyle(
                                fontSize: 12.5.spMin,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ],
                          if (record.street != null) ...[
                            SizedBox(height: 4.spMin),
                            Text(
                              record.street!,
                              style: TextStyle(
                                fontSize: 12.spMin,
                                color: const Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
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
              color: isSelected
                  ? const Color(0xFF1D723C)
                  : Colors.transparent,
              width: 2.5.spMin,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13.5.spMin,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF1D723C)
                : const Color(0xFF757575),
          ),
        ),
      ),
    );
  }
}
