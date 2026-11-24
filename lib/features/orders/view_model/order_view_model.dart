import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';

class OrderViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<LocationPickupModel> _orders = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String? _wardFilter;
  String? _localBodyFilter;
  bool _onlyCurrentDate = true;

  final Map<int, String> _customStatuses = {};
  final Set<int> _updatingIds = {};
  bool _isReaching = false;

  Position? _currentPosition;
  final Map<int, (double, double)> _geocodedCoords = {};

  OrderViewModel() {
    AuthViewModel.addOnLogoutCallback(_handleLogoutCallback);
  }

  @override
  void dispose() {
    AuthViewModel.removeOnLogoutCallback(_handleLogoutCallback);
    super.dispose();
  }

  Future<void> _handleLogoutCallback() async {
    reset();
  }

  void reset() {
    _orders = [];
    _isLoading = true;
    _searchQuery = "";
    _wardFilter = null;
    _localBodyFilter = null;
    _onlyCurrentDate = true;
    _customStatuses.clear();
    _updatingIds.clear();
    _isReaching = false;
    _currentPosition = null;
    _geocodedCoords.clear();
    notifyListeners();
  }

  List<LocationPickupModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get wardFilter => _wardFilter;
  String? get localBodyFilter => _localBodyFilter;
  bool get onlyCurrentDate => _onlyCurrentDate;
  bool get isReaching => _isReaching;
  Position? get currentPosition => _currentPosition;

  void setOnlyCurrentDate(bool value) {
    _onlyCurrentDate = value;
    notifyListeners();
  }

  /// Fetches collector's live GPS coordinates using Geolocator
  Future<void> fetchCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        _currentPosition = lastPos;
        notifyListeners();
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
      _currentPosition = pos;
      notifyListeners();
    } catch (e) {
      debugPrint('[OrderViewModel] fetchCurrentLocation error: $e');
    }
  }

  void setCurrentPosition(Position pos) {
    _currentPosition = pos;
    notifyListeners();
  }

  static final Map<String, (double, double)> _knownAreas = {
    // Districts
    'ernakulam': (9.9816, 76.2999),
    'thrissur': (10.5276, 76.2144),
    'kozhikode': (11.2588, 75.7804),
    'thiruvananthapuram': (8.5241, 76.9366),
    'kollam': (8.8932, 76.6141),
    'kottayam': (9.5916, 76.5222),
    'alappuzha': (9.4981, 76.3388),
    'palakkad': (10.7867, 76.6548),
    'malappuram': (11.0735, 76.0740),
    'kannur': (11.8745, 75.3704),
    'kasaragod': (12.4996, 74.9869),
    'idukki': (9.8500, 76.9667),
    'wayanad': (11.6854, 76.1320),
    'pathanamthitta': (9.2648, 76.7870),

    // Municipalities, Panchayats & Towns
    'aluva': (10.1076, 76.3516),
    'aluva municipality': (10.1076, 76.3516),
    'eloor': (10.0760, 76.3020),
    'eloor municipality': (10.0760, 76.3020),
    'arimbur': (10.4900, 76.1500),
    'arimbur grama panchayat': (10.4900, 76.1500),
    'kalamassery': (10.0537, 76.3195),
    'kalamassery municipality': (10.0537, 76.3195),
    'thrikkakara': (10.0284, 76.3364),
    'thrikkakara municipality': (10.0284, 76.3364),
    'kochi': (9.9312, 76.2673),
    'cochin': (9.9312, 76.2673),
    'kakkanad': (10.0159, 76.3419),
    'edappally': (10.0261, 76.3082),
    'infopark': (10.0080, 76.3620),
    'elamakkara': (10.0218, 76.2905),
    'kanayannur': (9.9816, 76.2999),

    // Postal Pincodes
    '682026': (10.0218, 76.2905),
    '682048': (10.0080, 76.3620),
    '682030': (10.0159, 76.3419),
    '682303': (10.0760, 76.3020),
    '683101': (10.1076, 76.3516),
  };

  /// Returns coordinates for an order (either from backend, geocoded, or regional fallback)
  (double, double)? getOrderCoordinates(LocationPickupModel order,
      {bool allowFallback = true}) {
    if (order.latitude != null && order.longitude != null) {
      return (order.latitude!, order.longitude!);
    }
    if (_geocodedCoords.containsKey(order.id)) {
      return _geocodedCoords[order.id];
    }
    if (!allowFallback) return null;

    // Smart area resolution to ensure 100% of bookings are plotted
    (double, double)? base;
    if (order.zipCode != null &&
        _knownAreas.containsKey(order.zipCode!.trim())) {
      base = _knownAreas[order.zipCode!.trim()];
    } else if (order.localBody != null &&
        _knownAreas.containsKey(order.localBody!.trim().toLowerCase())) {
      base = _knownAreas[order.localBody!.trim().toLowerCase()];
    } else if (order.city != null &&
        _knownAreas.containsKey(order.city!.trim().toLowerCase())) {
      base = _knownAreas[order.city!.trim().toLowerCase()];
    } else if (order.district != null &&
        _knownAreas.containsKey(order.district!.trim().toLowerCase())) {
      base = _knownAreas[order.district!.trim().toLowerCase()];
    } else if (_currentPosition != null) {
      base = (_currentPosition!.latitude, _currentPosition!.longitude);
    } else {
      base = (10.0218, 76.2905); // Central Kerala default
    }

    if (base != null) {
      // Deterministic spread offset so pins in same area don't overlap exactly
      final int seed = order.id.abs();
      final double latOffset = (((seed * 17) % 100) - 50) * 0.00018;
      final double lngOffset = (((seed * 31) % 100) - 50) * 0.00018;
      return (base.$1 + latOffset, base.$2 + lngOffset);
    }

    return null;
  }

  /// Calculates real-time distance in meters from collector to order
  double? getDistanceInMeters(LocationPickupModel order) {
    if (_currentPosition == null) return null;
    final coords = getOrderCoordinates(order);
    if (coords == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      coords.$1,
      coords.$2,
    );
  }

  /// Formats distance nicely (e.g., "450 m" or "1.8 km")
  String? getFormattedDistance(LocationPickupModel order) {
    final meters = getDistanceInMeters(order);
    if (meters == null) return null;
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Geocodes missing addresses asynchronously in background
  Future<void> _resolveMissingCoordinates(List<LocationPickupModel> list) async {
    for (final order in list) {
      if (order.latitude != null && order.longitude != null) continue;
      if (_geocodedCoords.containsKey(order.id)) continue;

      final query = order.street?.trim().isNotEmpty == true
          ? order.street!.trim()
          : (order.zipCode?.trim().isNotEmpty == true
              ? '${order.zipCode!.trim()}, Kerala, India'
              : (order.ward?.trim().isNotEmpty == true
                  ? '${order.ward!.trim()}, Kerala, India'
                  : null));

      if (query == null) continue;

      try {
        final dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          headers: {'User-Agent': 'SuchigoCollectorApp/1.0'},
        ));
        final res = await dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'q': query,
            'format': 'json',
            'limit': 1,
          },
        );
        if (res.data is List && (res.data as List).isNotEmpty) {
          final item = (res.data as List).first;
          final lat = double.tryParse(item['lat']?.toString() ?? '');
          final lon = double.tryParse(item['lon']?.toString() ?? '');
          if (lat != null && lon != null) {
            _geocodedCoords[order.id] = (lat, lon);
            notifyListeners();
          }
        }
      } catch (_) {}
    }
  }

  String getOrderStatus(LocationPickupModel order) {
    return _customStatuses[order.id] ?? order.status?.toLowerCase() ?? 'pending';
  }

  bool isOrderUpdating(int orderId) => _updatingIds.contains(orderId);

  /// Returns only the orders scheduled/booked for the current date (today)
  List<LocationPickupModel> get todayOrders {
    final now = DateTime.now();
    return _orders.where((order) => isCurrentDateOrder(order, now)).toList();
  }

  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime? tryParseDate(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    final iso = DateTime.tryParse(trimmed);
    if (iso != null) return iso;

    final parts = trimmed.split(RegExp(r'[-/.\s]'));
    if (parts.length >= 3) {
      if (parts[0].length == 4) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2].split('T')[0].split(' ')[0]);
        if (y != null && m != null && d != null) {
          try {
            return DateTime(y, m, d);
          } catch (_) {}
        }
      } else if (parts[2].length >= 4) {
        final p0 = int.tryParse(parts[0]);
        final p1 = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2].split('T')[0].split(' ')[0]);
        if (p0 != null && p1 != null && y != null) {
          try {
            return DateTime(y, p1, p0);
          } catch (_) {}
        }
      }
    }

    final monthRegex = RegExp(r'(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})');
    final match = monthRegex.firstMatch(trimmed);
    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      final monthStr = match.group(2)!.toLowerCase();
      final year = int.tryParse(match.group(3)!);
      const months = {
        'jan': 1,
        'january': 1,
        'feb': 2,
        'february': 2,
        'mar': 3,
        'march': 3,
        'apr': 4,
        'april': 4,
        'may': 5,
        'jun': 6,
        'june': 6,
        'jul': 7,
        'july': 7,
        'aug': 8,
        'august': 8,
        'sep': 9,
        'september': 9,
        'oct': 10,
        'october': 10,
        'nov': 11,
        'november': 11,
        'dec': 12,
        'december': 12,
      };
      final month = months[monthStr];
      if (day != null && month != null && year != null) {
        try {
          return DateTime(year, month, day);
        } catch (_) {}
      }
    }

    return null;
  }

  static bool isCurrentDateOrder(LocationPickupModel order,
      [DateTime? currentDate]) {
    final now = currentDate ?? DateTime.now();

    // 1. Check pickupDateDisplay
    if (order.pickupDateDisplay != null &&
        order.pickupDateDisplay!.trim().isNotEmpty) {
      final disp = order.pickupDateDisplay!.trim().toLowerCase();
      if (disp == 'today') return true;
      if (disp == 'tomorrow' || disp == 'yesterday') return false;
      final parsedDisp = tryParseDate(disp);
      if (parsedDisp != null) {
        return isSameDate(parsedDisp, now);
      }
    }

    // 2. Check pickupDate
    final rawDate = order.pickupDate?.trim();
    if (rawDate != null &&
        rawDate.isNotEmpty &&
        rawDate.toLowerCase() != 'null') {
      final lower = rawDate.toLowerCase();
      if (lower == 'today') return true;
      if (lower == 'tomorrow' || lower == 'yesterday') return false;

      final parsed = tryParseDate(rawDate);
      if (parsed != null) {
        return isSameDate(parsed, now);
      }

      final ymd =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final dmy =
          "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
      final ymdSlash =
          "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";
      final dmySlash =
          "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

      if (rawDate.contains(ymd) ||
          rawDate.contains(dmy) ||
          rawDate.contains(ymdSlash) ||
          rawDate.contains(dmySlash)) {
        return true;
      }

      // Explicitly dated for another day
      return false;
    }

    // 3. Check dayOfWeek / pickupDay
    final dow = (order.dayOfWeek ?? order.pickupDay)?.trim().toLowerCase();
    if (dow != null && dow.isNotEmpty && dow != 'null') {
      final todayLong = DateFormat('EEEE').format(now).toLowerCase();
      final todayShort = DateFormat('E').format(now).toLowerCase();
      return dow == todayLong || dow == todayShort;
    }

    // 4. Check calendarDate if provided
    if (order.calendarDate != null && order.calendarDate! > 0) {
      return order.calendarDate == now.day;
    }

    // Fallback: If no date at all is specified, treat as current booking
    return true;
  }

  List<LocationPickupModel> get filteredOrders {
    var list = _onlyCurrentDate ? todayOrders : _orders;

    if (_localBodyFilter != null && _localBodyFilter!.trim().isNotEmpty) {
      final lbf = _localBodyFilter!.trim().toLowerCase();
      final matched = list.where((order) {
        final lb = order.localBody?.trim().toLowerCase() ?? '';
        if (lb.isEmpty) return false;
        return lb == lbf || lb.contains(lbf) || lbf.contains(lb);
      }).toList();

      if (matched.isNotEmpty) {
        list = matched;
      }
    }

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
    var result = list;
    if (query.isNotEmpty) {
      result = list.where((order) {
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

    // Sort based on distance (nearest first) whenever coordinates are available
    if (_currentPosition != null) {
      final sorted = List<LocationPickupModel>.from(result);
      sorted.sort((a, b) {
        final distA = getDistanceInMeters(a) ?? double.infinity;
        final distB = getDistanceInMeters(b) ?? double.infinity;
        return distA.compareTo(distB);
      });
      return sorted;
    }

    return result;
  }

  void setWardFilter(String? ward) {
    _wardFilter = ward;
    notifyListeners();
  }

  void setLocalBodyFilter(String? localBody) {
    _localBodyFilter = localBody;
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

  Future<void> fetchActiveOrders({
    String? ward,
    String? localBody,
    int? localBodyId,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Start fetching collector's live location concurrently
    fetchCurrentLocation();

    try {
      final data = await _apiClient.getLocations(
        ward: ward,
        localBody: localBody,
        localBodyId: localBodyId,
      );
      _orders = data;
      _isLoading = false;
      notifyListeners();

      // Resolve missing order coordinates in background
      _resolveMissingCoordinates(data);
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
