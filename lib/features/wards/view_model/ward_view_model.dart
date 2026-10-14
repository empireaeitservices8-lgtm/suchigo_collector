import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

      // Fresh accurate GPS position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
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
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedLocations = await _apiClient.getLocations();

      // Check if user explicitly selected a specific ward from the profile section
      final bool hasSelectedWard = selectedWard != null ||
          (selectedWardName != null && selectedWardName.trim().isNotEmpty);
      final targetWardName = selectedWard?.name ?? selectedWardName;
      final targetWardNumber = selectedWard?.wardNumber;

      // 1. Fetch official wards from API if available
      List<WardModel> apiWards = [];
      try {
        apiWards = await _apiClient.getWards(localBodyId);
      } catch (_) {}

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
        apiWards = [
          WardModel(
            id: 1,
            name: "Neericode West",
            wardNumber: "1",
            localbody: localBodyId,
          ),
          WardModel(
            id: 2,
            name: "Neericode East",
            wardNumber: "2",
            localbody: localBodyId,
          ),
          WardModel(
            id: 3,
            name: "Panchayat Head Quarters",
            wardNumber: "3",
            localbody: localBodyId,
          ),
          WardModel(
            id: 4,
            name: "Koduvazhanga South",
            wardNumber: "4",
            localbody: localBodyId,
          ),
          WardModel(
            id: 5,
            name: "Koduvazhanga North",
            wardNumber: "5",
            localbody: localBodyId,
          ),
        ];
      }

      List<WardModel> profileWards = [];

      // 2. If a specific ward was selected from the profile section, show ONLY that ward
      if (hasSelectedWard && targetWardName != null && targetWardName.trim().isNotEmpty) {
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
              w.name.trim().toLowerCase() == targetWardName.trim().toLowerCase()) {
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
                    RegExp(r'^(\d+)\s*-').firstMatch(targetWardName)?.group(1) ??
                    "1",
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
        final targetWardName = selectedWard?.name ?? selectedWardName ?? "Ward 1";
        final targetWardNumber = selectedWard?.wardNumber ?? "1";
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
        _wards = [
          WardModel(
            id: 1,
            name: "Neericode West",
            wardNumber: "1",
            localbody: localBodyId,
          ),
          WardModel(
            id: 2,
            name: "Neericode East",
            wardNumber: "2",
            localbody: localBodyId,
          ),
          WardModel(
            id: 3,
            name: "Panchayat Head Quarters",
            wardNumber: "3",
            localbody: localBodyId,
          ),
          WardModel(
            id: 4,
            name: "Koduvazhanga South",
            wardNumber: "4",
            localbody: localBodyId,
          ),
          WardModel(
            id: 5,
            name: "Koduvazhanga North",
            wardNumber: "5",
            localbody: localBodyId,
          ),
        ];
      }
      _isLoading = false;
      notifyListeners();
    }
  }
}
