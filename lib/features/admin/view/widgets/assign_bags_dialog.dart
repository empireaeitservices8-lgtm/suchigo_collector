import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view_model/admin_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';

class AssignBagsDialog extends StatefulWidget {
  final CollectorModel collector;
  final VoidCallback? onBagsAssigned;

  const AssignBagsDialog({
    super.key,
    required this.collector,
    this.onBagsAssigned,
  });

  static Future<bool?> show(
    BuildContext context, {
    required CollectorModel collector,
    VoidCallback? onBagsAssigned,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AssignBagsDialog(
        collector: collector,
        onBagsAssigned: onBagsAssigned,
      ),
    );
  }

  @override
  State<AssignBagsDialog> createState() => _AssignBagsDialogState();
}

class _AssignBagsDialogState extends State<AssignBagsDialog> {
  final TextEditingController _bagsController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _bagsController.dispose();
    super.dispose();
  }

  Future<void> _handleAssign() async {
    final text = _bagsController.text.trim();
    final count = int.tryParse(text);
    if (count == null || count <= 0) {
      Fluttertoast.showToast(
        msg: "Please enter a valid number of bags",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.orange.shade800,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isSaving = true);
    final adminVm = context.read<AdminViewModel>();

    final res = await adminVm.assignBags(
      collectorId: widget.collector.id,
      bagCount: count,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (res != null) {
        final message =
            res['message']?.toString() ?? "Bags assigned successfully";
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: const Color(0xFF1D723C),
          textColor: Colors.white,
        );
        widget.onBagsAssigned?.call();
        Navigator.pop(context, true);
      } else {
        Fluttertoast.showToast(
          msg: "Failed to assign bags. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectorName = widget.collector.name.isNotEmpty
        ? widget.collector.name
        : (widget.collector.username.isNotEmpty
            ? widget.collector.username
            : "Collector");

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.spMin),
      ),
      elevation: 8,
      backgroundColor: const Color(0xFFF3F4F3),
      insetPadding:
          EdgeInsets.symmetric(horizontal: 24.spMin, vertical: 24.spMin),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.spMin, 22.spMin, 22.spMin, 20.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Assign Bags to $collectorName",
              style: TextStyle(
                fontSize: 18.spMin,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B4D3E),
                letterSpacing: -0.2.spMin,
              ),
            ),
            SizedBox(height: 18.spMin),

            // Bag Count Input Field
            TextField(
              controller: _bagsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              style: TextStyle(
                fontSize: 15.spMin,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B4D3E),
              ),
              decoration: InputDecoration(
                hintText: "Number of Bags (e.g. 50)",
                hintStyle: TextStyle(
                  fontSize: 14.5.spMin,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF757575),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.spMin,
                  vertical: 14.spMin,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                  borderSide: const BorderSide(color: Color(0xFF9E9E9E)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                  borderSide: const BorderSide(color: Color(0xFF9E9E9E)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                  borderSide: const BorderSide(
                    color: Color(0xFF1D723C),
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
            SizedBox(height: 22.spMin),

            // Action Buttons: Cancel and Assign
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF757575),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.spMin,
                      vertical: 10.spMin,
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
                SizedBox(width: 8.spMin),
                ElevatedButton(
                  onPressed: _isSaving ? null : _handleAssign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D723C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.spMin,
                      vertical: 12.spMin,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.spMin),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 18.spMin,
                          height: 18.spMin,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Assign",
                          style: TextStyle(
                            fontSize: 14.5.spMin,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
