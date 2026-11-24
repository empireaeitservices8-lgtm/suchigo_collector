import 'package:flutter/material.dart';
import 'package:suchigo_collector/helpers/sp_helper.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';

class WasteConfigurationViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  int _selectedTab = 0; // 0 = Residential, 1 = Commercial
  bool _isLoading = true;

  List<Map<String, dynamic>> _wasteTypes = [
    {'name': 'Adult Diaper', 'icon': Icons.elderly_rounded},
    {'name': 'Compostable Materials', 'icon': Icons.eco_rounded},
    {'name': 'Hair', 'icon': Icons.content_cut_rounded},
    {'name': 'Hazardous Waste', 'icon': Icons.warning_amber_rounded},
    {'name': 'Kids Diaper', 'icon': Icons.child_care_rounded},
    {'name': 'Medical Waste', 'icon': Icons.medical_services_rounded},
    {'name': 'Sanitary Pad', 'icon': Icons.clean_hands_rounded},
  ];

  final Set<String> _selectedWasteTypes = {};
  final Map<String, int> _bagQuantities = {};

  List<Map<String, dynamic>> _availableBags = [
    {'name': 'LARGE', 'price': 10.0},
    {'name': 'MEDIUM', 'price': 7.0},
    {'name': 'SMALL', 'price': 5.0},
  ];

  final Map<String, double> _bagPrices = {
    'LARGE': 10.0,
    'MEDIUM': 7.0,
    'SMALL': 5.0,
  };

  double _ratePerKg = 0.0;
  String? _disposalLocationName;
  double _enteredWeight = 0.0;
  double _walletBalance = 0.0;
  bool _redeemWallet = false;
  LocationPickupModel? _currentOrder;

  String _paymentMode = 'online'; // 'cash' or 'online'
  String? _qrCodeBase64;
  String? _qrCodeUrl;
  String? _razorpayOrderId;
  dynamic _currentBillId;
  bool _isLoadingQr = false;
  bool _isProcessingPayment = false;
  bool _isPaymentSuccess = false;
  double? _receivedPaymentAmount;
  String? _receivedPaymentUserName;

  LocationPickupModel? get currentOrder => _currentOrder;
  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get wasteTypes => _wasteTypes;
  Set<String> get selectedWasteTypes => _selectedWasteTypes;
  Map<String, int> get bagQuantities => _bagQuantities;
  List<Map<String, dynamic>> get availableBags => _availableBags;
  Map<String, double> get bagPrices => _bagPrices;
  int get totalBags {
    int total = 0;
    _bagQuantities.forEach((_, qty) => total += qty);
    return total;
  }
  bool get hasBags => _bagQuantities.isNotEmpty && totalBags > 0;
  bool get hasWeight => _enteredWeight > 0;
  bool get isConfigurationValid => hasBags && hasWeight;
  double get ratePerKg => _ratePerKg;
  String? get disposalLocationName => _disposalLocationName;
  double get enteredWeight => _enteredWeight;
  double get walletBalance =>
      _walletBalance > 0 ? _walletBalance : (_currentOrder?.walletBalance ?? 0.0);
  bool get redeemWallet => _redeemWallet;
  String get paymentMode => _paymentMode;
  String? get qrCodeBase64 => _qrCodeBase64;
  String? get qrCodeUrl => _qrCodeUrl;
  String? get razorpayOrderId => _razorpayOrderId;
  dynamic get currentBillId => _currentBillId;
  bool get isLoadingQr => _isLoadingQr;
  bool get isProcessingPayment => _isProcessingPayment;
  bool get isPaymentSuccess => _isPaymentSuccess;
  double? get receivedPaymentAmount => _receivedPaymentAmount;
  String? get receivedPaymentUserName => _receivedPaymentUserName;

  void markPaymentSuccess({double? amount, String? userName}) {
    _isPaymentSuccess = true;
    _receivedPaymentAmount = amount ?? finalTotal;
    _receivedPaymentUserName = userName;
    notifyListeners();
  }

  void resetPaymentSuccess() {
    _isPaymentSuccess = false;
    _receivedPaymentAmount = null;
    _receivedPaymentUserName = null;
    notifyListeners();
  }

  double get subtotal {
    double total = 0.0;
    if (_enteredWeight > 0) {
      total += _enteredWeight * _ratePerKg;
    }
    _bagQuantities.forEach((size, qty) {
      final price = _bagPrices[size] ??
          _bagPrices[size.toUpperCase()] ??
          (size.toUpperCase().contains('LARGE')
              ? 10.0
              : (size.toUpperCase().contains('MEDIUM') ? 7.0 : 5.0));
      total += qty * price;
    });
    return total;
  }

  double get discount {
    if (!_redeemWallet) return 0.0;
    return subtotal > walletBalance ? walletBalance : subtotal;
  }

  double get finalTotal {
    final t = subtotal - discount;
    return t > 0 ? t : 0.0;
  }

  void selectTab(int tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  void setWeight(double weight) {
    if (_enteredWeight != weight) {
      _currentBillId = null;
      _qrCodeBase64 = null;
      _qrCodeUrl = null;
      _razorpayOrderId = null;
      _isPaymentSuccess = false;
      _receivedPaymentAmount = null;
      _receivedPaymentUserName = null;
    }
    _enteredWeight = weight;
    notifyListeners();
  }

  void toggleRedeemWallet() {
    if (walletBalance <= 0 && !_redeemWallet) return;
    _redeemWallet = !_redeemWallet;
    _currentBillId = null;
    _qrCodeBase64 = null;
    _qrCodeUrl = null;
    _razorpayOrderId = null;
    _currentBillId = null;
    _isPaymentSuccess = false;
    _receivedPaymentAmount = null;
    _receivedPaymentUserName = null;
    notifyListeners();
  }

  void toggleWasteType(String name) {
    if (_selectedWasteTypes.contains(name)) {
      _selectedWasteTypes.remove(name);
    } else {
      _selectedWasteTypes.add(name);
    }
    notifyListeners();
  }

  void addBag(String name) {
    _currentBillId = null;
    _qrCodeBase64 = null;
    _qrCodeUrl = null;
    _razorpayOrderId = null;
    _currentBillId = null;
    _isPaymentSuccess = false;
    _receivedPaymentAmount = null;
    _receivedPaymentUserName = null;
    final currentQty = _bagQuantities[name] ?? 0;
    _bagQuantities[name] = currentQty + 1;
    notifyListeners();
  }

  void decreaseBag(String name) {
    _currentBillId = null;
    _qrCodeBase64 = null;
    _qrCodeUrl = null;
    _razorpayOrderId = null;
    _currentBillId = null;
    _isPaymentSuccess = false;
    _receivedPaymentAmount = null;
    _receivedPaymentUserName = null;
    final currentQty = _bagQuantities[name] ?? 0;
    if (currentQty > 1) {
      _bagQuantities[name] = currentQty - 1;
    } else {
      _bagQuantities.remove(name);
    }
    notifyListeners();
  }

  void removeBag(String name) {
    _currentBillId = null;
    _qrCodeBase64 = null;
    _qrCodeUrl = null;
    _razorpayOrderId = null;
    _currentBillId = null;
    _isPaymentSuccess = false;
    _receivedPaymentAmount = null;
    _receivedPaymentUserName = null;
    _bagQuantities.remove(name);
    notifyListeners();
  }

  void setPaymentMode(String mode) {
    _paymentMode = mode;
    notifyListeners();
  }

  Future<void> fetchQrCode(
    int pickupId, {
    String? localBody,
    String? ward,
    String? userName,
    int? collectorId,
  }) async {
    if (finalTotal <= 0) {
      _isLoadingQr = false;
      _qrCodeBase64 = null;
      _qrCodeUrl = null;
      _razorpayOrderId = null;
      notifyListeners();
      return;
    }
    _isLoadingQr = true;
    notifyListeners();
    try {
      final effectiveCollectorId =
          collectorId ?? _apiClient.currentCollector?.id;
      final effectiveLocalBody =
          localBody ?? _currentOrder?.localBody ?? _currentOrder?.ward;
      final effectiveWard = ward ?? _currentOrder?.ward;
      final effectiveUserName = userName ?? _currentOrder?.name;

      // 1. Bill MUST exist BEFORE payment so the backend webhook can find it
      if (_currentBillId == null) {
        try {
          debugPrint(
              '[WasteConfig] Generating pending bill before QR creation for pickup: $pickupId, collector: $effectiveCollectorId');
          final billRes = await _apiClient.generateBill(
            pickupId: pickupId,
            weight: enteredWeight,
            rate: ratePerKg,
            totalAmount: finalTotal,
            paymentMethod: 'online',
            localBody: effectiveLocalBody,
            ward: effectiveWard,
            userName: effectiveUserName,
            collectorId: effectiveCollectorId,
            status: 'pending',
          );
          if (billRes is Map) {
            _currentBillId = billRes['bill_id'] ??
                billRes['id'] ??
                billRes['bill']?['id'] ??
                billRes['data']?['id'] ??
                billRes['bill_no'];
          }
          debugPrint(
              '[WasteConfig] Pending bill successfully created: bill_id=$_currentBillId');
        } catch (billErr) {
          debugPrint('[WasteConfig] Error creating pending bill: $billErr');
        }
      }

      // 2. Generate Razorpay QR code / order with bill_id and collector_id in body and notes
      final res = await _apiClient.generateRazorpayQr(
        amount: finalTotal,
        pickupId: pickupId,
        billId: _currentBillId,
        collectorId: effectiveCollectorId,
      );
      if (res is Map) {
        _qrCodeBase64 =
            res['qr_code']?.toString() ?? res['qr_image']?.toString();
        _qrCodeUrl =
            res['qr_code_url']?.toString() ?? res['image_url']?.toString();
        _razorpayOrderId =
            res['order_id']?.toString() ?? res['qr_id']?.toString();
        if (_currentBillId == null && res['bill_id'] != null) {
          _currentBillId = res['bill_id'];
        }
      }
    } catch (e) {
      debugPrint('[WasteConfig] QR Code fetch error: $e');
    } finally {
      _isLoadingQr = false;
      notifyListeners();
    }
  }

  Future<bool> processPayment({
    required int pickupId,
    required int locationId,
    String? localBody,
    String? ward,
    String? userName,
    int? collectorId,
  }) async {
    _isProcessingPayment = true;
    notifyListeners();
    try {
      final effectiveCollectorId =
          collectorId ?? _apiClient.currentCollector?.id;

      if (_paymentMode == 'online' && _razorpayOrderId != null) {
        try {
          await _apiClient.verifyRazorpayPayment(
            orderId: _razorpayOrderId!,
            pickupId: pickupId,
          );
        } catch (verifyErr) {
          debugPrint(
              '[WasteConfig] verifyRazorpayPayment non-fatal: $verifyErr');
        }
      }

      // Finalize or generate bill if cash or if pending bill not created yet
      if (_currentBillId == null || _paymentMode == 'cash' || finalTotal == 0) {
        final billRes = await _apiClient.generateBill(
          pickupId: pickupId,
          weight: enteredWeight,
          rate: ratePerKg,
          totalAmount: finalTotal,
          paymentMethod: finalTotal == 0 ? 'wallet' : paymentMode,
          localBody: localBody ?? ward,
          ward: ward,
          userName: userName,
          collectorId: effectiveCollectorId,
          status: 'paid',
          extraData:
              _currentBillId != null ? {'bill_id': _currentBillId} : null,
        );
        if (billRes is Map && _currentBillId == null) {
          _currentBillId = billRes['bill_id'] ??
              billRes['id'] ??
              billRes['bill']?['id'] ??
              billRes['data']?['id'] ??
              billRes['bill_no'];
        }
      }

      await _apiClient.updatePickupStatus(
        pickupId: pickupId,
        locationId: locationId,
        status: 'completed',
      );
      _isProcessingPayment = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[WasteConfig] Payment completion: $e');
      _isProcessingPayment = false;
      notifyListeners();
      return false;
    }
  }

  IconData _getIconForWasteType(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('adult')) return Icons.elderly_rounded;
    if (lower.contains('kid') ||
        lower.contains('child') ||
        lower.contains('baby') ||
        lower.contains('diaper') ||
        lower.contains('daiper')) {
      return Icons.child_care_rounded;
    }
    if (lower.contains('compost') || lower.contains('eco')) {
      return Icons.eco_rounded;
    }
    if (lower.contains('hair') || lower.contains('cut')) {
      return Icons.content_cut_rounded;
    }
    if (lower.contains('hazard') || lower.contains('danger')) {
      return Icons.warning_amber_rounded;
    }
    if (lower.contains('med') ||
        lower.contains('hospital') ||
        lower.contains('clinic')) {
      return Icons.medical_services_rounded;
    }
    if (lower.contains('sanitary') || lower.contains('pad')) {
      return Icons.clean_hands_rounded;
    }
    return Icons.recycling_rounded;
  }

  String _formatWasteTypeName(String name) {
    if (name.toUpperCase() == 'SANITARY PAD') return 'Sanitary Pad';
    if (name.toLowerCase() == 'adult daiper') return 'Adult Diaper';
    if (name.toLowerCase() == 'kids daiper') return 'Kids Diaper';
    return name;
  }

  Future<void> initForOrder(
    LocationPickupModel order, {
    int? selectedLocalBodyId,
    String? selectedLocalBodyName,
  }) async {
    _isLoading = true;
    _currentOrder = order;
    _enteredWeight = 0.0;
    _bagQuantities.clear();
    _selectedWasteTypes.clear();
    _walletBalance = order.walletBalance ?? 0.0;
    _redeemWallet = false;
    _paymentMode = 'online';
    _qrCodeBase64 = null;
    _qrCodeUrl = null;
    _razorpayOrderId = null;
    _currentBillId = null;
    _isPaymentSuccess = false;
    _receivedPaymentAmount = null;
    _receivedPaymentUserName = null;
    notifyListeners();

    try {
      final savedLocalBodyName =
          await SpHelper.getString('profile_saved_localbody');
      final savedLocalBodyIdStr =
          await SpHelper.getString('profile_saved_localbody_id');
      final effectiveLocalBodyId =
          selectedLocalBodyId ?? int.tryParse(savedLocalBodyIdStr ?? '');

      final results = await Future.wait([
        _apiClient.getBags(),
        _apiClient.getWasteTypes(),
        _apiClient.getDisposalRates(localBodyId: effectiveLocalBodyId),
      ]);

      final bags = results[0] as List<BagModel>;
      final types = results[1] as List<WasteTypeModel>;
      final rates = results[2] as List<DisposalRateModel>;

      if (bags.isNotEmpty) {
        _availableBags = bags.map((b) {
          final upperName = b.size.toUpperCase();
          _bagPrices[upperName] = b.price;
          _bagPrices[b.size] = b.price;
          return {
            'name': upperName,
            'price': b.price,
            'description': b.description,
          };
        }).toList();
      }

      if (types.isNotEmpty) {
        _wasteTypes = types.map((w) {
          final formattedName = _formatWasteTypeName(w.name);
          return {
            'name': formattedName,
            'raw_name': w.name,
            'icon': _getIconForWasteType(w.name),
          };
        }).toList();
      }

      if (rates.isNotEmpty) {
        DisposalRateModel? matchedRate;

        // 1. Match by local_body_id if known
        if (effectiveLocalBodyId != null) {
          for (final r in rates) {
            if (r.localBodyId == effectiveLocalBodyId) {
              matchedRate = r;
              break;
            }
          }
        }

        // 2. Match by local body name from order, selected profile, saved profile, or default ("Alangad Panchayat")
        if (matchedRate == null) {
          final candidateNames = <String>[
            if (order.localBody != null && order.localBody!.trim().isNotEmpty)
              order.localBody!.trim(),
            if (selectedLocalBodyName != null &&
                selectedLocalBodyName.trim().isNotEmpty)
              selectedLocalBodyName.trim(),
            if (savedLocalBodyName != null &&
                savedLocalBodyName.trim().isNotEmpty)
              savedLocalBodyName.trim(),
            if (order.ward != null && order.ward!.trim().isNotEmpty)
              order.ward!.trim(),
            '',
          ];

          for (final candidate in candidateNames) {
            final lowerCandidate = candidate.toLowerCase();
            for (final r in rates) {
              final rName = r.localBodyName?.trim().toLowerCase() ?? '';
              if (rName.isEmpty) continue;
              if (rName == lowerCandidate ||
                  rName.contains(lowerCandidate) ||
                  lowerCandidate.contains(rName)) {
                matchedRate = r;
                break;
              }
            }
            if (matchedRate != null) break;
          }
        }

        matchedRate ??= rates.first;
        _ratePerKg = matchedRate.ratePerKg;
        _disposalLocationName = matchedRate.localBodyName;
      }

      if (order.wasteType?.isNotEmpty == true) {
        for (final type in _wasteTypes) {
          final tName = type['name'].toString().toLowerCase();
          if (tName.contains(order.wasteType!.toLowerCase()) ||
              order.wasteType!.toLowerCase().contains(tName)) {
            _selectedWasteTypes.add(type['name'] as String);
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
