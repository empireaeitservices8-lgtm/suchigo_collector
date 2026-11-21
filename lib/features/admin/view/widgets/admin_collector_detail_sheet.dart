import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view/widgets/assign_vehicle_dialog.dart';
import 'package:suchigo_collector/features/admin/view/widgets/assign_bags_dialog.dart';
import 'package:suchigo_collector/features/admin/view/admin_collector_history_screen.dart';
import 'package:suchigo_collector/features/admin/view_model/admin_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';

class AdminCollectorDetailSheet extends StatefulWidget {
  final AdminCollectorStats stats;

  const AdminCollectorDetailSheet({
    super.key,
    required this.stats,
  });

  static Future<void> show(BuildContext context, AdminCollectorStats stats) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminCollectorDetailSheet(stats: stats),
    );
  }

  @override
  State<AdminCollectorDetailSheet> createState() =>
      _AdminCollectorDetailSheetState();
}

class _AdminCollectorDetailSheetState extends State<AdminCollectorDetailSheet> {
  AdminCollectorHistoryModel? _historyData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final adminVm = context.read<AdminViewModel>();
      final result =
          await adminVm.fetchCollectorHistory(widget.stats.collector.id);
      if (mounted) {
        setState(() {
          _historyData = result;
        });
      }
    } catch (e) {
      debugPrint('[AdminCollectorDetailSheet] _loadHistory error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collector = _historyData?.collector ?? widget.stats.collector;
    final totalBags =
        (_historyData != null && _historyData!.assignedBagCount > 0)
            ? _historyData!.assignedBagCount
            : (_historyData?.totalBagAssignments ?? 0);
    final locations = _historyData?.locations ?? [];

    // District and Local Body directly from collector object
    final String districtName =
        (collector.district != null && collector.district!.trim().isNotEmpty)
            ? collector.district!.trim()
            : (_historyData != null && _historyData!.district.trim().isNotEmpty
                ? _historyData!.district.trim()
                : (_isLoading ? "Loading..." : ""));

    final String localBodyName = (collector.localBodyName != null &&
            collector.localBodyName!.trim().isNotEmpty)
        ? collector.localBodyName!.trim()
        : ((collector.localBody != null &&
                collector.localBody!.trim().isNotEmpty)
            ? collector.localBody!.trim()
            : (_historyData != null && _historyData!.localBody.trim().isNotEmpty
                ? _historyData!.localBody.trim()
                : (_isLoading ? "Loading..." : "")));

    // Performance metrics directly from collector stats / API
    final completedLocations = locations
        .where((l) => l.status?.trim().toLowerCase() == 'completed')
        .toList();
    final totalPickups = widget.stats.pickups > 0
        ? widget.stats.pickups
        : (collector.totalPickups > 0
            ? collector.totalPickups
            : completedLocations.length);
    final totalWasteKg = widget.stats.quantityKg > 0
        ? widget.stats.quantityKg
        : (collector.totalQuantity > 0
            ? collector.totalQuantity
            : completedLocations.fold(0.0, (sum, l) => sum + l.quantityKg));
    final totalRevenue = widget.stats.revenue > 0
        ? widget.stats.revenue
        : (collector.totalRevenue > 0
            ? collector.totalRevenue
            : completedLocations.fold(0.0, (sum, l) => sum + l.amount));
    final cashCollected = widget.stats.cashCollected > 0
        ? widget.stats.cashCollected
        : (collector.cashCollected > 0
            ? collector.cashCollected
            : completedLocations
                .where((l) =>
                    (l.paymentMethod ?? '').trim().toUpperCase() == 'CASH')
                .fold(0.0, (sum, l) => sum + l.amount));
    final onlineCollected = widget.stats.onlineCollected > 0
        ? widget.stats.onlineCollected
        : (collector.onlineCollected > 0
            ? collector.onlineCollected
            : completedLocations
                .where((l) =>
                    (l.paymentMethod ?? '').trim().toUpperCase() == 'ONLINE')
                .fold(0.0, (sum, l) => sum + l.amount));

    final vehicleDisplay = collector.vehicleName?.isNotEmpty == true
        ? "${collector.vehicleName}${collector.vehicleNumber?.isNotEmpty == true ? ' (${collector.vehicleNumber})' : ''}"
        : "No vehicle assigned";

    final nameDisplay = collector.name.trim().isNotEmpty
        ? collector.name.trim()
        : (collector.username.trim().isNotEmpty
            ? collector.username.trim()
            : "Collector");

    final phoneDisplay =
        collector.phone.trim().isNotEmpty ? collector.phone.trim() : "";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.spMin),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            22.spMin,
            12.spMin,
            22.spMin,
            MediaQuery.of(context).viewInsets.bottom + 24.spMin,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Center Grab Handle
              Center(
                child: Container(
                  width: 44.spMin,
                  height: 4.spMin,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6D6D6),
                    borderRadius: BorderRadius.circular(2.spMin),
                  ),
                ),
              ),

              SizedBox(height: 18.spMin),

              // 2. Collector Name, Status Badge & Phone
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameDisplay,
                          style: TextStyle(
                            fontSize: 20.spMin,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B4D3E),
                            letterSpacing: -0.2.spMin,
                          ),
                        ),
                        SizedBox(height: 4.spMin),
                        Text(
                          "Phone: $phoneDisplay",
                          style: TextStyle(
                            fontSize: 13.5.spMin,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.spMin,
                      vertical: 5.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: widget.stats.isOnDuty
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12.spMin),
                    ),
                    child: Text(
                      widget.stats.isOnDuty ? "On Duty" : "Off Duty",
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w700,
                        color: widget.stats.isOnDuty
                            ? const Color(0xFF1D723C)
                            : const Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.spMin),
                child: Divider(
                  color: const Color(0xFFEEEEEE),
                  height: 1.spMin,
                  thickness: 1.spMin,
                ),
              ),

              // 3. Section: Duty Coverage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Duty Coverage",
                    style: TextStyle(
                      fontSize: 15.5.spMin,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B4D3E),
                    ),
                  ),
                  if (_isLoading)
                    SizedBox(
                      width: 14.spMin,
                      height: 14.spMin,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1D723C),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12.spMin),

              // Vehicle Row
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final assigned = await AssignVehicleDialog.show(
                    context,
                    collector: collector,
                    onVehicleAssigned: () => _loadHistory(),
                  );
                  if (assigned == true && mounted) {
                    _loadHistory();
                  }
                },
                child: _buildDetailRow(
                  label: "Vehicle",
                  valueWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vehicleDisplay,
                        style: TextStyle(
                          fontSize: 13.5.spMin,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B4D3E),
                        ),
                      ),
                      SizedBox(width: 6.spMin),
                      Icon(
                        Icons.edit_outlined,
                        size: 16.spMin,
                        color: const Color(0xFF1D723C),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10.spMin),

              // Assigned Bags Row
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  final assigned = await AssignBagsDialog.show(
                    context,
                    collector: collector,
                    onBagsAssigned: () => _loadHistory(),
                  );
                  if (assigned == true && mounted) {
                    _loadHistory();
                  }
                },
                child: _buildDetailRow(
                  label: "Assigned Bags",
                  valueWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLoading && _historyData == null
                            ? "Loading..."
                            : "$totalBags Bags",
                        style: TextStyle(
                          fontSize: 13.5.spMin,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B4D3E),
                        ),
                      ),
                      SizedBox(width: 6.spMin),
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 18.spMin,
                        color: const Color(0xFF1D723C),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10.spMin),

              // District Row
              _buildDetailRow(
                label: "District",
                value: districtName,
              ),

              SizedBox(height: 10.spMin),

              // Local Body Row
              _buildDetailRow(
                label: "Local Body",
                value: localBodyName,
              ),

              SizedBox(height: 10.spMin),

              // Ward Area Row
              // _buildDetailRow(
              //   label: "Ward Area",
              //   value: wardName,
              // ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.spMin),
                child: Divider(
                  color: const Color(0xFFEEEEEE),
                  height: 1.spMin,
                  thickness: 1.spMin,
                ),
              ),

              // 4. Section: Performance & Finance Metrics
              Text(
                "Performance & Finance Metrics",
                style: TextStyle(
                  fontSize: 15.5.spMin,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B4D3E),
                ),
              ),

              SizedBox(height: 12.spMin),

              // Metric Cards Row 1: Total Waste, Total Revenue, Total Pickups
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: "Total Waste",
                      value: "${totalWasteKg.toStringAsFixed(1)} Kg",
                    ),
                  ),
                  SizedBox(width: 8.spMin),
                  Expanded(
                    child: _buildMetricCard(
                      label: "Total Revenue",
                      value: "₹${totalRevenue.toInt()}",
                    ),
                  ),
                  SizedBox(width: 8.spMin),
                  Expanded(
                    child: _buildMetricCard(
                      label: "Total Pickups",
                      value: "$totalPickups",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.spMin),

              // Metric Cards Row 2: Cash Collected, Online Collected
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: "Cash Collected",
                      value: "₹${cashCollected.toStringAsFixed(1)}",
                    ),
                  ),
                  SizedBox(width: 8.spMin),
                  Expanded(
                    child: _buildMetricCard(
                      label: "Online Collected",
                      value: "₹${onlineCollected.toInt()}",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.spMin),

              // 5. Button: View A-Z Collection History
              SizedBox(
                width: double.infinity,
                height: 50.spMin,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminCollectorHistoryScreen(
                          collector: collector,
                          stats: widget.stats,
                          initialHistory: _historyData,
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
                        Icons.history_rounded,
                        color: Colors.white,
                        size: 20.spMin,
                      ),
                      SizedBox(width: 8.spMin),
                      Text(
                        "View A-Z Collection History",
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
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5.spMin,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF757575),
          ),
        ),
        valueWidget ??
            Text(
              value ?? "",
              style: TextStyle(
                fontSize: 13.5.spMin,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B4D3E),
              ),
            ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 11.spMin,
        horizontal: 6.spMin,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(
          color: const Color(0xFFE8F5E9),
          width: 1.spMin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF757575),
            ),
          ),
          SizedBox(height: 4.spMin),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.spMin,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B4D3E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
