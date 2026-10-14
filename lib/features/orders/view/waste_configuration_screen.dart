import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/home/view/home_screen.dart';
import 'package:suchigo_collector/features/orders/view_model/waste_configuration_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';

class WasteConfigurationScreen extends StatefulWidget {
  static const routeName = '/WasteConfigurationScreen';

  final LocationPickupModel order;

  const WasteConfigurationScreen({
    super.key,
    required this.order,
  });

  @override
  State<WasteConfigurationScreen> createState() =>
      _WasteConfigurationScreenState();
}

class _WasteConfigurationScreenState extends State<WasteConfigurationScreen> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WasteConfigurationViewModel>().initForOrder(widget.order);
      }
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _showAddBagBottomSheet() {
    final wasteVm = context.read<WasteConfigurationViewModel>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.spMin, vertical: 24.spMin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Bag Size to Add",
                style: TextStyle(
                  fontSize: 18.spMin,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF135C30),
                  letterSpacing: -0.2.spMin,
                ),
              ),
              SizedBox(height: 18.spMin),
              ...wasteVm.availableBags.map((bag) {
                final name = bag['name'] as String;
                final price = bag['price'] as double;
                return Container(
                  margin: EdgeInsets.only(bottom: 12.spMin),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.spMin,
                    vertical: 14.spMin,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FCF7),
                    borderRadius: BorderRadius.circular(16.spMin),
                    border: Border.all(
                      color: const Color(0xFFD7EED7),
                      width: 1.spMin,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: const Color(0xFF1D723C),
                        size: 24.spMin,
                      ),
                      SizedBox(width: 16.spMin),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 15.spMin,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1A1A),
                                letterSpacing: 0.3.spMin,
                              ),
                            ),
                            SizedBox(height: 3.spMin),
                            Text(
                              "Price: ₹${price.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 12.spMin,
                                color: const Color(0xFF757575),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<WasteConfigurationViewModel>()
                              .addBag(name);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D723C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.spMin),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 22.spMin,
                            vertical: 10.spMin,
                          ),
                        ),
                        child: Text(
                          "ADD",
                          style: TextStyle(
                            fontSize: 13.5.spMin,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5.spMin,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 10.spMin),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.spMin),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Uint8List? _decodeBase64Qr(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final clean = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(clean.trim());
    } catch (e) {
      debugPrint('[WasteConfig] Error decoding base64 QR: $e');
      return null;
    }
  }

  void _showPaymentBottomSheet() {
    final effectivePickupId = widget.order.pickupId ?? widget.order.id;
    context.read<WasteConfigurationViewModel>().fetchQrCode(effectivePickupId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      builder: (ctx) {
        return Consumer<WasteConfigurationViewModel>(
          builder: (context, wasteVm, _) {
            final qrBytes = _decodeBase64Qr(wasteVm.qrCodeBase64);

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
                    "Select Payment Mode",
                    style: TextStyle(
                      fontSize: 18.5.spMin,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF135C30),
                      letterSpacing: -0.2.spMin,
                    ),
                  ),
                  SizedBox(height: 18.spMin),

                  // Radio Selector: Cash | Online Payment
                  Row(
                    children: [
                      // Cash Radio
                      GestureDetector(
                        onTap: () {
                          wasteVm.setPaymentMode('cash');
                        },
                        child: Row(
                          children: [
                            Icon(
                              wasteVm.paymentMode == 'cash'
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: wasteVm.paymentMode == 'cash'
                                  ? const Color(0xFF1D723C)
                                  : const Color(0xFF757575),
                              size: 22.spMin,
                            ),
                            SizedBox(width: 8.spMin),
                            Text(
                              "Cash",
                              style: TextStyle(
                                fontSize: 15.spMin,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 28.spMin),

                      // Online Payment Radio
                      GestureDetector(
                        onTap: () {
                          wasteVm.setPaymentMode('online');
                        },
                        child: Row(
                          children: [
                            Icon(
                              wasteVm.paymentMode == 'online'
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: wasteVm.paymentMode == 'online'
                                  ? const Color(0xFF1D723C)
                                  : const Color(0xFF757575),
                              size: 22.spMin,
                            ),
                            SizedBox(width: 8.spMin),
                            Text(
                              "Online Payment",
                              style: TextStyle(
                                fontSize: 15.spMin,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.spMin),

                  // QR Code Card or Cash Info Card
                  if (wasteVm.paymentMode == 'online')
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 240.spMin,
                            height: 240.spMin,
                            padding: EdgeInsets.all(16.spMin),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.spMin),
                              border: Border.all(
                                color: const Color(0xFFE8F5E9),
                                width: 1.5.spMin,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 12.spMin,
                                  offset: Offset(0, 4.spMin),
                                ),
                              ],
                            ),
                            child: Center(
                              child: wasteVm.isLoadingQr
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircularProgressIndicator(
                                          color: Color(0xFF1D723C),
                                        ),
                                        SizedBox(height: 12.spMin),
                                        Text(
                                          "Generating QR...",
                                          style: TextStyle(
                                            fontSize: 12.spMin,
                                            color: const Color(0xFF757575),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : (qrBytes != null
                                      ? Image.memory(
                                          qrBytes,
                                          width: 200.spMin,
                                          height: 200.spMin,
                                          fit: BoxFit.contain,
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.qr_code_2_rounded,
                                              size: 130.spMin,
                                              color: const Color(0xFF1D723C),
                                            ),
                                            Text(
                                              "₹${wasteVm.finalTotal.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontSize: 14.spMin,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF135C30),
                                              ),
                                            ),
                                          ],
                                        )),
                            ),
                          ),
                          SizedBox(height: 14.spMin),
                          Text(
                            "SCAN QR CODE TO PAY INSTANTLY",
                            style: TextStyle(
                              fontSize: 12.spMin,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1D723C),
                              letterSpacing: 0.6.spMin,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.spMin,
                        vertical: 20.spMin,
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
                          Container(
                            padding: EdgeInsets.all(12.spMin),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.payments_rounded,
                              color: const Color(0xFF1D723C),
                              size: 26.spMin,
                            ),
                          ),
                          SizedBox(width: 16.spMin),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cash Collection",
                                  style: TextStyle(
                                    fontSize: 14.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                                SizedBox(height: 4.spMin),
                                Text(
                                  "Collect ₹${wasteVm.finalTotal.toStringAsFixed(2)} in Cash",
                                  style: TextStyle(
                                    fontSize: 17.spMin,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF135C30),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 24.spMin),

                  // Bottom Action Buttons: Cancel | Verify Payment / Confirm Payment
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48.spMin,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: const Color(0xFFE0E0E0),
                                width: 1.2.spMin,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.spMin),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 14.5.spMin,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.spMin),
                      Expanded(
                        child: SizedBox(
                          height: 48.spMin,
                          child: ElevatedButton(
                            onPressed: wasteVm.isProcessingPayment
                                ? null
                                : () async {
                                    final effectivePickupId =
                                        widget.order.pickupId ??
                                            widget.order.id;

                                    final success = await wasteVm.processPayment(
                                      pickupId: effectivePickupId,
                                      locationId: widget.order.id,
                                      localBody: widget.order.localBody ??
                                          widget.order.ward,
                                      ward: widget.order.ward,
                                      userName: widget.order.name,
                                    );

                                    if (!context.mounted) return;
                                    Navigator.pop(context); // Close sheet

                                    if (success) {
                                      _showSuccessDialog(wasteVm.finalTotal);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D723C),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.spMin),
                              ),
                            ),
                            child: wasteVm.isProcessingPayment
                                ? SizedBox(
                                    width: 20.spMin,
                                    height: 20.spMin,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Verify Payment",
                                    style: TextStyle(
                                      fontSize: 14.5.spMin,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog([double? totalAmount]) {
    final finalTotal = totalAmount ??
        (mounted
            ? context.read<WasteConfigurationViewModel>().finalTotal
            : 0.0);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.spMin),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: const Color(0xFF1D723C), size: 28.spMin),
            SizedBox(width: 10.spMin),
            Text(
              "Collection Complete",
              style: TextStyle(
                fontSize: 18.spMin,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF135C30),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Amount: ₹${finalTotal.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 6.spMin),
            Text(
              "Bill has been generated and the pickup status is marked as completed.",
              style: TextStyle(
                fontSize: 13.spMin,
                color: const Color(0xFF616161),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomeScreen.routeName,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D723C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.spMin),
              ),
            ),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleProceedToPayment() async {
    final wasteVm = context.read<WasteConfigurationViewModel>();
    if (wasteVm.enteredWeight <= 0 && wasteVm.bagQuantities.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter weight or add bag size to continue",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
      );
      return;
    }

    _showPaymentBottomSheet();
  }

  @override
  Widget build(BuildContext context) {
    final wasteVm = context.watch<WasteConfigurationViewModel>();
    final locationName = widget.order.ward?.isNotEmpty == true
        ? widget.order.ward!
        : (widget.order.localBody?.isNotEmpty == true
            ? widget.order.localBody!
            : "Alangad Panchayat");

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

                // Top Header: Back Button + Title + Red Exit Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.spMin),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                            "Waste Configuration",
                            style: TextStyle(
                              fontSize: 20.spMin,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF135C30),
                              letterSpacing: -0.3.spMin,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38.spMin,
                          height: 38.spMin,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFEBEE),
                          ),
                          child: Icon(
                            Icons.exit_to_app_rounded,
                            color: const Color(0xFFE53935),
                            size: 20.spMin,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (wasteVm.isLoading)
                  LinearProgressIndicator(
                    minHeight: 2.spMin,
                    color: const Color(0xFF1D723C),
                    backgroundColor: Colors.transparent,
                  )
                else
                  SizedBox(height: 2.spMin),

                SizedBox(height: 12.spMin),

                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.spMin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Residential / Commercial Switcher
                        Container(
                          padding: EdgeInsets.all(4.spMin),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.spMin),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                              width: 1.spMin,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    wasteVm.selectTab(0);
                                  },
                                  child: Container(
                                    height: 42.spMin,
                                    decoration: BoxDecoration(
                                      color: wasteVm.selectedTab == 0
                                          ? const Color(0xFF1D723C)
                                          : Colors.transparent,
                                      borderRadius:
                                          BorderRadius.circular(12.spMin),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Residential",
                                      style: TextStyle(
                                        fontSize: 14.spMin,
                                        fontWeight: FontWeight.w700,
                                        color: wasteVm.selectedTab == 0
                                            ? Colors.white
                                            : const Color(0xFF616161),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    wasteVm.selectTab(1);
                                  },
                                  child: Container(
                                    height: 42.spMin,
                                    decoration: BoxDecoration(
                                      color: wasteVm.selectedTab == 1
                                          ? const Color(0xFF1D723C)
                                          : Colors.transparent,
                                      borderRadius:
                                          BorderRadius.circular(12.spMin),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Commercial",
                                      style: TextStyle(
                                        fontSize: 14.spMin,
                                        fontWeight: FontWeight.w700,
                                        color: wasteVm.selectedTab == 1
                                            ? Colors.white
                                            : const Color(0xFF616161),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // 2. Add Bag Size Card
                        GestureDetector(
                          onTap: _showAddBagBottomSheet,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.spMin,
                              vertical: 16.spMin,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.spMin),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10.spMin,
                                  offset: Offset(0, 3.spMin),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  color: const Color(0xFF1D723C),
                                  size: 22.spMin,
                                ),
                                SizedBox(width: 14.spMin),
                                Text(
                                  "Add Bag Size",
                                  style: TextStyle(
                                    fontSize: 15.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: const Color(0xFF1D723C),
                                  size: 24.spMin,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // 3. Adjust Quantities Card
                        Container(
                          padding: EdgeInsets.all(18.spMin),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.spMin),
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
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.spMin,
                                      vertical: 2.spMin,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius:
                                          BorderRadius.circular(6.spMin),
                                    ),
                                    child: Text(
                                      "123",
                                      style: TextStyle(
                                        fontSize: 11.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1D723C),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.spMin),
                                  Text(
                                    "Adjust Quantities",
                                    style: TextStyle(
                                      fontSize: 15.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14.spMin),
                              if (wasteVm.bagQuantities.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.spMin,
                                    ),
                                    child: Text(
                                      "Select a bag size above first to adjust quantity",
                                      style: TextStyle(
                                        fontSize: 13.spMin,
                                        color: const Color(0xFF9E9E9E),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...wasteVm.bagQuantities.entries.map((entry) {
                                  final displayName = entry.key.toUpperCase().contains('BAG')
                                      ? entry.key
                                      : "${entry.key} Bag";
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.spMin),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            displayName,
                                            style: TextStyle(
                                              fontSize: 15.spMin,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF1A1A1A),
                                              letterSpacing: 0.2.spMin,
                                            ),
                                          ),
                                        ),
                                        // Minus Button (Circle)
                                        GestureDetector(
                                          onTap: () {
                                            wasteVm.decreaseBag(entry.key);
                                          },
                                          child: Container(
                                            width: 36.spMin,
                                            height: 36.spMin,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE8F5E9),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.remove_rounded,
                                              size: 18.spMin,
                                              color: const Color(0xFF1D723C),
                                            ),
                                          ),
                                        ),
                                        // Quantity Text
                                        Container(
                                          width: 44.spMin,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "${entry.value}",
                                            style: TextStyle(
                                              fontSize: 16.spMin,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF1A1A1A),
                                            ),
                                          ),
                                        ),
                                        // Plus Button (Circle)
                                        GestureDetector(
                                          onTap: () {
                                            wasteVm.addBag(entry.key);
                                          },
                                          child: Container(
                                            width: 36.spMin,
                                            height: 36.spMin,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE8F5E9),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.add_rounded,
                                              size: 18.spMin,
                                              color: const Color(0xFF1D723C),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12.spMin),
                                        // Delete / Trash Button (Light Red Circle)
                                        GestureDetector(
                                          onTap: () {
                                            wasteVm.removeBag(entry.key);
                                          },
                                          child: Container(
                                            width: 36.spMin,
                                            height: 36.spMin,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFEBEE),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.delete_outline_rounded,
                                              size: 20.spMin,
                                              color: const Color(0xFFE53935),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // 4. Select Waste Type Card
                        Container(
                          padding: EdgeInsets.all(18.spMin),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.spMin),
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
                                children: [
                                  Icon(
                                    Icons.recycling_rounded,
                                    color: const Color(0xFF1D723C),
                                    size: 22.spMin,
                                  ),
                                  SizedBox(width: 10.spMin),
                                  Text(
                                    "Select Waste Type",
                                    style: TextStyle(
                                      fontSize: 15.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14.spMin),

                              // Grid of waste types
                              Wrap(
                                spacing: 10.spMin,
                                runSpacing: 10.spMin,
                                children: wasteVm.wasteTypes.map((type) {
                                  final name = type['name'] as String;
                                  final icon = type['icon'] as IconData;
                                  final isSelected =
                                      wasteVm.selectedWasteTypes.contains(name);

                                  final itemWidth =
                                      (MediaQuery.of(context).size.width -
                                              32.spMin -
                                              36.spMin -
                                              10.spMin) /
                                          2;

                                  return GestureDetector(
                                    onTap: () {
                                      wasteVm.toggleWasteType(name);
                                    },
                                    child: Container(
                                      width: itemWidth,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.spMin,
                                        vertical: 12.spMin,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF1D723C)
                                            : const Color(0xFFF7FCF7),
                                        borderRadius:
                                            BorderRadius.circular(16.spMin),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF1D723C)
                                              : const Color(0xFFE8F5E9),
                                          width: isSelected ? 1.5.spMin : 1.spMin,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(6.spMin),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white.withValues(alpha: 0.2)
                                                  : const Color(0xFFE8F5E9),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              icon,
                                              size: 16.spMin,
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF1D723C),
                                            ),
                                          ),
                                          SizedBox(width: 8.spMin),
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 12.spMin,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xFF135C30),
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                          if (isSelected) ...[
                                            SizedBox(width: 4.spMin),
                                            Icon(
                                              Icons.check_circle_rounded,
                                              size: 16.spMin,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // 5. Disposal Location Card
                        Container(
                          padding: EdgeInsets.all(18.spMin),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.spMin),
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
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: const Color(0xFF1D723C),
                                    size: 20.spMin,
                                  ),
                                  SizedBox(width: 10.spMin),
                                  Text(
                                    "Disposal Location",
                                    style: TextStyle(
                                      fontSize: 15.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.spMin),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.spMin,
                                  vertical: 14.spMin,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FCF7),
                                  borderRadius: BorderRadius.circular(14.spMin),
                                  border: Border.all(
                                    color: const Color(0xFFE8F5E9),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      locationName,
                                      style: TextStyle(
                                        fontSize: 14.5.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    Text(
                                      "₹${wasteVm.ratePerKg.toStringAsFixed(2)}/kg",
                                      style: TextStyle(
                                        fontSize: 14.5.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1D723C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // 6. Weighed Weight (Manual) Card
                        Container(
                          padding: EdgeInsets.all(18.spMin),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.spMin),
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
                                children: [
                                  Icon(
                                    Icons.scale_rounded,
                                    color: const Color(0xFF1D723C),
                                    size: 20.spMin,
                                  ),
                                  SizedBox(width: 10.spMin),
                                  Text(
                                    "Weighed Weight (Manual)",
                                    style: TextStyle(
                                      fontSize: 15.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.spMin),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.spMin,
                                  vertical: 4.spMin,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14.spMin),
                                  border: Border.all(
                                    color: const Color(0xFF1D723C),
                                    width: 1.5.spMin,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _weightController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                                decimal: true),
                                        style: TextStyle(
                                          fontSize: 16.spMin,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                        onChanged: (val) {
                                          wasteVm.setWeight(
                                              double.tryParse(val.trim()) ?? 0.0);
                                        },
                                        decoration: InputDecoration(
                                          filled: false,
                                          fillColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hintText: "Enter weight in KGs",
                                          hintStyle: TextStyle(
                                            fontSize: 14.spMin,
                                            color: const Color(0xFF9E9E9E),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.spMin,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "kg",
                                      style: TextStyle(
                                        fontSize: 15.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1D723C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // 7. User Wallet Balance Card
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.spMin,
                            vertical: 14.spMin,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.spMin),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10.spMin,
                                offset: Offset(0, 3.spMin),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.spMin),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8F5E9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: const Color(0xFF1D723C),
                                  size: 22.spMin,
                                ),
                              ),
                              SizedBox(width: 14.spMin),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "User Wallet Balance",
                                    style: TextStyle(
                                      fontSize: 14.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  SizedBox(height: 2.spMin),
                                  Text(
                                    "₹${wasteVm.walletBalance.toStringAsFixed(2)} available",
                                    style: TextStyle(
                                      fontSize: 12.spMin,
                                      color: const Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                "Redeem",
                                style: TextStyle(
                                  fontSize: 13.5.spMin,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1D723C),
                                ),
                              ),
                              SizedBox(width: 10.spMin),
                              // Custom Animated Toggle Switch
                              GestureDetector(
                                onTap: () {
                                  wasteVm.toggleRedeemWallet();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  width: 48.spMin,
                                  height: 26.spMin,
                                  padding: EdgeInsets.all(2.5.spMin),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(20.spMin),
                                    color: wasteVm.redeemWallet
                                        ? const Color(0xFF1D723C)
                                        : const Color(0xFFD4D4D4),
                                  ),
                                  alignment: wasteVm.redeemWallet
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 21.spMin,
                                    height: 21.spMin,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.15),
                                          blurRadius: 4.spMin,
                                          offset: Offset(0, 1.spMin),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 14.spMin),

                        // 8. Item / Service Summary Table Card
                        Container(
                          padding: EdgeInsets.all(18.spMin),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.spMin),
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
                              // Table Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      "ITEM / SERVICE",
                                      style: TextStyle(
                                        fontSize: 10.5.spMin,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF9E9E9E),
                                        letterSpacing: 0.4.spMin,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      "QTY / RATE",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10.5.spMin,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF9E9E9E),
                                        letterSpacing: 0.4.spMin,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "PRICE (₹)",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 10.5.spMin,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF9E9E9E),
                                        letterSpacing: 0.4.spMin,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.spMin),
                              Divider(
                                color: const Color(0xFFF5F5F5),
                                thickness: 1.spMin,
                                height: 1.spMin,
                              ),
                              SizedBox(height: 12.spMin),

                              if (wasteVm.enteredWeight <= 0 &&
                                  wasteVm.bagQuantities.isEmpty &&
                                  wasteVm.selectedWasteTypes.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.spMin),
                                  child: Center(
                                    child: Text(
                                      "No items selected yet",
                                      style: TextStyle(
                                        fontSize: 13.spMin,
                                        color: const Color(0xFF9E9E9E),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                              else ...[
                                ...wasteVm.bagQuantities.entries.map((e) {
                                  final p = wasteVm.bagPrices[e.key] ??
                                      wasteVm.bagPrices[e.key.toUpperCase()] ??
                                      (e.key.toUpperCase().contains('MEDIUM')
                                          ? 7.0
                                          : (e.key.toUpperCase().contains('SMALL')
                                              ? 5.0
                                              : 10.0));
                                  final displayName = e.key.toUpperCase().contains('BAG')
                                      ? e.key
                                      : "${e.key} Bag";
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 10.spMin),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            displayName,
                                            style: TextStyle(
                                              fontSize: 14.spMin,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF1A1A1A),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "${e.value} bag(s)",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13.5.spMin,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF1A1A1A),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "₹${(e.value * p).toStringAsFixed(2)}",
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              fontSize: 14.spMin,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF1D723C),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                if (wasteVm.enteredWeight > 0)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 10.spMin),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            locationName.contains('Panchayat')
                                                ? "${locationName.replaceAll('Panchayat', '').trim()} Rate"
                                                : "$locationName Rate",
                                            style: TextStyle(
                                              fontSize: 14.spMin,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF1A1A1A),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "${wasteVm.enteredWeight.toStringAsFixed(wasteVm.enteredWeight.truncateToDouble() == wasteVm.enteredWeight ? 0 : 1)} kg @ ₹${wasteVm.ratePerKg.toStringAsFixed(2)}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13.spMin,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF1A1A1A),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "₹${(wasteVm.enteredWeight * wasteVm.ratePerKg).toStringAsFixed(2)}",
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              fontSize: 14.spMin,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF1D723C),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (wasteVm.redeemWallet && wasteVm.discount > 0) ...[
                                  Divider(
                                    color: const Color(0xFFF5F5F5),
                                    thickness: 1.spMin,
                                    height: 1.spMin,
                                  ),
                                  SizedBox(height: 10.spMin),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 10.spMin),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            "Wallet Redeemed",
                                            style: TextStyle(
                                              fontSize: 14.spMin,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFFE57373),
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                          flex: 2,
                                          child: SizedBox(),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "-₹${wasteVm.discount.toStringAsFixed(2)}",
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              fontSize: 14.spMin,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFFE57373),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                Divider(
                                  color: const Color(0xFFF5F5F5),
                                  thickness: 1.spMin,
                                  height: 1.spMin,
                                ),
                                SizedBox(height: 10.spMin),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "TOTAL PRICE",
                                      style: TextStyle(
                                        fontSize: 14.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1A1A1A),
                                        letterSpacing: 0.2.spMin,
                                      ),
                                    ),
                                    Text(
                                      "₹${wasteVm.finalTotal.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 16.5.spMin,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1D723C),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: 16.spMin),

                        // 9. Proceed to Payment Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.spMin,
                          child: ElevatedButton(
                            onPressed: _handleProceedToPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D723C),
                              foregroundColor: Colors.white,
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
                                  Icons.credit_card_rounded,
                                  color: Colors.white,
                                  size: 20.spMin,
                                ),
                                SizedBox(width: 8.spMin),
                                Text(
                                  "Proceed to Payment",
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
}
