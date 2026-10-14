import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:suchigo_collector/features/home/view/home_screen.dart';
import 'package:suchigo_collector/features/orders/view/navigation_screen.dart';
import 'package:suchigo_collector/features/orders/view/waste_configuration_screen.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/orders/view_model/order_view_model.dart';
import 'package:suchigo_collector/utils/url_launcher_helper.dart';

class UpdateStatusScreen extends StatefulWidget {
  static const routeName = '/UpdateStatusScreen';

  final LocationPickupModel order;

  const UpdateStatusScreen({
    super.key,
    required this.order,
  });

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  final ApiClient _apiClient = ApiClient();

  bool _isPending(String status) => status.toLowerCase() == 'pending';
  bool _isAccepted(String status) => status.toLowerCase() == 'accepted';
  bool _isTravellingOrBeyond(String status) {
    final s = status.toLowerCase();
    return s == 'travelling' ||
        s == 'in_transit' ||
        s == 'reached' ||
        s == 'arrived' ||
        s == 'completed';
  }

  int _currentStepIndex(String status) {
    final s = status.toLowerCase();
    if (s == 'travelling' ||
        s == 'in_transit' ||
        s == 'reached' ||
        s == 'arrived' ||
        s == 'completed') {
      return 2;
    }
    if (s == 'accepted') {
      return 1;
    }
    return 0;
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    await UrlLauncherHelper.openDialer(phoneNumber);
  }

  Future<void> _openWhatsApp(String? phoneNumber) async {
    await UrlLauncherHelper.openWhatsApp(phoneNumber);
  }

  Future<void> _updateStatus(String newStatus) async {
    final effectivePickupId = widget.order.pickupId ?? widget.order.id;
    await context.read<OrderViewModel>().updatePickupStatus(
      pickupId: effectivePickupId,
      locationId: widget.order.id,
      status: newStatus,
    );

    if (!mounted) return;

    final toastMsg = newStatus.toLowerCase() == 'travelling'
        ? "Travelling started"
        : (newStatus.toLowerCase() == 'accepted'
            ? "Order accepted successfully"
            : "Order status updated to: ${newStatus.toUpperCase()}");

    Fluttertoast.showToast(
      msg: toastMsg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF1D723C),
      textColor: Colors.white,
      fontSize: 14.0,
    );

    if (newStatus.toLowerCase() == 'travelling') {
      Navigator.pushNamed(
        context,
        WasteConfigurationScreen.routeName,
        arguments: widget.order,
      );
    }
  }

  Future<void> _handleStartNavigation() async {
    final effectivePickupId = widget.order.pickupId ?? widget.order.id;
    await context.read<OrderViewModel>().updatePickupStatus(
      pickupId: effectivePickupId,
      locationId: widget.order.id,
      status: 'travelling',
    );

    if (!mounted) return;

    final result = await Navigator.pushNamed(
      context,
      NavigationScreen.routeName,
      arguments: widget.order,
    );

    if (result == 'reached' && mounted) {
      context.read<OrderViewModel>().setLocalStatus(widget.order.id, 'reached');
    }
  }

  String _formatAddress(LocationPickupModel order) {
    final parts = [
      order.street,
      order.city,
      order.district,
      order.state,
      order.zipCode,
    ].where((e) => e != null && e.trim().isNotEmpty).toList();

    if (parts.isEmpty) {
      return order.ward ?? "No address specified";
    }
    return parts.join(", ");
  }

  void _showRescheduleBottomSheet() {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final formattedDate =
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";

            return Padding(
              padding: EdgeInsets.only(
                left: 20.spMin,
                right: 20.spMin,
                top: 24.spMin,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.spMin,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reschedule Collection",
                    style: TextStyle(
                      fontSize: 19.spMin,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF135C30),
                      letterSpacing: -0.2.spMin,
                    ),
                  ),
                  SizedBox(height: 12.spMin),
                  Text(
                    "Select a new collection date for this order:",
                    style: TextStyle(
                      fontSize: 14.spMin,
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 18.spMin),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF1D723C),
                                onPrimary: Colors.white,
                                onSurface: Color(0xFF1A1A1A),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.spMin,
                        vertical: 14.spMin,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FCF7),
                        borderRadius: BorderRadius.circular(16.spMin),
                        border: Border.all(
                          color: const Color(0xFFD7EED7),
                          width: 1.2.spMin,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: const Color(0xFF1D723C),
                            size: 22.spMin,
                          ),
                          SizedBox(width: 14.spMin),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 16.spMin,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.edit_calendar_rounded,
                            color: const Color(0xFF1D723C),
                            size: 24.spMin,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 22.spMin),
                  SizedBox(
                    width: double.infinity,
                    height: 52.spMin,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() {
                                isSubmitting = true;
                              });

                              try {
                                final effectivePickupId =
                                    widget.order.pickupId ?? widget.order.id;
                                await _apiClient.reschedulePickup(
                                  pickupId: effectivePickupId,
                                  newDate:
                                      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                                  locationId: widget.order.id,
                                );
                                await _apiClient.updatePickupStatus(
                                  pickupId: effectivePickupId,
                                  locationId: widget.order.id,
                                  status: 'rescheduled',
                                );
                              } catch (_) {}

                              if (!context.mounted) return;
                              Navigator.pop(context);

                              Fluttertoast.showToast(
                                msg: "Collection rescheduled to $formattedDate",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: const Color(0xFF1D723C),
                                textColor: Colors.white,
                              );

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                HomeScreen.routeName,
                                (route) => false,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D723C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.spMin),
                        ),
                      ),
                      child: isSubmitting
                          ? SizedBox(
                              width: 22.spMin,
                              height: 22.spMin,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Confirm Reschedule",
                              style: TextStyle(
                                fontSize: 16.spMin,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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

  void _showCancelBottomSheet() {
    String selectedReason = "Not Available";
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.spMin,
                right: 20.spMin,
                top: 24.spMin,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.spMin,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cancel Collection",
                    style: TextStyle(
                      fontSize: 19.spMin,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF135C30),
                      letterSpacing: -0.2.spMin,
                    ),
                  ),
                  SizedBox(height: 12.spMin),
                  Text(
                    "Please select a reason for cancellation:",
                    style: TextStyle(
                      fontSize: 14.spMin,
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 18.spMin),

                  // Option 1: Not Available
                  GestureDetector(
                    onTap: () {
                      setModalState(() {
                        selectedReason = "Not Available";
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.spMin,
                        vertical: 16.spMin,
                      ),
                      decoration: BoxDecoration(
                        color: selectedReason == "Not Available"
                            ? const Color(0xFFFFF8F8)
                            : const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(16.spMin),
                        border: Border.all(
                          color: selectedReason == "Not Available"
                              ? const Color(0xFFFF8A80)
                              : Colors.transparent,
                          width: 1.2.spMin,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedReason == "Not Available"
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: selectedReason == "Not Available"
                                ? const Color(0xFFE53935)
                                : const Color(0xFF757575),
                            size: 22.spMin,
                          ),
                          SizedBox(width: 14.spMin),
                          Text(
                            "Not Available",
                            style: TextStyle(
                              fontSize: 15.spMin,
                              fontWeight: FontWeight.w800,
                              color: selectedReason == "Not Available"
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12.spMin),

                  // Option 2: Already Taken
                  GestureDetector(
                    onTap: () {
                      setModalState(() {
                        selectedReason = "Already Taken";
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.spMin,
                        vertical: 16.spMin,
                      ),
                      decoration: BoxDecoration(
                        color: selectedReason == "Already Taken"
                            ? const Color(0xFFFFF8F8)
                            : const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(16.spMin),
                        border: Border.all(
                          color: selectedReason == "Already Taken"
                              ? const Color(0xFFFF8A80)
                              : Colors.transparent,
                          width: 1.2.spMin,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedReason == "Already Taken"
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: selectedReason == "Already Taken"
                                ? const Color(0xFFE53935)
                                : const Color(0xFF757575),
                            size: 22.spMin,
                          ),
                          SizedBox(width: 14.spMin),
                          Text(
                            "Already Taken",
                            style: TextStyle(
                              fontSize: 15.spMin,
                              fontWeight: FontWeight.w800,
                              color: selectedReason == "Already Taken"
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.spMin),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.spMin,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() {
                                isSubmitting = true;
                              });

                              final effectivePickupId =
                                  widget.order.pickupId ?? widget.order.id;

                              final statusString =
                                  selectedReason == "Already Taken"
                                      ? "already_taken"
                                      : "not_available";

                              try {
                                await _apiClient.updatePickupStatus(
                                  pickupId: effectivePickupId,
                                  locationId: widget.order.id,
                                  status: statusString,
                                  remarks: selectedReason,
                                  reason: selectedReason,
                                );
                              } catch (_) {}

                              if (!context.mounted) return;
                              Navigator.pop(context);

                              Fluttertoast.showToast(
                                msg: "Collection marked as $selectedReason",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: const Color(0xFFE53935),
                                textColor: Colors.white,
                              );

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                HomeScreen.routeName,
                                (route) => false,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.spMin),
                        ),
                      ),
                      child: isSubmitting
                          ? SizedBox(
                              width: 22.spMin,
                              height: 22.spMin,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 16.spMin,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final orderVm = context.watch<OrderViewModel>();
    final currentStatus = orderVm.getOrderStatus(order);
    final isUpdating = orderVm.isOrderUpdating(order.id);
    final isPending = _isPending(currentStatus);
    final isAccepted = _isAccepted(currentStatus);
    final isTravellingOrBeyond = _isTravellingOrBeyond(currentStatus);
    final currentStepIndex = _currentStepIndex(currentStatus);
    final fullAddress = _formatAddress(order);
    final itemsDesc = order.itemsDescription?.isNotEmpty == true
        ? order.itemsDescription!
        : (order.wasteType?.isNotEmpty == true
            ? order.wasteType!
            : "General household waste");

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
                        "Update Status",
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

                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.spMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card 1: Status Stepper
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.spMin,
                            vertical: 18.spMin,
                          ),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStepItem(
                                stepIndex: 0,
                                icon: Icons.schedule_rounded,
                                label: "Pending",
                                isCurrent: currentStepIndex == 0,
                                isCompleted: currentStepIndex >= 0,
                              ),
                              _buildStepConnector(isCompleted: currentStepIndex >= 1),
                              _buildStepItem(
                                stepIndex: 1,
                                icon: Icons.directions_walk_rounded,
                                label: "Travelling",
                                isCurrent: currentStepIndex == 1,
                                isCompleted: currentStepIndex >= 1,
                              ),
                              _buildStepConnector(isCompleted: currentStepIndex >= 2),
                              _buildStepItem(
                                stepIndex: 2,
                                icon: Icons.location_on_rounded,
                                label: "Reached",
                                isCurrent: currentStepIndex == 2,
                                isCompleted: currentStepIndex >= 2,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // Start Navigation Button
                        SizedBox(
                          width: double.infinity,
                          height: 48.spMin,
                          child: ElevatedButton(
                            onPressed: _handleStartNavigation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D723C),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.spMin),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.explore_outlined,
                                  color: Colors.white,
                                  size: 20.spMin,
                                ),
                                SizedBox(width: 8.spMin),
                                Text(
                                  "Start Navigation",
                                  style: TextStyle(
                                    fontSize: 15.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.2.spMin,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // Card 2: Order Information Details
                        Container(
                          padding: EdgeInsets.all(18.spMin),
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
                              // Order ID Row + Status Pill
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "ORDER ID",
                                        style: TextStyle(
                                          fontSize: 11.spMin,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF9E9E9E),
                                          letterSpacing: 0.4.spMin,
                                        ),
                                      ),
                                      SizedBox(height: 3.spMin),
                                      Text(
                                        "ORD-${order.id}",
                                        style: TextStyle(
                                          fontSize: 16.spMin,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.spMin,
                                      vertical: 5.spMin,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isAccepted
                                          ? const Color(0xFFE3F2FD)
                                          : const Color(0xFFFFF3E0),
                                      borderRadius:
                                          BorderRadius.circular(12.spMin),
                                    ),
                                    child: Text(
                                      isPending
                                          ? "Pending"
                                          : (isAccepted
                                              ? "Accepted"
                                              : currentStatus.toUpperCase()),
                                      style: TextStyle(
                                        fontSize: 11.5.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: isAccepted
                                            ? const Color(0xFF1976D2)
                                            : const Color(0xFFFB8C00),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 14.spMin),
                              Divider(
                                color: const Color(0xFFF5F5F5),
                                thickness: 1.spMin,
                                height: 1.spMin,
                              ),
                              SizedBox(height: 14.spMin),

                              // Customer Name
                              _buildInfoRow(
                                icon: Icons.person_outline_rounded,
                                label: "CUSTOMER NAME",
                                value: order.name,
                              ),
                              SizedBox(height: 16.spMin),

                              // Delivery Address
                              _buildInfoRow(
                                icon: Icons.map_outlined,
                                label: "DELIVERY ADDRESS",
                                value: fullAddress,
                              ),
                              SizedBox(height: 16.spMin),

                              // Landmark / Ward
                              _buildInfoRow(
                                icon: Icons.tag_rounded,
                                label: "LANDMARK / WARD",
                                value: WardModel.formatWardName(
                                    order.ward ?? "Neericode West"),
                              ),
                              SizedBox(height: 16.spMin),

                              // Items / Bags
                              _buildInfoRow(
                                icon: Icons.shopping_bag_outlined,
                                label: "ITEMS / BAGS",
                                value: "$itemsDesc • 0 bag(s)",
                              ),
                              SizedBox(height: 16.spMin),

                              // Phone Number
                              _buildInfoRow(
                                icon: Icons.phone_android_rounded,
                                label: "PHONE NUMBER",
                                value: order.contactNumber ?? "+917592964952",
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // WhatsApp & Call Customer Buttons Row
                        Row(
                          children: [
                            // WhatsApp Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _openWhatsApp(order.contactNumber),
                                child: Container(
                                  height: 48.spMin,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius:
                                        BorderRadius.circular(16.spMin),
                                    border: Border.all(
                                      color: const Color(0xFFC8E6C9),
                                      width: 1.spMin,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_rounded,
                                        color: const Color(0xFF1D723C),
                                        size: 18.spMin,
                                      ),
                                      SizedBox(width: 8.spMin),
                                      Text(
                                        "WhatsApp",
                                        style: TextStyle(
                                          fontSize: 14.spMin,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1D723C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 12.spMin),

                            // Call Customer Button
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _makePhoneCall(order.contactNumber),
                                child: Container(
                                  height: 48.spMin,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBF3FB),
                                    borderRadius:
                                        BorderRadius.circular(16.spMin),
                                    border: Border.all(
                                      color: const Color(0xFFBBDEFB),
                                      width: 1.spMin,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.phone_rounded,
                                        color: const Color(0xFF1976D2),
                                        size: 18.spMin,
                                      ),
                                      SizedBox(width: 8.spMin),
                                      Text(
                                        "Call Customer",
                                        style: TextStyle(
                                          fontSize: 14.spMin,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1976D2),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 14.spMin),

                        // Main Action Button:
                        // 1. Pending -> Accept Order (Blue)
                        // 2. Accepted -> Start Travelling (Orange)
                        // 3. Travelling/Beyond -> Configure Waste / Accept Order (Blue)
                        SizedBox(
                          width: double.infinity,
                          height: 50.spMin,
                          child: ElevatedButton(
                            onPressed: isUpdating
                                ? null
                                : () {
                                    if (isPending) {
                                      _updateStatus("accepted");
                                    } else if (isAccepted) {
                                      _updateStatus("travelling");
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        WasteConfigurationScreen.routeName,
                                        arguments: widget.order,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAccepted
                                  ? const Color(0xFFEF6C00) // Orange for Start Travelling
                                  : const Color(0xFF1565C0), // Blue for Accept Order
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: isAccepted
                                  ? const Color(0xFFFFCC80)
                                  : const Color(0xFF90CAF9),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.spMin),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isAccepted
                                      ? Icons.directions_run_rounded
                                      : Icons.assignment_turned_in_outlined,
                                  color: Colors.white,
                                  size: 20.spMin,
                                ),
                                SizedBox(width: 8.spMin),
                                Text(
                                  isUpdating
                                      ? "Updating..."
                                      : (isAccepted
                                          ? "Start Travelling"
                                          : (isTravellingOrBeyond
                                              ? "Waste Configuration"
                                              : "Accept Order")),
                                  style: TextStyle(
                                    fontSize: 15.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // Reschedule & Cancel Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: _showRescheduleBottomSheet,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: const Color(0xFFFFA000),
                                    size: 16.spMin,
                                  ),
                                  SizedBox(width: 6.spMin),
                                  Text(
                                    "Reschedule",
                                    style: TextStyle(
                                      fontSize: 14.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFFFA000),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _showCancelBottomSheet,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    color: const Color(0xFFE53935),
                                    size: 17.spMin,
                                  ),
                                  SizedBox(width: 6.spMin),
                                  Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 14.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFE53935),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.spMin),
                      ],
                    ),
                  ),
                ),

                // Bottom Floating Home Navigation
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.spMin),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        HomeScreen.routeName,
                        (route) => false,
                      );
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

  Widget _buildStepItem({
    required int stepIndex,
    required IconData icon,
    required String label,
    required bool isCurrent,
    required bool isCompleted,
  }) {
    final Color circleColor =
        isCompleted ? const Color(0xFF1D723C) : const Color(0xFFF0F0F0);
    final Color iconColor =
        isCompleted ? Colors.white : const Color(0xFF9E9E9E);
    final Color textColor =
        isCompleted ? const Color(0xFF1A1A1A) : const Color(0xFF9E9E9E);

    return Column(
      children: [
        Container(
          width: 44.spMin,
          height: 44.spMin,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20.spMin,
          ),
        ),
        SizedBox(height: 8.spMin),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.spMin,
            fontWeight: isCompleted ? FontWeight.w800 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Container(
      width: 38.spMin,
      height: 2.spMin,
      margin: EdgeInsets.only(bottom: 22.spMin),
      color: isCompleted ? const Color(0xFF1D723C) : const Color(0xFFE0E0E0),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.spMin),
          child: Icon(
            icon,
            size: 18.spMin,
            color: const Color(0xFF9E9E9E),
          ),
        ),
        SizedBox(width: 12.spMin),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5.spMin,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9E9E9E),
                  letterSpacing: 0.3.spMin,
                ),
              ),
              SizedBox(height: 3.spMin),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
