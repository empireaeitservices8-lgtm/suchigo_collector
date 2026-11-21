import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
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

  bool _isAccepted(String status) => status.toLowerCase() == 'accepted';
  bool _isTravelling(String status) {
    final s = status.toLowerCase();
    return s == 'travelling' || s == 'in_transit';
  }

  bool _isReachedOrBeyond(String status) {
    final s = status.toLowerCase();
    return s == 'reached' || s == 'arrived' || s == 'completed';
  }

  bool _isTravellingOrBeyond(String status) =>
      _isTravelling(status) || _isReachedOrBeyond(status);

  bool _isRescheduled(String status) {
    final s = status.toLowerCase().trim();
    return s == 'rescheduled' || s == 'reschedule';
  }

  bool _isPending(String status) {
    final s = status.toLowerCase().trim();
    return s == 'pending' ||
        (!_isAccepted(s) &&
            !_isTravellingOrBeyond(s) &&
            !_isRescheduled(s) &&
            s != 'cancelled');
  }

  int _currentStepIndex(String status) {
    final s = status.toLowerCase().trim();
    if (s == 'completed' || s == 'reached' || s == 'arrived') {
      return 2;
    }
    if (s == 'travelling' || s == 'in_transit' || s == 'accepted') {
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

  String _formatDisplayDate(String rawDate) {
    if (widget.order.pickupDateDisplay != null &&
        widget.order.pickupDateDisplay!.trim().isNotEmpty) {
      return widget.order.pickupDateDisplay!.trim();
    }
    final trimmed = rawDate.trim();
    try {
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) {
        final day = widget.order.dayOfWeek?.trim().isNotEmpty == true
            ? widget.order.dayOfWeek!.trim()
            : DateFormat('EEEE').format(parsed);
        return "$day, ${DateFormat('dd MMM yyyy').format(parsed)}";
      }
    } catch (_) {}
    return trimmed;
  }

  void _showRescheduleBottomSheet() {
    DateTime initialDate;
    if (widget.order.pickupDate != null &&
        widget.order.pickupDate!.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(widget.order.pickupDate!.trim());
      if (parsed != null) {
        initialDate = parsed;
      } else {
        initialDate = DateTime.now().add(const Duration(days: 1));
      }
    } else {
      initialDate = DateTime.now().add(const Duration(days: 1));
    }

    final firstDate = DateTime(2020, 1, 1);
    final lastDate = DateTime(2035, 12, 31);

    int targetWeekday = DateTime.friday;
    final dow = (widget.order.dayOfWeek ??
            widget.order.pickupDay ??
            widget.order.pickupDateDisplay ??
            '')
        .trim()
        .toLowerCase();
    if (dow.contains('mon')) {
      targetWeekday = DateTime.monday;
    } else if (dow.contains('tue')) {
      targetWeekday = DateTime.tuesday;
    } else if (dow.contains('wed')) {
      targetWeekday = DateTime.wednesday;
    } else if (dow.contains('thu')) {
      targetWeekday = DateTime.thursday;
    } else if (dow.contains('fri')) {
      targetWeekday = DateTime.friday;
    } else if (dow.contains('sat')) {
      targetWeekday = DateTime.saturday;
    } else if (dow.contains('sun')) {
      targetWeekday = DateTime.sunday;
    } else {
      targetWeekday = initialDate.weekday;
    }

    // Ensure initialDate matches the given day from API
    if (initialDate.weekday != targetWeekday) {
      final diff = (targetWeekday - initialDate.weekday + 7) % 7;
      initialDate = initialDate.add(Duration(days: diff == 0 ? 7 : diff));
    }

    DateTime selectedDate = initialDate;
    bool isSubmitting = false;

    // Enable ONLY the given day of the week (e.g. Friday only) in calendar
    bool isDaySelectable(DateTime date) {
      return date.weekday == targetWeekday;
    }

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
            final dayOfWeekStr = (selectedDate.year == initialDate.year &&
                    selectedDate.month == initialDate.month &&
                    selectedDate.day == initialDate.day &&
                    widget.order.dayOfWeek?.trim().isNotEmpty == true)
                ? widget.order.dayOfWeek!.trim()
                : DateFormat('EEEE').format(selectedDate);

            final formattedDate =
                DateFormat('dd MMM yyyy').format(selectedDate);
            final rawApiDateStr =
                "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 20.spMin,
                  right: 20.spMin,
                  top: 14.spMin,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20.spMin,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top drag pill
                    Center(
                      child: Container(
                        width: 44.spMin,
                        height: 4.5.spMin,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(2.5.spMin),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.spMin),

                    // Header Row: Icon + Title + Close Button
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.spMin),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10.spMin),
                          ),
                          child: Icon(
                            Icons.event_repeat_rounded,
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
                                "Reschedule Collection",
                                style: TextStyle(
                                  fontSize: 18.spMin,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF135C30),
                                  letterSpacing: -0.2.spMin,
                                ),
                              ),
                              SizedBox(height: 2.spMin),
                              Text(
                                "Select a new collection date for this order",
                                style: TextStyle(
                                  fontSize: 12.5.spMin,
                                  color: const Color(0xFF757575),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.all(4.spMin),
                            child: Icon(
                              Icons.close_rounded,
                              size: 22.spMin,
                              color: const Color(0xFF9E9E9E),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 14.spMin),

                    // Informative note about enabled collection day

                    // Interactive Calendar Picker
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.spMin),
                        border: Border.all(
                          color: const Color(0xFFE8F5E9),
                          width: 1.spMin,
                        ),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF1D723C),
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Color(0xFF1A1A1A),
                          ),
                        ),
                        child: CalendarDatePicker(
                          initialDate: selectedDate,
                          firstDate: firstDate,
                          lastDate: lastDate,
                          currentDate: DateTime.now(),
                          selectableDayPredicate: isDaySelectable,
                          onDateChanged: (newDate) {
                            setModalState(() {
                              selectedDate = newDate;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 18.spMin),

                    // Confirm Reschedule Button
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

                                try {
                                  final effectivePickupId =
                                      widget.order.pickupId ?? widget.order.id;
                                  await _apiClient.reschedulePickup(
                                    pickupId: effectivePickupId,
                                    newDate: rawApiDateStr,
                                    locationId: widget.order.id,
                                  );
                                  await _apiClient.updatePickupStatus(
                                    pickupId: effectivePickupId,
                                    locationId: widget.order.id,
                                    status: 'rescheduled',
                                  );
                                  if (context.mounted) {
                                    context
                                        .read<OrderViewModel>()
                                        .setLocalStatus(
                                            widget.order.id, 'rescheduled');
                                  }
                                } catch (_) {}

                                if (!context.mounted) return;
                                Navigator.pop(context);

                                Fluttertoast.showToast(
                                  msg:
                                      "Rescheduled to $dayOfWeekStr, $formattedDate",
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
                                  fontSize: 15.5.spMin,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
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
    final isRescheduled = _isRescheduled(currentStatus);
    final isPending = _isPending(currentStatus);
    final isAccepted = _isAccepted(currentStatus);
    final isTravelling = _isTravelling(currentStatus);
    final isReachedOrBeyond = _isReachedOrBeyond(currentStatus);
    final isTravellingOrBeyond = _isTravellingOrBeyond(currentStatus);
    final isCompleted = currentStatus.toLowerCase().trim() == 'completed';
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
                                icon: isRescheduled
                                    ? Icons.event_repeat_rounded
                                    : Icons.schedule_rounded,
                                label:
                                    isRescheduled ? "Rescheduled" : "Pending",
                                isCurrent: currentStepIndex == 0,
                                isCompleted: currentStepIndex >= 0,
                                customColor: isRescheduled
                                    ? const Color(0xFFE65100)
                                    : null,
                                customBgColor: isRescheduled
                                    ? const Color(0xFFFFF3E0)
                                    : null,
                              ),
                              _buildStepConnector(
                                  isCompleted: currentStepIndex >= 1),
                              _buildStepItem(
                                stepIndex: 1,
                                icon: Icons.directions_walk_rounded,
                                label: "Travelling",
                                isCurrent: currentStepIndex == 1,
                                isCompleted: currentStepIndex >= 1,
                              ),
                              _buildStepConnector(
                                  isCompleted: currentStepIndex >= 2),
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

                        // Start Navigation Button (Enabled ONLY when status is 'accepted' or 'travelling' and not completed)
                        Builder(
                          builder: (context) {
                            final bool isAcceptOrTravelling =
                                (isAccepted || isTravelling) && !isCompleted;
                            final bool isNavigationEnabled =
                                isAcceptOrTravelling && !isUpdating;

                            return SizedBox(
                              width: double.infinity,
                              height: 48.spMin,
                              child: ElevatedButton(
                                onPressed: isUpdating
                                    ? null
                                    : (isNavigationEnabled
                                        ? _handleStartNavigation
                                        : () {
                                            final msg = isCompleted
                                                ? "Order is already completed"
                                                : (isRescheduled
                                                    ? "Order is rescheduled. Please accept to start navigation"
                                                    : (isPending
                                                        ? "Please accept the order to start navigation"
                                                        : "Navigation is disabled (destination already reached)"));
                                            Fluttertoast.showToast(
                                              msg: msg,
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor:
                                                  const Color(0xFF424242),
                                              textColor: Colors.white,
                                            );
                                          }),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isNavigationEnabled
                                      ? const Color(0xFF1D723C)
                                      : const Color(0xFFE0E0E0),
                                  foregroundColor: isNavigationEnabled
                                      ? Colors.white
                                      : const Color(0xFF9E9E9E),
                                  disabledBackgroundColor:
                                      const Color(0xFFE0E0E0),
                                  disabledForegroundColor:
                                      const Color(0xFF9E9E9E),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14.spMin),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.explore_outlined,
                                      color: isNavigationEnabled
                                          ? Colors.white
                                          : const Color(0xFF9E9E9E),
                                      size: 20.spMin,
                                    ),
                                    SizedBox(width: 8.spMin),
                                    Text(
                                      "Start Navigation",
                                      style: TextStyle(
                                        fontSize: 15.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: isNavigationEnabled
                                            ? Colors.white
                                            : const Color(0xFF9E9E9E),
                                        letterSpacing: 0.2.spMin,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
                                      color: isRescheduled
                                          ? const Color(0xFFFFF3E0)
                                          : (isAccepted
                                              ? const Color(0xFFE3F2FD)
                                              : (isPending
                                                  ? const Color(0xFFFFF8E1)
                                                  : const Color(0xFFE8F5E9))),
                                      borderRadius:
                                          BorderRadius.circular(12.spMin),
                                    ),
                                    child: Text(
                                      isRescheduled
                                          ? "Rescheduled"
                                          : (isPending
                                              ? "Pending"
                                              : (isAccepted
                                                  ? "Accepted"
                                                  : currentStatus
                                                      .toUpperCase())),
                                      style: TextStyle(
                                        fontSize: 11.5.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: isRescheduled
                                            ? const Color(0xFFE65100)
                                            : (isAccepted
                                                ? const Color(0xFF1976D2)
                                                : (isPending
                                                    ? const Color(0xFFFB8C00)
                                                    : const Color(0xFF1D723C))),
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
                                value: (order.ward != null &&
                                        order.ward!.trim().isNotEmpty)
                                    ? WardModel.formatWardName(order.ward!)
                                    : "",
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
                                value: order.contactNumber ?? "",
                              ),
                              if (order.pickupDate != null &&
                                  order.pickupDate!.trim().isNotEmpty) ...[
                                SizedBox(height: 16.spMin),
                                _buildInfoRow(
                                  icon: isRescheduled
                                      ? Icons.event_repeat_rounded
                                      : Icons.calendar_today_rounded,
                                  label: isRescheduled
                                      ? "RESCHEDULED DATE"
                                      : "PICKUP DATE",
                                  value: _formatDisplayDate(order.pickupDate!),
                                ),
                              ],
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
                                onTap: () => _openWhatsApp(order.contactNumber),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                            onPressed: isUpdating || isCompleted
                                ? null
                                : () {
                                    if (isPending || isRescheduled) {
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
                              backgroundColor: isCompleted
                                  ? const Color(0xFF1D723C)
                                  : (isAccepted
                                      ? const Color(
                                          0xFFEF6C00) // Orange for Start Travelling
                                      : (isTravellingOrBeyond
                                          ? const Color(0xFF1D723C)
                                          : const Color(
                                              0xFF1565C0))), // Blue for Accept Order
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: isCompleted
                                  ? const Color(0xFF81C784)
                                  : (isAccepted
                                      ? const Color(0xFFFFCC80)
                                      : const Color(0xFF90CAF9)),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.spMin),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isCompleted
                                      ? Icons.check_circle_rounded
                                      : (isAccepted
                                          ? Icons.directions_run_rounded
                                          : (isTravellingOrBeyond
                                              ? Icons.delete_outline_rounded
                                              : Icons
                                                  .assignment_turned_in_outlined)),
                                  color: Colors.white,
                                  size: 20.spMin,
                                ),
                                SizedBox(width: 8.spMin),
                                Text(
                                  isUpdating
                                      ? "Updating..."
                                      : (isCompleted
                                          ? "Order Completed"
                                          : (isAccepted
                                              ? "Start Travelling"
                                              : (isTravellingOrBeyond
                                                  ? "Waste Configuration"
                                                  : "Accept Order"))),
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

                        if (!isCompleted) ...[
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
                              // GestureDetector(
                              //   onTap: _showCancelBottomSheet,
                              //   child: Row(
                              //     children: [
                              //       Icon(
                              //         Icons.cancel_outlined,
                              //         color: const Color(0xFFE53935),
                              //         size: 17.spMin,
                              //       ),
                              //       SizedBox(width: 6.spMin),
                              //       Text(
                              //         "Cancel",
                              //         style: TextStyle(
                              //           fontSize: 14.spMin,
                              //           fontWeight: FontWeight.w700,
                              //           color: const Color(0xFFE53935),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ],

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
    Color? customColor,
    Color? customBgColor,
  }) {
    final Color circleColor = customBgColor ??
        (isCompleted ? const Color(0xFF1D723C) : const Color(0xFFF0F0F0));
    final Color iconColor =
        customColor ?? (isCompleted ? Colors.white : const Color(0xFF9E9E9E));
    final Color textColor = customColor ??
        (isCompleted ? const Color(0xFF1A1A1A) : const Color(0xFF9E9E9E));

    return Column(
      children: [
        Container(
          width: 44.spMin,
          height: 44.spMin,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: customColor != null
                ? Border.all(color: customColor, width: 1.5.spMin)
                : null,
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
