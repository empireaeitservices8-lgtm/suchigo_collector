import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view_model/admin_view_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final adminVm = context.watch<AdminViewModel>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 12.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Metrics Card
          Container(
            padding: EdgeInsets.all(20.spMin),
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
                // Top Row: Active Nodes & Total Quantity
                Row(
                  children: [
                    // Active Nodes
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 38.spMin,
                            height: 38.spMin,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10.spMin),
                            ),
                            child: Icon(
                              Icons.people_outline_rounded,
                              color: const Color(0xFF1D723C),
                              size: 22.spMin,
                            ),
                          ),
                          SizedBox(width: 12.spMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Active Nodes",
                                  style: TextStyle(
                                    fontSize: 12.5.spMin,
                                    color: const Color(0xFF757575),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2.spMin),
                                Text(
                                  "${adminVm.onDutyCount} / ${adminVm.totalCollectorsCount}",
                                  style: TextStyle(
                                    fontSize: 18.spMin,
                                    color: SuchigoColors.textDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.spMin),

                    // Total Quantity
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 38.spMin,
                            height: 38.spMin,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10.spMin),
                            ),
                            child: Icon(
                              Icons.scale_outlined,
                              color: const Color(0xFF1D723C),
                              size: 22.spMin,
                            ),
                          ),
                          SizedBox(width: 12.spMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Quantity",
                                  style: TextStyle(
                                    fontSize: 12.5.spMin,
                                    color: const Color(0xFF757575),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2.spMin),
                                Text(
                                  "${adminVm.totalQuantityKg.toStringAsFixed(1)} Kg",
                                  style: TextStyle(
                                    fontSize: 18.spMin,
                                    color: SuchigoColors.textDark,
                                    fontWeight: FontWeight.w800,
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

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.spMin),
                  child: Divider(
                    color: const Color(0xFFF0F0F0),
                    height: 1.spMin,
                  ),
                ),

                // Bottom Row: Total Revenue & Payment Splits
                Row(
                  children: [
                    // Total Revenue
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 38.spMin,
                            height: 38.spMin,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10.spMin),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: const Color(0xFF1D723C),
                              size: 22.spMin,
                            ),
                          ),
                          SizedBox(width: 12.spMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Revenue",
                                  style: TextStyle(
                                    fontSize: 12.5.spMin,
                                    color: const Color(0xFF757575),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2.spMin),
                                Text(
                                  "₹${adminVm.totalRevenue.toInt()}",
                                  style: TextStyle(
                                    fontSize: 18.spMin,
                                    color: SuchigoColors.textDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.spMin),

                    // Cash & Online Breakdowns
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                size: 16.spMin,
                                color: const Color(0xFF9E9E9E),
                              ),
                              SizedBox(width: 6.spMin),
                              Text(
                                "Cash: ₹${adminVm.cashRevenue.toInt()}",
                                style: TextStyle(
                                  fontSize: 13.spMin,
                                  fontWeight: FontWeight.w700,
                                  color: SuchigoColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.spMin),
                          Row(
                            children: [
                              Icon(
                                Icons.credit_card_outlined,
                                size: 16.spMin,
                                color: const Color(0xFF9E9E9E),
                              ),
                              SizedBox(width: 6.spMin),
                              Text(
                                "Online: ₹${adminVm.onlineRevenue.toInt()}",
                                style: TextStyle(
                                  fontSize: 13.spMin,
                                  fontWeight: FontWeight.w700,
                                  color: SuchigoColors.textDark,
                                ),
                              ),
                            ],
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

          // 2. Operations Insights Card
          Container(
            padding: EdgeInsets.all(20.spMin),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Analytics Icon
                Row(
                  children: [
                    Container(
                      width: 32.spMin,
                      height: 32.spMin,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D723C),
                        borderRadius: BorderRadius.circular(8.spMin),
                      ),
                      child: Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.white,
                        size: 20.spMin,
                      ),
                    ),
                    SizedBox(width: 12.spMin),
                    Text(
                      "Operations Insights",
                      style: TextStyle(
                        fontSize: 16.5.spMin,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B4D3E),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.spMin),

                // Metric 1: Collector Duty Ratio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Collector Duty Ratio",
                      style: TextStyle(
                        fontSize: 13.5.spMin,
                        fontWeight: FontWeight.w700,
                        color: SuchigoColors.textDark,
                      ),
                    ),
                    Text(
                      "${adminVm.onDutyCount} / ${adminVm.totalCollectorsCount} On Duty",
                      style: TextStyle(
                        fontSize: 13.5.spMin,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D723C),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.spMin),

                // Green Progress Bar
                Container(
                  height: 8.spMin,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(4.spMin),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: adminVm.totalCollectorsCount > 0
                        ? (adminVm.onDutyCount / adminVm.totalCollectorsCount)
                            .clamp(0.0, 1.0)
                        : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D723C),
                        borderRadius: BorderRadius.circular(4.spMin),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 18.spMin),

                // Metric 2: Payment Distribution
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payment Distribution",
                      style: TextStyle(
                        fontSize: 13.5.spMin,
                        fontWeight: FontWeight.w700,
                        color: SuchigoColors.textDark,
                      ),
                    ),
                    Text(
                      "Cash 50% • Online 50%",
                      style: TextStyle(
                        fontSize: 12.5.spMin,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF616161),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.spMin),

                // Two-tone Progress Bar (50% light green, 50% dark green)
                Container(
                  height: 8.spMin,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.spMin),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: const Color(0xFF81C784),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: const Color(0xFF1D723C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.spMin),

          // 3. Quick Action Cards (Collectors List & System Setup)
          Row(
            children: [
              // Card 1: Collectors List
              Expanded(
                child: GestureDetector(
                  onTap: () => adminVm.setTab(1),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.spMin,
                      vertical: 16.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF6EC),
                      borderRadius: BorderRadius.circular(20.spMin),
                      border: Border.all(
                        color: const Color(0xFFCDE8CE),
                        width: 1.spMin,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.spMin,
                          height: 36.spMin,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.spMin),
                          ),
                          child: Icon(
                            Icons.people_alt_rounded,
                            color: const Color(0xFF1D723C),
                            size: 20.spMin,
                          ),
                        ),
                        SizedBox(width: 10.spMin),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Collectors List",
                                style: TextStyle(
                                  fontSize: 13.5.spMin,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1B4D3E),
                                ),
                              ),
                              SizedBox(height: 2.spMin),
                              Text(
                                "Manage duty & bags",
                                style: TextStyle(
                                  fontSize: 10.5.spMin,
                                  color: const Color(0xFF757575),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: const Color(0xFF1D723C),
                          size: 20.spMin,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12.spMin),

              // Card 2: System Setup
              Expanded(
                child: GestureDetector(
                  onTap: () => adminVm.setTab(2),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.spMin,
                      vertical: 16.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF6EC),
                      borderRadius: BorderRadius.circular(20.spMin),
                      border: Border.all(
                        color: const Color(0xFFCDE8CE),
                        width: 1.spMin,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.spMin,
                          height: 36.spMin,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.spMin),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: const Color(0xFF1D723C),
                            size: 20.spMin,
                          ),
                        ),
                        SizedBox(width: 10.spMin),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "System Setup",
                                style: TextStyle(
                                  fontSize: 13.5.spMin,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1B4D3E),
                                ),
                              ),
                              SizedBox(height: 2.spMin),
                              Text(
                                "Bags & waste categories",
                                style: TextStyle(
                                  fontSize: 10.5.spMin,
                                  color: const Color(0xFF757575),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: const Color(0xFF1D723C),
                          size: 20.spMin,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 90.spMin), // Bottom padding for floating nav bar
        ],
      ),
    );
  }
}
