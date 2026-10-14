import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_collector/features/admin/view_model/admin_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';

class AssignVehicleDialog extends StatefulWidget {
  final CollectorModel collector;
  final VoidCallback? onVehicleAssigned;

  const AssignVehicleDialog({
    super.key,
    required this.collector,
    this.onVehicleAssigned,
  });

  static Future<bool?> show(
    BuildContext context, {
    required CollectorModel collector,
    VoidCallback? onVehicleAssigned,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AssignVehicleDialog(
        collector: collector,
        onVehicleAssigned: onVehicleAssigned,
      ),
    );
  }

  @override
  State<AssignVehicleDialog> createState() => _AssignVehicleDialogState();
}

class _AssignVehicleDialogState extends State<AssignVehicleDialog> {
  VehicleModelItem? _selectedModel;
  String? _selectedPlateNumber;
  final TextEditingController _customPlateController = TextEditingController();

  List<VehicleModelItem> _vehicleModels = [];
  List<VehicleNumberItem> _vehicleNumbers = [];
  bool _isLoading = true;
  bool _isLoadingNumbers = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _customPlateController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    final adminVm = context.read<AdminViewModel>();
    final models = await adminVm.fetchVehicleModels();

    if (mounted) {
      setState(() {
        _vehicleModels = models;
        // If collector currently has a vehicle assigned, match it
        if (widget.collector.vehicleName != null &&
            widget.collector.vehicleName!.trim().isNotEmpty) {
          final currentName = widget.collector.vehicleName!.trim().toLowerCase();
          for (final m in models) {
            if (m.name.trim().toLowerCase() == currentName) {
              _selectedModel = m;
              break;
            }
          }
        }
        if (widget.collector.vehicleNumber != null &&
            widget.collector.vehicleNumber!.trim().isNotEmpty) {
          _selectedPlateNumber = widget.collector.vehicleNumber!.trim();
          _customPlateController.text = _selectedPlateNumber!;
        }
        _isLoading = false;
      });

      if (_selectedModel != null) {
        _loadNumbersForModel(_selectedModel!.id);
      }
    }
  }

  Future<void> _loadNumbersForModel(int modelId) async {
    setState(() => _isLoadingNumbers = true);
    final adminVm = context.read<AdminViewModel>();
    final numbers = await adminVm.fetchVehicleNumbers(modelId);
    if (mounted) {
      setState(() {
        _vehicleNumbers = numbers;
        _isLoadingNumbers = false;
        if (numbers.isNotEmpty) {
          if (_selectedPlateNumber == null ||
              !numbers.any((n) => n.number == _selectedPlateNumber)) {
            _selectedPlateNumber = numbers.first.number;
            _customPlateController.text = _selectedPlateNumber!;
          }
        } else {
          _selectedPlateNumber = null;
          _customPlateController.clear();
        }
      });
    }
  }

  Future<void> _onModelChanged(VehicleModelItem? model) async {
    if (model == _selectedModel) return;

    setState(() {
      _selectedModel = model;
      _selectedPlateNumber = null;
      _customPlateController.clear();
      _vehicleNumbers = [];
      _isLoadingNumbers = model != null;
    });

    if (model != null) {
      await _loadNumbersForModel(model.id);
    }
  }

  Future<void> _handleAssign() async {
    if (_isSaving || _isLoadingNumbers) return;

    setState(() => _isSaving = true);
    final adminVm = context.read<AdminViewModel>();

    final vehicleName = _selectedModel?.name;
    final vehiclePlate = _selectedPlateNumber ??
        (_customPlateController.text.trim().isNotEmpty
            ? _customPlateController.text.trim()
            : null);

    final success = await adminVm.assignVehicle(
      collectorId: widget.collector.id,
      vehicleModel: vehicleName,
      vehicleNumber: vehiclePlate,
      modelId: _selectedModel?.id,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Fluttertoast.showToast(
          msg: vehicleName != null
              ? "Assigned $vehicleName ($vehiclePlate) to ${widget.collector.name}"
              : "Vehicle unassigned for ${widget.collector.name}",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: const Color(0xFF1D723C),
          textColor: Colors.white,
        );
        widget.onVehicleAssigned?.call();
        Navigator.pop(context, true);
      } else {
        Fluttertoast.showToast(
          msg: "Failed to assign vehicle. Please try again.",
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

    final bool isUnassigning = _selectedModel == null &&
        (widget.collector.vehicleName != null &&
            widget.collector.vehicleName!.trim().isNotEmpty);

    final bool hasValidSelection = _selectedModel != null &&
        ((_selectedPlateNumber != null &&
                _selectedPlateNumber!.trim().isNotEmpty) ||
            _customPlateController.text.trim().isNotEmpty);

    final bool canAssign =
        (hasValidSelection || isUnassigning) && !_isLoadingNumbers;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.spMin),
      ),
      elevation: 10,
      backgroundColor: const Color(0xFFF3F4F3),
      insetPadding: EdgeInsets.symmetric(horizontal: 22.spMin, vertical: 24.spMin),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22.spMin, 24.spMin, 22.spMin, 20.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title: Assign Vehicle to <Name>
            Text(
              "Assign Vehicle to $collectorName",
              style: TextStyle(
                fontSize: 18.spMin,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF135C30),
                letterSpacing: -0.2.spMin,
              ),
            ),
            SizedBox(height: 5.spMin),

            // Subtitle
            Text(
              "Select an authorized vehicle model and plate number",
              style: TextStyle(
                fontSize: 12.5.spMin,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF757575),
              ),
            ),

            SizedBox(height: 20.spMin),

            // Field 1: Vehicle Model
            Text(
              "Vehicle Model",
              style: TextStyle(
                fontSize: 13.5.spMin,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B4D3E),
              ),
            ),
            SizedBox(height: 8.spMin),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.spMin),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1.spMin,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 3.spMin),
              child: Row(
                children: [
                  Icon(
                    Icons.local_shipping_rounded,
                    color: const Color(0xFF1D723C),
                    size: 22.spMin,
                  ),
                  SizedBox(width: 12.spMin),
                  Expanded(
                    child: _isLoading
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.spMin),
                            child: Text(
                              "Loading vehicle models...",
                              style: TextStyle(
                                fontSize: 13.5.spMin,
                                color: const Color(0xFF9E9E9E),
                              ),
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<VehicleModelItem?>(
                              value: _selectedModel,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16.spMin),
                              hint: Text(
                                "No vehicle assigned",
                                style: TextStyle(
                                  fontSize: 14.spMin,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF212121),
                                ),
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down_rounded,
                                color: const Color(0xFF757575),
                                size: 28.spMin,
                              ),
                              items: [
                                DropdownMenuItem<VehicleModelItem?>(
                                  value: null,
                                  child: Text(
                                    "No vehicle assigned",
                                    style: TextStyle(
                                      fontSize: 14.spMin,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF757575),
                                    ),
                                  ),
                                ),
                                ..._vehicleModels.map((m) {
                                  return DropdownMenuItem<VehicleModelItem?>(
                                    value: m,
                                    child: Text(
                                      m.name,
                                      style: TextStyle(
                                        fontSize: 14.spMin,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF212121),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: _onModelChanged,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.spMin),

            // Field 2: License Plate
            Text(
              "License Plate",
              style: TextStyle(
                fontSize: 13.5.spMin,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B4D3E),
              ),
            ),
            SizedBox(height: 8.spMin),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.spMin),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1.spMin,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 3.spMin),
              child: Row(
                children: [
                  Icon(
                    Icons.credit_card_rounded,
                    color: const Color(0xFF1D723C),
                    size: 22.spMin,
                  ),
                  SizedBox(width: 12.spMin),
                  Expanded(
                    child: _isLoadingNumbers
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.spMin),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16.spMin,
                                  height: 16.spMin,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF1D723C),
                                  ),
                                ),
                                SizedBox(width: 10.spMin),
                                Text(
                                  "Loading vehicle numbers...",
                                  style: TextStyle(
                                    fontSize: 13.5.spMin,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _selectedModel == null
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.spMin),
                                child: Text(
                                  "Select a vehicle model first",
                                  style: TextStyle(
                                    fontSize: 13.5.spMin,
                                    color: const Color(0xFF9E9E9E),
                                  ),
                                ),
                              )
                            : _vehicleNumbers.isNotEmpty
                                ? DropdownButtonHideUnderline(
                                    child: DropdownButton<String?>(
                                      value: _selectedPlateNumber,
                                      isExpanded: true,
                                      dropdownColor: Colors.white,
                                      borderRadius: BorderRadius.circular(16.spMin),
                                      hint: Text(
                                        "Select Plate Number",
                                        style: TextStyle(
                                          fontSize: 14.spMin,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF757575),
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: const Color(0xFF757575),
                                        size: 28.spMin,
                                      ),
                                      items: _vehicleNumbers.map((n) {
                                        return DropdownMenuItem<String?>(
                                          value: n.number,
                                          child: Text(
                                            n.number,
                                            style: TextStyle(
                                              fontSize: 14.spMin,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF212121),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedPlateNumber = val;
                                          if (val != null) {
                                            _customPlateController.text = val;
                                          }
                                        });
                                      },
                                    ),
                                  )
                                : TextField(
                                    controller: _customPlateController,
                                    style: TextStyle(
                                      fontSize: 14.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF212121),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Enter Plate Number (e.g. KL 07 AB 1234)",
                                      hintStyle: TextStyle(
                                        fontSize: 13.spMin,
                                        color: const Color(0xFF9E9E9E),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 12.spMin),
                                    ),
                                    onChanged: (val) {
                                      _selectedPlateNumber = val;
                                    },
                                  ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.spMin),

            // Action Buttons: Cancel and Assign
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF757575),
                    padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 10.spMin),
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
                  onPressed: (_isSaving || !canAssign) ? null : _handleAssign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAssign
                        ? const Color(0xFF1D723C)
                        : const Color(0xFFDCD8E0),
                    disabledBackgroundColor: const Color(0xFFDCD8E0),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF8E8E93),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 24.spMin, vertical: 12.spMin),
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
                            color: canAssign ? Colors.white : const Color(0xFF8E8E93),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
