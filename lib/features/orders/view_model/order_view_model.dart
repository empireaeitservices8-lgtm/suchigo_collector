import 'package:flutter/material.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';

class OrderViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<LocationPickupModel> _orders = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String? _wardFilter;

  final Map<int, String> _customStatuses = {};
  final Set<int> _updatingIds = {};
  bool _isReaching = false;

  List<LocationPickupModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get wardFilter => _wardFilter;
  bool get isReaching => _isReaching;

  String getOrderStatus(LocationPickupModel order) {
    return _customStatuses[order.id] ?? order.status?.toLowerCase() ?? 'pending';
  }

  bool isOrderUpdating(int orderId) => _updatingIds.contains(orderId);

  List<LocationPickupModel> get filteredOrders {
    var list = _orders;

    if (_wardFilter != null && _wardFilter!.trim().isNotEmpty) {
      final wf = _wardFilter!.trim().toLowerCase();
      final wardMatch = RegExp(r'^(\d+)\s*-\s*(.+)$').firstMatch(_wardFilter!.trim());
      final numPart = wardMatch?.group(1);
      final namePart = wardMatch?.group(2)?.trim().toLowerCase() ?? wf;

      final matched = list.where((order) {
        final w = order.ward?.trim().toLowerCase() ?? '';
        if (w.isEmpty) return false;
        return w == wf ||
            w == namePart ||
            w.contains(namePart) ||
            namePart.contains(w) ||
            (numPart != null && w == numPart);
      }).toList();

      if (matched.isNotEmpty) {
        list = matched;
      }
    }

    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return list;

    return list.where((order) {
      final name = order.name.toLowerCase();
      final phone = order.contactNumber?.toLowerCase() ?? '';
      final ward = order.ward?.toLowerCase() ?? '';
      final id = "ord-${order.id}".toLowerCase();
      final idNum = order.id.toString();

      return name.contains(query) ||
          phone.contains(query) ||
          ward.contains(query) ||
          id.contains(query) ||
          idNum.contains(query);
    }).toList();
  }

  void setWardFilter(String? ward) {
    _wardFilter = ward;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setLocalStatus(int orderId, String status) {
    _customStatuses[orderId] = status;
    notifyListeners();
  }

  void setReaching(bool value) {
    _isReaching = value;
    notifyListeners();
  }

  Future<void> fetchActiveOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiClient.getLocations();
      _orders = data;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePickupStatus({
    required int pickupId,
    required int locationId,
    required String status,
  }) async {
    _updatingIds.add(locationId);
    notifyListeners();

    try {
      await _apiClient.updatePickupStatus(
        pickupId: pickupId,
        locationId: locationId,
        status: status,
      );
      _customStatuses[locationId] = status;
      final index = _orders.indexWhere((o) => o.id == locationId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
      }
      _updatingIds.remove(locationId);
      notifyListeners();
      return true;
    } catch (_) {
      // Optimistic fallback
      _customStatuses[locationId] = status;
      _updatingIds.remove(locationId);
      notifyListeners();
      return true;
    }
  }

  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      await _apiClient.updateLocationStatus(
        locationId: orderId,
        status: newStatus,
      );
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
