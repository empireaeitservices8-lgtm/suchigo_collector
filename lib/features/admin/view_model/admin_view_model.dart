import 'package:flutter/material.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';

class AdminCollectorStats {
  final CollectorModel collector;
  final double quantityKg;
  final double revenue;
  final int pickups;
  final bool isOnDuty;
  final bool hasVehicle;
  final String localBody;
  final String ward;

  AdminCollectorStats({
    required this.collector,
    this.quantityKg = 0.0,
    this.revenue = 0.0,
    this.pickups = 0,
    this.isOnDuty = true,
    this.hasVehicle = true,
    this.localBody = "Kochi Corporation",
    this.ward = "ERAVIMANGALAM",
  });
}

class AdminViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  int _selectedTabIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  AdminDashboardModel? _dashboardData;
  List<AdminCollectorStats> _collectorStatsList = [];

  int get selectedTabIndex => _selectedTabIndex;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  AdminDashboardModel? get dashboardData => _dashboardData;
  AdminDashboardStatisticsModel? get statistics => _dashboardData?.statistics;

  String _dutyStatusFilter = "All";
  String _vehicleFilter = "All";
  String _selectedLocalBody = "All";
  String _selectedWard = "All";
  String _sortBy = "Default";

  String get dutyStatusFilter => _dutyStatusFilter;
  String get vehicleFilter => _vehicleFilter;
  String get selectedLocalBody => _selectedLocalBody;
  String get selectedWard => _selectedWard;
  String get sortBy => _sortBy;

  List<String> get availableLocalBodies => [
        "All",
        "Kochi Corporation",
        "Nadathara Grama Panchayat",
        "Kalamassery Municipality",
      ];

  List<String> get availableWards => [
        "All",
        "ERAVIMANGALAM",
        "EDAPPALLY",
        "KALAMASSERY",
        "PALARIVATTOM",
      ];

  List<AdminCollectorStats> get collectorStatsList {
    List<AdminCollectorStats> list = List.from(_collectorStatsList);

    // 1. Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((item) {
        final name = item.collector.name.toLowerCase();
        final username = item.collector.username.toLowerCase();
        final phone = item.collector.phone.toLowerCase();
        return name.contains(q) || username.contains(q) || phone.contains(q);
      }).toList();
    }

    // 2. Duty Status Filter
    if (_dutyStatusFilter == "On Duty") {
      list = list.where((item) => item.isOnDuty).toList();
    } else if (_dutyStatusFilter == "Off Duty") {
      list = list.where((item) => !item.isOnDuty).toList();
    }

    // 3. Vehicle Filter
    if (_vehicleFilter == "Assigned") {
      list = list.where((item) => item.hasVehicle).toList();
    } else if (_vehicleFilter == "No Vehicle") {
      list = list.where((item) => !item.hasVehicle).toList();
    }

    // 4. Local Body Filter
    if (_selectedLocalBody != "All") {
      list = list
          .where((item) =>
              item.localBody.toLowerCase() == _selectedLocalBody.toLowerCase())
          .toList();
    }

    // 5. Ward Filter
    if (_selectedWard != "All") {
      list = list
          .where((item) =>
              item.ward.toLowerCase() == _selectedWard.toLowerCase())
          .toList();
    }

    // 6. Sorting
    switch (_sortBy) {
      case "Name (A-Z)":
        list.sort((a, b) {
          final nameA = a.collector.name.isNotEmpty
              ? a.collector.name
              : a.collector.username;
          final nameB = b.collector.name.isNotEmpty
              ? b.collector.name
              : b.collector.username;
          return nameA.toLowerCase().compareTo(nameB.toLowerCase());
        });
        break;
      case "Quantity (High to Low)":
        list.sort((a, b) => b.quantityKg.compareTo(a.quantityKg));
        break;
      case "Revenue (High to Low)":
        list.sort((a, b) => b.revenue.compareTo(a.revenue));
        break;
      case "Pickups (High to Low)":
        list.sort((a, b) => b.pickups.compareTo(a.pickups));
        break;
      default:
        // Default order
        break;
    }

    return list;
  }

  int get totalCollectorsCount {
    if (_dashboardData != null &&
        _dashboardData!.statistics.totalCollectors > 0) {
      return _dashboardData!.statistics.totalCollectors;
    }
    return _collectorStatsList.isNotEmpty ? _collectorStatsList.length : 16;
  }

  int get onDutyCount {
    final activeInList = _collectorStatsList.where((c) => c.isOnDuty).length;
    return activeInList > 0 ? activeInList : totalCollectorsCount;
  }

  int get totalLocations => _dashboardData?.statistics.totalLocations ?? 41;

  int get pendingPickups => _dashboardData?.statistics.pendingPickups ?? 41;

  int get totalBills => _dashboardData?.statistics.totalBills ?? 63;

  double get totalQuantityKg {
    return 122.5;
  }

  double get totalRevenue {
    if (_dashboardData != null && _dashboardData!.statistics.totalRevenue > 0) {
      return _dashboardData!.statistics.totalRevenue;
    }
    return 60374.85;
  }

  double get pendingCash => _dashboardData?.statistics.pendingCash ?? 0.0;

  double get cashRevenue => pendingCash;
  double get onlineRevenue => 0.0;

  AdminViewModel() {
    _loadInitialMockData();
    fetchAdminData();
  }

  void setTab(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void applyFilters({
    required String dutyStatus,
    required String vehicle,
    required String localBody,
    required String ward,
    required String sortBy,
  }) {
    _dutyStatusFilter = dutyStatus;
    _vehicleFilter = vehicle;
    _selectedLocalBody = localBody;
    _selectedWard = ward;
    _sortBy = sortBy;
    notifyListeners();
  }

  void resetFilters() {
    _dutyStatusFilter = "All";
    _vehicleFilter = "All";
    _selectedLocalBody = "All";
    _selectedWard = "All";
    _sortBy = "Default";
    notifyListeners();
  }

  void setDutyStatusFilter(String val) {
    _dutyStatusFilter = val;
    notifyListeners();
  }

  void setVehicleFilter(String val) {
    _vehicleFilter = val;
    notifyListeners();
  }

  void setSelectedLocalBody(String val) {
    _selectedLocalBody = val;
    notifyListeners();
  }

  void setSelectedWard(String val) {
    _selectedWard = val;
    notifyListeners();
  }

  void setSortBy(String val) {
    _sortBy = val;
    notifyListeners();
  }

  static final List<String> _sampleLocalBodies = [
    "Kochi Corporation",
    "Nadathara Grama Panchayat",
    "Kalamassery Municipality",
  ];

  static final List<String> _sampleWards = [
    "ERAVIMANGALAM",
    "EDAPPALLY",
    "KALAMASSERY",
    "PALARIVATTOM",
  ];

  static final List<double> _sampleQuantities = [
    45.5, 32.0, 58.2, 12.5, 78.0, 24.5, 66.8, 19.0, 84.2, 38.5, 52.0, 15.8, 91.0, 28.4, 47.6
  ];

  static final List<double> _sampleRevenues = [
    1850.0, 1200.0, 2400.0, 650.0, 3100.0, 980.0, 2750.0, 820.0, 3450.0, 1560.0, 2100.0, 720.0, 3900.0, 1140.0, 1920.0
  ];

  static final List<int> _samplePickups = [
    12, 8, 15, 4, 18, 7, 14, 5, 21, 9, 13, 4, 23, 8, 11
  ];

  static AdminCollectorStats _createStatsForCollector(CollectorModel c, int index) {
    return AdminCollectorStats(
      collector: c,
      isOnDuty: index % 5 != 0, // 80% on duty, 20% off duty
      hasVehicle: index % 4 != 0, // 75% assigned, 25% no vehicle
      localBody: _sampleLocalBodies[index % _sampleLocalBodies.length],
      ward: _sampleWards[index % _sampleWards.length],
      quantityKg: _sampleQuantities[index % _sampleQuantities.length],
      revenue: _sampleRevenues[index % _sampleRevenues.length],
      pickups: _samplePickups[index % _samplePickups.length],
    );
  }

  void _loadInitialMockData() {
    final mockCollectors = [
      CollectorModel(
        id: 1,
        username: "as",
        name: "as",
        email: "as@suchigo.com",
        phone: "7592964933",
      ),
      CollectorModel(
        id: 2,
        username: "kiran",
        name: "kiran",
        email: "kiran@suchigo.com",
        phone: "7592964953",
      ),
      CollectorModel(
        id: 3,
        username: "kiran2",
        name: "kiran",
        email: "kiran2@suchigo.com",
        phone: "7592964953",
      ),
      CollectorModel(
        id: 4,
        username: "shyam",
        name: "shyam",
        email: "shyam@suchigo.com",
        phone: "7592964952",
      ),
      CollectorModel(
        id: 5,
        username: "rahul",
        name: "rahul",
        email: "rahul@suchigo.com",
        phone: "7592964911",
      ),
      CollectorModel(
        id: 6,
        username: "anoop",
        name: "anoop",
        email: "anoop@suchigo.com",
        phone: "7592964988",
      ),
      CollectorModel(
        id: 7,
        username: "mithun",
        name: "mithun",
        email: "mithun@suchigo.com",
        phone: "7592964977",
      ),
      CollectorModel(
        id: 8,
        username: "arjun",
        name: "arjun",
        email: "arjun@suchigo.com",
        phone: "7592964966",
      ),
      CollectorModel(
        id: 9,
        username: "deepak",
        name: "deepak",
        email: "deepak@suchigo.com",
        phone: "7592964955",
      ),
      CollectorModel(
        id: 10,
        username: "sreejith",
        name: "sreejith",
        email: "sreejith@suchigo.com",
        phone: "7592964944",
      ),
      CollectorModel(
        id: 11,
        username: "vijay",
        name: "vijay",
        email: "vijay@suchigo.com",
        phone: "7592964933",
      ),
      CollectorModel(
        id: 12,
        username: "ajay",
        name: "ajay",
        email: "ajay@suchigo.com",
        phone: "7592964922",
      ),
      CollectorModel(
        id: 13,
        username: "manoj",
        name: "manoj",
        email: "manoj@suchigo.com",
        phone: "7592964911",
      ),
      CollectorModel(
        id: 14,
        username: "harish",
        name: "harish",
        email: "harish@suchigo.com",
        phone: "7592964900",
      ),
      CollectorModel(
        id: 15,
        username: "pradeep",
        name: "pradeep",
        email: "pradeep@suchigo.com",
        phone: "7592964999",
      ),
    ];

    _collectorStatsList = mockCollectors
        .asMap()
        .entries
        .map((entry) => _createStatsForCollector(entry.value, entry.key))
        .toList();
  }

  Future<void> fetchAdminData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch dashboard statistics
      try {
        _dashboardData = await _apiClient.getAdminDashboard();
      } catch (e) {
        debugPrint('[AdminViewModel] getAdminDashboard error: $e');
      }

      // 2. Fetch collectors list
      try {
        final remoteCollectors = await _apiClient.getAdminCollectors();
        if (remoteCollectors.isNotEmpty) {
          _collectorStatsList = remoteCollectors
              .asMap()
              .entries
              .map((entry) => _createStatsForCollector(entry.value, entry.key))
              .toList();
        }
      } catch (e) {
        debugPrint('[AdminViewModel] getAdminCollectors error: $e');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await fetchAdminData();
  }

  Future<AdminCollectorHistoryModel?> fetchCollectorHistory(int collectorId) async {
    try {
      return await _apiClient.getAdminCollectorHistory(collectorId);
    } catch (e) {
      debugPrint('[AdminViewModel] fetchCollectorHistory error: $e');
      return null;
    }
  }

  // --- Vehicle Management ---
  List<VehicleModelItem> _vehicleModels = [];
  List<VehicleNumberItem> _vehicleNumbers = [];
  bool _isVehiclesLoading = false;

  List<VehicleModelItem> get vehicleModels => _vehicleModels;
  List<VehicleNumberItem> get vehicleNumbers => _vehicleNumbers;
  bool get isVehiclesLoading => _isVehiclesLoading;

  Future<List<VehicleModelItem>> fetchVehicleModels() async {
    _isVehiclesLoading = true;
    notifyListeners();
    try {
      final models = await _apiClient.getVehicleModels();
      _vehicleModels = models.isNotEmpty
          ? models
          : [VehicleModelItem(id: 1, name: 'Tata Ace')];
      return _vehicleModels;
    } catch (_) {
      _vehicleModels = [VehicleModelItem(id: 1, name: 'Tata Ace')];
      return _vehicleModels;
    } finally {
      _isVehiclesLoading = false;
      notifyListeners();
    }
  }

  Future<List<VehicleNumberItem>> fetchVehicleNumbers(int? modelId) async {
    try {
      final numbers = await _apiClient.getVehicleNumbers(modelId);
      _vehicleNumbers = numbers.isNotEmpty
          ? numbers
          : [
              VehicleNumberItem(
                id: 1,
                number: 'KL 07 AB 1234',
                vehicleModelId: modelId,
              )
            ];
      notifyListeners();
      return _vehicleNumbers;
    } catch (_) {
      _vehicleNumbers = [
        VehicleNumberItem(
          id: 1,
          number: 'KL 07 AB 1234',
          vehicleModelId: modelId,
        )
      ];
      notifyListeners();
      return _vehicleNumbers;
    }
  }

  Future<bool> assignVehicle({
    required int collectorId,
    required String? vehicleModel,
    required String? vehicleNumber,
    int? modelId,
  }) async {
    try {
      await _apiClient.assignVehicleToCollector(
        collectorId: collectorId,
        vehicleModel: vehicleModel,
        vehicleNumber: vehicleNumber,
        modelId: modelId,
      );

      final index =
          _collectorStatsList.indexWhere((s) => s.collector.id == collectorId);
      if (index != -1) {
        final oldStat = _collectorStatsList[index];
        final updatedCollector = oldStat.collector.copyWith(
          vehicleName: vehicleModel,
          vehicleNumber: vehicleNumber,
        );
        _collectorStatsList[index] = AdminCollectorStats(
          collector: updatedCollector,
          quantityKg: oldStat.quantityKg,
          revenue: oldStat.revenue,
          pickups: oldStat.pickups,
          isOnDuty: oldStat.isOnDuty,
          hasVehicle: vehicleModel != null && vehicleModel.isNotEmpty,
          localBody: oldStat.localBody,
          ward: oldStat.ward,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('[AdminViewModel] assignVehicle error: $e');
      return false;
    }
  }

  // --- Bags Management ---
  List<BagModel> _bags = [];
  bool _isBagsLoading = false;
  String _bagsSearchQuery = '';

  List<BagModel> get bags {
    if (_bagsSearchQuery.isEmpty) return _bags;
    final q = _bagsSearchQuery.toLowerCase();
    return _bags.where((b) {
      final size = b.size.toLowerCase();
      final desc = (b.description ?? '').toLowerCase();
      final price = b.price.toString();
      return size.contains(q) || desc.contains(q) || price.contains(q);
    }).toList();
  }

  bool get isBagsLoading => _isBagsLoading;
  String get bagsSearchQuery => _bagsSearchQuery;

  void setBagsSearchQuery(String query) {
    _bagsSearchQuery = query;
    notifyListeners();
  }

  Future<void> fetchBags() async {
    _isBagsLoading = true;
    notifyListeners();

    try {
      final remoteBags = await _apiClient.getBags();
      _bags = remoteBags.isNotEmpty ? remoteBags : _defaultBags;
    } catch (_) {
      _bags = _defaultBags;
    } finally {
      _isBagsLoading = false;
      notifyListeners();
    }
  }

  void addBag(BagModel bag) {
    _bags.add(bag);
    notifyListeners();
  }

  static final List<BagModel> _defaultBags = [
    BagModel(
      id: 1,
      size: "large",
      price: 10.00,
      description: "Small waste bag",
      isActive: true,
    ),
    BagModel(
      id: 2,
      size: "medium",
      price: 7.00,
      description: "Medium waste bag",
      isActive: true,
    ),
    BagModel(
      id: 3,
      size: "small",
      price: 5.00,
      description: "Small waste bag",
      isActive: true,
    ),
  ];

  // --- Waste Types Management ---
  List<WasteTypeModel> _wasteTypesList = [];
  bool _isWasteTypesLoading = false;
  String _wasteTypesSearchQuery = '';

  List<WasteTypeModel> get wasteTypesList {
    if (_wasteTypesSearchQuery.isEmpty) return _wasteTypesList;
    final q = _wasteTypesSearchQuery.toLowerCase();
    return _wasteTypesList.where((w) {
      final name = w.name.toLowerCase();
      final desc = (w.description ?? '').toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();
  }

  bool get isWasteTypesLoading => _isWasteTypesLoading;
  String get wasteTypesSearchQuery => _wasteTypesSearchQuery;

  void setWasteTypesSearchQuery(String query) {
    _wasteTypesSearchQuery = query;
    notifyListeners();
  }

  Future<void> fetchWasteTypes() async {
    _isWasteTypesLoading = true;
    notifyListeners();

    try {
      final remoteTypes = await _apiClient.getWasteTypes();
      _wasteTypesList =
          remoteTypes.isNotEmpty ? remoteTypes : _defaultWasteTypes;
    } catch (_) {
      _wasteTypesList = _defaultWasteTypes;
    } finally {
      _isWasteTypesLoading = false;
      notifyListeners();
    }
  }

  void addWasteType(WasteTypeModel wasteType) {
    _wasteTypesList.add(wasteType);
    notifyListeners();
  }

  static final List<WasteTypeModel> _defaultWasteTypes = [
    WasteTypeModel(
      id: 1,
      name: "Adult Daiper",
      description: "Adult Daiper",
      isActive: true,
    ),
    WasteTypeModel(
      id: 2,
      name: "Compostable Materials",
      description: "Materials suitable for composting",
      isActive: true,
    ),
    WasteTypeModel(
      id: 3,
      name: "Hair",
      description: "Hair Waste",
      isActive: true,
    ),
    WasteTypeModel(
      id: 4,
      name: "Hazardous Waste",
      description: "Dangerous materials requiring special handling",
      isActive: true,
    ),
    WasteTypeModel(
      id: 5,
      name: "Kids Daiper",
      description: "Kids Daiper",
      isActive: true,
    ),
    WasteTypeModel(
      id: 6,
      name: "Medical Waste",
      description: "Medical wastes",
      isActive: true,
    ),
    WasteTypeModel(
      id: 7,
      name: "SANITARY PAD",
      description: "Sanitary pad waste",
      isActive: true,
    ),
  ];
}
