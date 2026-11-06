import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view_model/admin_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class AdminCollectorHistoryScreen extends StatefulWidget {
  final CollectorModel collector;
  final AdminCollectorStats? stats;
  final AdminCollectorHistoryModel? initialHistory;

  const AdminCollectorHistoryScreen({
    super.key,
    required this.collector,
    this.stats,
    this.initialHistory,
  });

  @override
  State<AdminCollectorHistoryScreen> createState() =>
      _AdminCollectorHistoryScreenState();
}

class _AdminCollectorHistoryRecord {
  final String scheduleCode;
  final String customerName;
  final String customerMobile;
  final String vehicleName;
  final String vehicleNo;
  final double amount;
  final double quantityKg;
  final String paymentMethod;
  final String date;

  _AdminCollectorHistoryRecord({
    required this.scheduleCode,
    required this.customerName,
    required this.customerMobile,
    required this.vehicleName,
    required this.vehicleNo,
    required this.amount,
    required this.quantityKg,
    required this.paymentMethod,
    required this.date,
  });
}

class _AdminCollectorHistoryScreenState
    extends State<AdminCollectorHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedPaymentFilter = "All";

  List<_AdminCollectorHistoryRecord> _records = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialHistory != null) {
      _populateFromHistory(widget.initialHistory!);
    }
    _loadHistory();
  }

  void _populateFromHistory(AdminCollectorHistoryModel history) {
    final defaultVehicleName = widget.collector.vehicleName?.isNotEmpty == true
        ? widget.collector.vehicleName!
        : (history.collector.vehicleName?.isNotEmpty == true
            ? history.collector.vehicleName!
            : "No vehicle assigned");
    final defaultVehicleNumber =
        widget.collector.vehicleNumber?.isNotEmpty == true
            ? widget.collector.vehicleNumber!
            : (history.collector.vehicleNumber?.isNotEmpty == true
                ? history.collector.vehicleNumber!
                : "N/A");

    _records = history.locations.map((loc) {
      return _AdminCollectorHistoryRecord(
        scheduleCode: loc.scheduleCode ?? "BILL-${loc.pickupId ?? loc.id}",
        customerName: loc.name.isNotEmpty ? loc.name : "Customer",
        customerMobile: loc.contactNumber?.isNotEmpty == true
            ? loc.contactNumber!
            : "N/A",
        vehicleName: loc.vehicleName?.isNotEmpty == true
            ? loc.vehicleName!
            : defaultVehicleName,
        vehicleNo: loc.vehicleNumber?.isNotEmpty == true
            ? loc.vehicleNumber!
            : defaultVehicleNumber,
        amount: loc.amount,
        quantityKg: loc.quantityKg,
        paymentMethod: (loc.paymentMethod?.isNotEmpty == true
                ? loc.paymentMethod!
                : "ONLINE")
            .toUpperCase(),
        date: loc.pickupDate ?? "N/A",
      );
    }).toList();
  }

  Future<void> _loadHistory() async {
    if (_records.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final adminVm = context.read<AdminViewModel>();
      final history = await adminVm.fetchCollectorHistory(widget.collector.id);
      if (history != null && mounted) {
        setState(() {
          _populateFromHistory(history);
        });
      }
    } catch (e) {
      debugPrint('[AdminCollectorHistoryScreen] _loadHistory error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_AdminCollectorHistoryRecord> get _filteredRecords {
    return _records.where((r) {
      if (_selectedPaymentFilter != "All" &&
          r.paymentMethod.toUpperCase() !=
              _selectedPaymentFilter.toUpperCase()) {
        return false;
      }
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return r.customerName.toLowerCase().contains(q) ||
          r.customerMobile.toLowerCase().contains(q) ||
          r.scheduleCode.toLowerCase().contains(q) ||
          r.vehicleNo.toLowerCase().contains(q);
    }).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.spMin)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.spMin, 16.spMin, 20.spMin, 24.spMin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.spMin,
                  height: 4.spMin,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2.spMin),
                  ),
                ),
              ),
              SizedBox(height: 16.spMin),
              Text(
                "Filter History",
                style: TextStyle(
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B4D3E),
                ),
              ),
              SizedBox(height: 14.spMin),
              Wrap(
                spacing: 8.spMin,
                children: ["All", "ONLINE", "CASH"].map((method) {
                  final isSelected = _selectedPaymentFilter == method;
                  return ChoiceChip(
                    label: Text(method),
                    selected: isSelected,
                    selectedColor: const Color(0xFFDFF3E0),
                    backgroundColor: const Color(0xFFF5F5F5),
                    labelStyle: TextStyle(
                      fontSize: 13.spMin,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF1D723C)
                          : const Color(0xFF616161),
                    ),
                    onSelected: (val) {
                      setState(() => _selectedPaymentFilter = method);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final collectorName = widget.collector.name.isNotEmpty
        ? widget.collector.name
        : (widget.collector.username.isNotEmpty
            ? widget.collector.username
            : "Amal");

    final vehicleDisplay = widget.collector.vehicleName?.isNotEmpty == true
        ? "${widget.collector.vehicleName}${widget.collector.vehicleNumber?.isNotEmpty == true ? ' (${widget.collector.vehicleNumber})' : ''}"
        : "No vehicle assigned";

    final initialLetter = (collectorName.isNotEmpty ? collectorName[0] : "A")
        .toUpperCase();

    final filteredList = _filteredRecords;

    final double totalQuantity = _records.isNotEmpty
        ? _records.fold(0.0, (sum, r) => sum + r.quantityKg)
        : (widget.stats?.quantityKg ?? 0.0);
    final double totalRevenue = _records.isNotEmpty
        ? _records.fold(0.0, (sum, r) => sum + r.amount)
        : (widget.stats?.revenue ?? 0.0);
    final int pickups = _records.isNotEmpty
        ? _records.length
        : (widget.stats?.pickups ?? 0);
    final double cashCollected = _records
        .where((r) => r.paymentMethod.toUpperCase() == "CASH")
        .fold(0.0, (sum, r) => sum + r.amount);
    final double onlineCollected = _records.isNotEmpty
        ? _records
            .where((r) => r.paymentMethod.toUpperCase() == "ONLINE")
            .fold(0.0, (sum, r) => sum + r.amount)
        : totalRevenue;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F8F2),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: const Color(0xFF1D723C),
            size: 24.spMin,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "$collectorName's History",
          style: TextStyle(
            fontSize: 18.5.spMin,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF135C30),
            letterSpacing: -0.3.spMin,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: const Color(0xFF1D723C),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 8.spMin),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile & Performance Metrics Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.spMin),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.spMin),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10.spMin,
                    offset: Offset(0, 3.spMin),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar, Name & Vehicle
                  Row(
                    children: [
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collectorName,
                              style: TextStyle(
                                fontSize: 16.spMin,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF212121),
                              ),
                            ),
                            SizedBox(height: 2.spMin),
                            Text(
                              vehicleDisplay,
                              style: TextStyle(
                                fontSize: 12.5.spMin,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.spMin),

                  // Metric Row 1: Total Quantity, Total Revenue, Pickups
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: "Total Quantity",
                          value: "${totalQuantity.toStringAsFixed(1)} Kg",
                        ),
                      ),
                      SizedBox(width: 8.spMin),
                      Expanded(
                        child: _buildMetricTile(
                          label: "Total Revenue",
                          value: "₹${totalRevenue.toInt()}",
                        ),
                      ),
                      SizedBox(width: 8.spMin),
                      Expanded(
                        child: _buildMetricTile(
                          label: "Pickups",
                          value: "$pickups",
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.spMin),

                  // Metric Row 2: Cash Collected, Online Collected
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: "Cash Collected",
                          value: "₹${cashCollected.toInt()}",
                        ),
                      ),
                      SizedBox(width: 8.spMin),
                      Expanded(
                        child: _buildMetricTile(
                          label: "Online Collected",
                          value: "₹${onlineCollected.toInt()}",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.spMin),

            // 2. Search & Filter Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48.spMin,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.spMin),
                      border: Border.all(
                        color: const Color(0xFFCDE8CE),
                        width: 1.spMin,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
                      },
                      style: TextStyle(
                        fontSize: 14.spMin,
                        color: SuchigoColors.textDark,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        hintText: "Search by customer name, phone...",
                        hintStyle: TextStyle(
                          color: const Color(0xFF9E9E9E),
                          fontSize: 13.spMin,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: const Color(0xFF1D723C),
                          size: 22.spMin,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 13.spMin),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.spMin),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    width: 48.spMin,
                    height: 48.spMin,
                    decoration: BoxDecoration(
                      color: _selectedPaymentFilter != "All"
                          ? const Color(0xFFDFF3E0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16.spMin),
                      border: Border.all(
                        color: const Color(0xFFCDE8CE),
                        width: 1.spMin,
                      ),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: const Color(0xFF1D723C),
                      size: 22.spMin,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.spMin),

            // 3. Collection Cards List
            if (_isLoading && _records.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(48.spMin),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.spMin),
                ),
                child: const CircularProgressIndicator(
                  color: Color(0xFF1D723C),
                ),
              )
            else if (filteredList.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.spMin,
                  vertical: 36.spMin,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.spMin),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 48.spMin,
                      color: const Color(0xFFBDBDBD),
                    ),
                    SizedBox(height: 12.spMin),
                    Text(
                      "No collection history records found",
                      style: TextStyle(
                        fontSize: 14.5.spMin,
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
                itemCount: filteredList.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.spMin),
                itemBuilder: (context, index) {
                  final record = filteredList[index];
                  return _buildHistoryCard(record);
                },
              ),

            SizedBox(height: 24.spMin),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildMetricTile({required String label, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.spMin, horizontal: 8.spMin),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(
          color: const Color(0xFFE8EFE8),
          width: 1.spMin,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5.spMin,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF757575),
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(_AdminCollectorHistoryRecord record) {
    return Container(
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
        children: [
          // Schedule Code Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Schedule Code",
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF757575),
                ),
              ),
              Text(
                record.scheduleCode,
                style: TextStyle(
                  fontSize: 13.5.spMin,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1D723C),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.spMin),
            child: Divider(
              color: const Color(0xFFF0F0F0),
              height: 1.spMin,
              thickness: 1.spMin,
            ),
          ),

          _buildRow("Customer Name", record.customerName),
          SizedBox(height: 8.spMin),
          _buildRow("Customer Mobile", record.customerMobile),
          SizedBox(height: 8.spMin),
          _buildRow("Vehicle Name", record.vehicleName),
          SizedBox(height: 8.spMin),
          _buildRow("Vehicle No", record.vehicleNo),
          SizedBox(height: 8.spMin),
          _buildRow("Amount", "₹${record.amount.toStringAsFixed(2)}"),
          SizedBox(height: 8.spMin),
          _buildRow("Quantity", "${record.quantityKg.toStringAsFixed(2)} Kg"),
          SizedBox(height: 8.spMin),
          _buildRow("Payment Method", record.paymentMethod),
          SizedBox(height: 8.spMin),
          _buildRow("Date", record.date),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF757575),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5.spMin,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}
