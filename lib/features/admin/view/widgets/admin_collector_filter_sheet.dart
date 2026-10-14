import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view_model/admin_view_model.dart';
import 'package:suchigo_collector/utils/suchigo_colors.dart';

class AdminCollectorFilterSheet extends StatelessWidget {
  const AdminCollectorFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdminCollectorFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminVm = context.watch<AdminViewModel>();
    final localBodies = adminVm.availableLocalBodies;
    final wards = adminVm.availableWards;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.spMin),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20.spMin,
        12.spMin,
        20.spMin,
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

          SizedBox(height: 16.spMin),

          // 2. Header Row: Title & Reset All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Filter & Sort",
                style: TextStyle(
                  fontSize: 18.spMin,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B4D3E),
                ),
              ),
              GestureDetector(
                onTap: () => adminVm.resetFilters(),
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

          SizedBox(height: 10.spMin),
          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
          SizedBox(height: 12.spMin),

          // 3. Duty Status
          Text(
            "Duty Status",
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B4D3E),
            ),
          ),
          SizedBox(height: 10.spMin),
          Row(
            children: [
              _buildFilterChip(
                label: "All",
                isSelected: adminVm.dutyStatusFilter == "All",
                onTap: () => adminVm.setDutyStatusFilter("All"),
              ),
              SizedBox(width: 10.spMin),
              _buildFilterChip(
                label: "On Duty",
                isSelected: adminVm.dutyStatusFilter == "On Duty",
                onTap: () => adminVm.setDutyStatusFilter("On Duty"),
              ),
              SizedBox(width: 10.spMin),
              _buildFilterChip(
                label: "Off Duty",
                isSelected: adminVm.dutyStatusFilter == "Off Duty",
                onTap: () => adminVm.setDutyStatusFilter("Off Duty"),
              ),
            ],
          ),

          SizedBox(height: 18.spMin),

          // 4. Vehicle Assignment
          Text(
            "Vehicle Assignment",
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B4D3E),
            ),
          ),
          SizedBox(height: 10.spMin),
          Row(
            children: [
              _buildFilterChip(
                label: "All",
                isSelected: adminVm.vehicleFilter == "All",
                onTap: () => adminVm.setVehicleFilter("All"),
              ),
              SizedBox(width: 10.spMin),
              _buildFilterChip(
                label: "Assigned",
                isSelected: adminVm.vehicleFilter == "Assigned",
                onTap: () => adminVm.setVehicleFilter("Assigned"),
              ),
              SizedBox(width: 10.spMin),
              _buildFilterChip(
                label: "No Vehicle",
                isSelected: adminVm.vehicleFilter == "No Vehicle",
                onTap: () => adminVm.setVehicleFilter("No Vehicle"),
              ),
            ],
          ),

          SizedBox(height: 18.spMin),

          // 5. Local Body
          Text(
            "Local Body",
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B4D3E),
            ),
          ),
          SizedBox(height: 10.spMin),
          _buildDropdownContainer(
            value: adminVm.selectedLocalBody,
            items: localBodies,
            onChanged: (val) {
              if (val != null) adminVm.setSelectedLocalBody(val);
            },
          ),

          SizedBox(height: 18.spMin),

          // 6. Ward Area
          Text(
            "Ward Area",
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B4D3E),
            ),
          ),
          SizedBox(height: 10.spMin),
          _buildDropdownContainer(
            value: adminVm.selectedWard,
            items: wards,
            onChanged: (val) {
              if (val != null) adminVm.setSelectedWard(val);
            },
          ),

          SizedBox(height: 18.spMin),

          // 7. Sort By
          Text(
            "Sort By",
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B4D3E),
            ),
          ),
          SizedBox(height: 10.spMin),
          Wrap(
            spacing: 10.spMin,
            runSpacing: 10.spMin,
            children: [
              _buildFilterChip(
                label: "Default",
                isSelected: adminVm.sortBy == "Default",
                onTap: () => adminVm.setSortBy("Default"),
              ),
              _buildFilterChip(
                label: "Name (A-Z)",
                isSelected: adminVm.sortBy == "Name (A-Z)",
                onTap: () => adminVm.setSortBy("Name (A-Z)"),
              ),
              _buildFilterChip(
                label: "Quantity (High to Low)",
                isSelected: adminVm.sortBy == "Quantity (High to Low)",
                onTap: () => adminVm.setSortBy("Quantity (High to Low)"),
              ),
              _buildFilterChip(
                label: "Revenue (High to Low)",
                isSelected: adminVm.sortBy == "Revenue (High to Low)",
                onTap: () => adminVm.setSortBy("Revenue (High to Low)"),
              ),
              _buildFilterChip(
                label: "Pickups (High to Low)",
                isSelected: adminVm.sortBy == "Pickups (High to Low)",
                onTap: () => adminVm.setSortBy("Pickups (High to Low)"),
              ),
            ],
          ),

          SizedBox(height: 24.spMin),

          // 8. Apply Filters Button
          SizedBox(
            width: double.infinity,
            height: 50.spMin,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D723C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.spMin),
                ),
              ),
              child: Text(
                "Apply Filters",
                style: TextStyle(
                  fontSize: 15.spMin,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 9.spMin,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F8F1) : const Color(0xFFF9FAF9),
          borderRadius: BorderRadius.circular(12.spMin),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1D723C)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 1.3.spMin : 1.spMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_rounded,
                size: 16.spMin,
                color: const Color(0xFF1D723C),
              ),
              SizedBox(width: 5.spMin),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.spMin,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF1D723C)
                    : const Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48.spMin,
      padding: EdgeInsets.symmetric(horizontal: 16.spMin),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FCF7),
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(
          color: const Color(0xFFD4ECD7),
          width: 1.spMin,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: Color(0xFF1D723C),
            size: 28,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14.spMin),
          style: TextStyle(
            fontSize: 14.spMin,
            fontWeight: FontWeight.w600,
            color: SuchigoColors.textDark,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w600,
                      color: SuchigoColors.textDark,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
