import 'package:flutter/material.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';

class HistoryViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  CollectorOverviewModel _overviewData = CollectorOverviewModel.empty();
  bool _isLoading = true;

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  int _selectedTabIndex = 0; // 0: Overview, 1: Daily Summary, 2: Completed Records

  String _selectedPaymentMethod = "All";
  String _selectedWasteCategory = "All";
  String _selectedSortBy = "Default";
  String _searchQuery = "";

  HistoryViewModel() {
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
    _overviewData = CollectorOverviewModel.empty();
    _isLoading = true;
    _fromDate = DateTime.now().subtract(const Duration(days: 30));
    _toDate = DateTime.now();
    _selectedTabIndex = 0;
    _selectedPaymentMethod = "All";
    _selectedWasteCategory = "All";
    _selectedSortBy = "Default";
    _searchQuery = "";
    notifyListeners();
  }

  CollectorOverviewModel get overviewData => _overviewData;
  CollectorModel? get collector =>
      _overviewData.collector ?? _apiClient.currentCollector;
  OverviewSummaryModel get overview => _overviewData.overview;
  List<DailySummaryItemModel> get dailySummary => _overviewData.dailySummary;
  List<LocationPickupModel> get allRecords => _overviewData.completedRecords;
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
    List<LocationPickupModel> list =
        List.from(_overviewData.completedRecords);

    // Filter by waste category
    if (_selectedWasteCategory != "All") {
      list = list.where((r) {
        final wt = r.wasteType?.toLowerCase() ?? '';
        final idesc = r.itemsDescription?.toLowerCase() ?? '';
        final cat = _selectedWasteCategory.toLowerCase();
        return wt.contains(cat) || idesc.contains(cat);
      }).toList();
    }

    // Filter by payment method
    if (_selectedPaymentMethod != "All") {
      list = list.where((r) {
        final pm = r.paymentMethod?.toLowerCase() ?? '';
        return pm == _selectedPaymentMethod.toLowerCase();
      }).toList();
    }

    // Search query filter
    if (query.isNotEmpty) {
      list = list.where((r) {
        final nameMatch = r.name.toLowerCase().contains(query);
        final phoneMatch =
            r.contactNumber?.toLowerCase().contains(query) ?? false;
        final wardMatch = r.ward?.toLowerCase().contains(query) ?? false;
        final streetMatch = r.street?.toLowerCase().contains(query) ?? false;
        final localBodyMatch =
            r.localBody?.toLowerCase().contains(query) ?? false;
        final idMatch = "ord-${r.id}".toLowerCase().contains(query) ||
            r.id.toString().contains(query) ||
            (r.pickupId?.toString().contains(query) ?? false);
        return nameMatch ||
            phoneMatch ||
            wardMatch ||
            streetMatch ||
            localBodyMatch ||
            idMatch;
      }).toList();
    }

    // Sort
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

  Future<void> fetchCollectionRecords({int? collectorId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fromStr =
          "${_fromDate.year}-${_fromDate.month.toString().padLeft(2, '0')}-${_fromDate.day.toString().padLeft(2, '0')}";
      final toStr =
          "${_toDate.year}-${_toDate.month.toString().padLeft(2, '0')}-${_toDate.day.toString().padLeft(2, '0')}";

      final data = await _apiClient.getCollectorOverview(
        collectorId: collectorId,
        fromDate: fromStr,
        toDate: toStr,
      );

      if (data != null) {
        _overviewData = data;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[HistoryViewModel] fetchCollectionRecords error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
