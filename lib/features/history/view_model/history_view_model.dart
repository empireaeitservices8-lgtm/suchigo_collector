import 'package:flutter/material.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';

class HistoryViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<LocationPickupModel> _allRecords = [];
  bool _isLoading = true;

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  int _selectedTabIndex = 0; // 0: Overview, 1: Daily Summary, 2: Completed Records

  String _selectedPaymentMethod = "All";
  String _selectedWasteCategory = "All";
  String _selectedSortBy = "Default";
  String _searchQuery = "";

  List<LocationPickupModel> get allRecords => _allRecords;
  bool get isLoading => _isLoading;
  DateTime get fromDate => _fromDate;
  DateTime get toDate => _toDate;
  int get selectedTabIndex => _selectedTabIndex;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  String get selectedWasteCategory => _selectedWasteCategory;
  String get selectedSortBy => _selectedSortBy;
  String get searchQuery => _searchQuery;

  List<LocationPickupModel> get completedRecords {
    final query = _searchQuery.trim().toLowerCase();
    List<LocationPickupModel> list = List.from(_allRecords);

    if (query.isNotEmpty) {
      list = list.where((r) {
        final nameMatch = r.name.toLowerCase().contains(query);
        final phoneMatch =
            r.contactNumber?.toLowerCase().contains(query) ?? false;
        final wardMatch = r.ward?.toLowerCase().contains(query) ?? false;
        return nameMatch || phoneMatch || wardMatch;
      }).toList();
    }

    if (_selectedSortBy == "Newest First") {
      list.sort((a, b) => b.id.compareTo(a.id));
    } else if (_selectedSortBy == "Oldest First") {
      list.sort((a, b) => a.id.compareTo(b.id));
    }

    return list;
  }

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFromDate(DateTime date) {
    _fromDate = date;
    if (_toDate.isBefore(_fromDate)) {
      _toDate = _fromDate;
    }
    notifyListeners();
  }

  void setToDate(DateTime date) {
    _toDate = date;
    notifyListeners();
  }

  void setFilters({
    required String paymentMethod,
    required String wasteCategory,
    required String sortBy,
  }) {
    _selectedPaymentMethod = paymentMethod;
    _selectedWasteCategory = wasteCategory;
    _selectedSortBy = sortBy;
    notifyListeners();
  }

  Future<void> fetchCollectionRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      final records = await _apiClient.getLocations();
      _allRecords = records;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
