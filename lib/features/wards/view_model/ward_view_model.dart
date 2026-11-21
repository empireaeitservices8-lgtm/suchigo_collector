import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';

class WardViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<WardModel> _wards = [];
  List<LocationPickupModel> _savedLocations = [];
  bool _isLoading = true;
  String _currentCoordinates = "Fetching location...";
  String _searchQuery = "";
  String _selectedFilter = "Submit";

  WardViewModel() {
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
    _wards = [];
    _savedLocations = [];
    _isLoading = true;
    _currentCoordinates = "Fetching location...";
    _searchQuery = "";
    _selectedFilter = "Submit";
    notifyListeners();
  }

  List<WardModel> get wards => _wards;
  List<LocationPickupModel> get savedLocations => _savedLocations;
  bool get isLoading => _isLoading;
  String get currentCoordinates => _currentCoordinates;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  List<WardModel> get filteredWards {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _wards;
    return _wards
        .where((w) =>
            w.displayName.toLowerCase().contains(query) ||
            w.name.toLowerCase().contains(query))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = "";
    notifyListeners();
  }

  void setSelectedFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> fetchLiveLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _currentCoordinates = "Location services disabled";
        notifyListeners();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _currentCoordinates = "Location permission denied";
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _currentCoordinates = "Location permission permanently denied";
        notifyListeners();
        return;
      }

      // Fast cached position
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        _currentCoordinates =
            "${lastPosition.latitude.toStringAsFixed(7)}, ${lastPosition.longitude.toStringAsFixed(5)}";
        notifyListeners();
      }

      // Fresh position with balanced accuracy and quick timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );

      _currentCoordinates =
          "${position.latitude.toStringAsFixed(7)}, ${position.longitude.toStringAsFixed(5)}";
      notifyListeners();
    } catch (_) {
      if (_currentCoordinates == "Fetching location...") {
        _currentCoordinates = "Location unavailable";
        notifyListeners();
      }
    }
  }

  Future<void> loadWardAndLocationData({
    int? localBodyId,
    WardModel? selectedWard,
    String? selectedWardName,
  }) async {
    _searchQuery = "";
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch locations and official wards concurrently to minimize latency
      final results = await Future.wait([
        _apiClient.getLocations().catchError((e) {
          debugPrint("Failed to fetch locations: $e");
          return <LocationPickupModel>[];
        }),
        _apiClient.getWards(localBodyId).catchError((e) {
          debugPrint("Failed to fetch wards: $e");
          return <WardModel>[];
        }),
      ]);

      final fetchedLocations = results[0] as List<LocationPickupModel>;
      List<WardModel> apiWards = results[1] as List<WardModel>;

      // Check if user explicitly selected a specific ward from the profile section
      final bool hasSelectedWard = selectedWard != null ||
          (selectedWardName != null && selectedWardName.trim().isNotEmpty);
      final targetWardName = selectedWard?.name ?? selectedWardName;
      final targetWardNumber = selectedWard?.wardNumber;

      // Fallback: extract unique wards from fetchedLocations if apiWards is empty
      if (apiWards.isEmpty && fetchedLocations.isNotEmpty) {
        final uniqueWardNames = <String>[];
        for (final loc in fetchedLocations) {
          if (loc.ward != null && loc.ward!.trim().isNotEmpty) {
            final wName = loc.ward!.trim();
            if (!uniqueWardNames
                .any((name) => name.toLowerCase() == wName.toLowerCase())) {
              uniqueWardNames.add(wName);
            }
          }
        }
        if (uniqueWardNames.isNotEmpty) {
          apiWards = uniqueWardNames.asMap().entries.map((entry) {
            return WardModel(
              id: entry.key + 1,
              name: entry.value,
              wardNumber: "${entry.key + 1}",
              localbody: localBodyId,
            );
          }).toList();
        }
      }

      // If still empty, supply default wards
      if (apiWards.isEmpty) {
        apiWards = [];
      }

      List<WardModel> profileWards = [];

      // 2. If a specific ward was selected from the profile section, show ONLY that ward
      if (hasSelectedWard &&
          targetWardName != null &&
          targetWardName.trim().isNotEmpty) {
        WardModel? matchedWard;
        final targetFormatted =
            WardModel.formatWardName(targetWardName, targetWardNumber);
        for (final w in apiWards) {
          if (targetWardNumber != null &&
              targetWardNumber.isNotEmpty &&
              w.wardNumber == targetWardNumber) {
            matchedWard = w;
            break;
          }
          if (w.displayName.toLowerCase() == targetFormatted.toLowerCase() ||
              w.name.trim().toLowerCase() ==
                  targetWardName.trim().toLowerCase()) {
            matchedWard = w;
            break;
          }
        }

        profileWards = [
          matchedWard ??
              selectedWard ??
              WardModel(
                id: selectedWard?.id ?? 1,
                name: targetWardName.trim(),
                wardNumber: targetWardNumber ??
                    RegExp(r'^(\d+)\s*-')
                        .firstMatch(targetWardName)
                        ?.group(1) ??
                    "",
                localbody: localBodyId,
              )
        ];
      } else {
        // 3. No specific ward selected in profile section -> Show ALL wards!
        profileWards = apiWards;
      }

      _wards = profileWards;
      _savedLocations = fetchedLocations;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      final bool hasSelectedWard = selectedWard != null ||
          (selectedWardName != null && selectedWardName.trim().isNotEmpty);
      if (hasSelectedWard) {
        final targetWardName = selectedWard?.name ?? selectedWardName ?? "";
        final targetWardNumber = selectedWard?.wardNumber ?? "";
        _wards = [
          selectedWard ??
              WardModel(
                id: 1,
                name: targetWardName.trim(),
                wardNumber: targetWardNumber,
                localbody: localBodyId,
              )
        ];
      } else {
        _wards = [];
      }
      _isLoading = false;
      notifyListeners();
    }
  }
}
