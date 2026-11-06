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

  double _ratePerKg = 42.0;
  String? _disposalLocationName;
  double _enteredWeight = 0.0;
  final double _walletBalance = 80.0;
  bool _redeemWallet = false;

  String _paymentMode = 'online'; // 'cash' or 'online'
  String? _qrCodeBase64;
  String? _qrCodeUrl;
  String? _razorpayOrderId;
  bool _isLoadingQr = false;
  bool _isProcessingPayment = false;

  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get wasteTypes => _wasteTypes;
  Set<String> get selectedWasteTypes => _selectedWasteTypes;
  Map<String, int> get bagQuantities => _bagQuantities;
  List<Map<String, dynamic>> get availableBags => _availableBags;
  Map<String, double> get bagPrices => _bagPrices;
  double get ratePerKg => _ratePerKg;
  String? get disposalLocationName => _disposalLocationName;
  double get enteredWeight => _enteredWeight;
  double get walletBalance => _walletBalance;
  bool get redeemWallet => _redeemWallet;
  String get paymentMode => _paymentMode;
  String? get qrCodeBase64 => _qrCodeBase64;
  String? get qrCodeUrl => _qrCodeUrl;
  String? get razorpayOrderId => _razorpayOrderId;
  bool get isLoadingQr => _isLoadingQr;
  bool get isProcessingPayment => _isProcessingPayment;

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
    return subtotal > _walletBalance ? _walletBalance : subtotal;
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
    _enteredWeight = weight;
    notifyListeners();
  }

  void toggleRedeemWallet() {
    _redeemWallet = !_redeemWallet;
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
    final currentQty = _bagQuantities[name] ?? 0;
    _bagQuantities[name] = currentQty + 1;
    notifyListeners();
  }

  void decreaseBag(String name) {
    final currentQty = _bagQuantities[name] ?? 0;
    if (currentQty > 1) {
      _bagQuantities[name] = currentQty - 1;
    } else {
      _bagQuantities.remove(name);
    }
    notifyListeners();
  }

  void removeBag(String name) {
    _bagQuantities.remove(name);
    notifyListeners();
  }

  void setPaymentMode(String mode) {
    _paymentMode = mode;
    notifyListeners();
  }

  Future<void> fetchQrCode(int pickupId) async {
    _isLoadingQr = true;
    notifyListeners();
    try {
      final res = await _apiClient.generateRazorpayQr(
        amount: finalTotal,
        pickupId: pickupId,
      );
      if (res is Map) {
        _qrCodeBase64 = res['qr_code']?.toString() ?? res['qr_image']?.toString();
        _qrCodeUrl =
            res['qr_code_url']?.toString() ?? res['image_url']?.toString();
        _razorpayOrderId =
            res['order_id']?.toString() ?? res['qr_id']?.toString();
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
  }) async {
    _isProcessingPayment = true;
    notifyListeners();
    try {
      if (_paymentMode == 'online' && _razorpayOrderId != null) {
        await _apiClient.verifyRazorpayPayment(
          orderId: _razorpayOrderId!,
          pickupId: pickupId,
        );
      }
      await _apiClient.generateBill(
        pickupId: pickupId,
        weight: enteredWeight,
        rate: ratePerKg,
        totalAmount: finalTotal,
        paymentMethod: paymentMode,
        localBody: localBody ?? ward,
        ward: ward,
        userName: userName,
      );
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
    _enteredWeight = 0.0;
    _bagQuantities.clear();
    _selectedWasteTypes.clear();
    _redeemWallet = false;
    _qrCodeBase64 = null;
    _qrCodeUrl = null;
    _razorpayOrderId = null;
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
            'Alangad Panchayat',
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
