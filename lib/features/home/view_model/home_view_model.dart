import 'package:flutter/material.dart';
import 'package:suchigo_collector/features/auth/view_model/auth_view_model.dart';
import 'package:suchigo_collector/helpers/sp_helper.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<DistrictModel> _districts = [];
  DistrictModel? _selectedDistrict;
  List<LocalBodyModel> _localBodies = [];
  LocalBodyModel? _selectedLocalBody;
  List<WardModel> _wards = [];
  WardModel? _selectedWard;

  bool _isLoadingDistricts = false;
  bool _isLoadingLocalBodies = false;
  bool _isLoadingWards = false;
  bool _isSavingProfile = false;
  bool _isProfileRecentlySaved = false;

  HomeViewModel() {
    AuthViewModel.addOnLogoutCallback(clearSelections);
  }

  @override
  void dispose() {
    AuthViewModel.removeOnLogoutCallback(clearSelections);
    super.dispose();
  }

  List<DistrictModel> get districts => _districts;
  DistrictModel? get selectedDistrict => _selectedDistrict;
  List<LocalBodyModel> get localBodies => _localBodies;
  LocalBodyModel? get selectedLocalBody => _selectedLocalBody;
  List<WardModel> get wards => _wards;
  WardModel? get selectedWard => _selectedWard;

  bool get isLoadingDistricts => _isLoadingDistricts;
  bool get isLoadingLocalBodies => _isLoadingLocalBodies;
  bool get isLoadingWards => _isLoadingWards;
  bool get isSavingProfile => _isSavingProfile;
  bool get isProfileRecentlySaved => _isProfileRecentlySaved;

  Future<void> fetchDistricts() async {
    _isLoadingDistricts = true;
    notifyListeners();

    try {
      final districts = await _apiClient.getDistricts();
      _districts = districts;
      _isLoadingDistricts = false;
      notifyListeners();
    } catch (_) {
      _isLoadingDistricts = false;
      notifyListeners();
    }
  }

  Future<void> fetchLocalBodies(int districtId) async {
    _isLoadingLocalBodies = true;
    _localBodies = [];
    _wards = [];
    _selectedWard = null;
    notifyListeners();

    try {
      final localBodies = await _apiClient.getLocalBodies(districtId);
      _localBodies = localBodies;
      _isLoadingLocalBodies = false;
      notifyListeners();
    } catch (_) {
      _isLoadingLocalBodies = false;
      notifyListeners();
    }
  }

  Future<void> fetchWards(int localBodyId) async {
    _isLoadingWards = true;
    _wards = [];
    notifyListeners();

    try {
      final wards = await _apiClient.getWards(localBodyId);
      _wards = wards;
      _isLoadingWards = false;
      notifyListeners();
    } catch (_) {
      _wards = [];
      _isLoadingWards = false;
      notifyListeners();
    }
  }

  void selectDistrict(DistrictModel? district) {
    _selectedDistrict = district;
    _selectedLocalBody = null;
    _selectedWard = null;
    _isProfileRecentlySaved = false;
    notifyListeners();
    if (district != null) {
      fetchLocalBodies(district.id);
    }
  }

  void selectLocalBody(LocalBodyModel? localBody) {
    _selectedLocalBody = localBody;
    _selectedWard = null;
    _isProfileRecentlySaved = false;
    notifyListeners();
    if (localBody != null) {
      fetchWards(localBody.id);
    }
  }

  Future<void> selectWard(WardModel? ward) async {
    _selectedWard = ward;
    _isProfileRecentlySaved = false;
    notifyListeners();
    if (ward != null) {
      await SpHelper.saveString('profile_saved_ward', ward.displayName);
      await SpHelper.saveString('profile_saved_ward_name', ward.name);
      await SpHelper.saveString('profile_saved_ward_id', ward.id.toString());
      await SpHelper.saveString(
          'profile_saved_ward_number', ward.wardNumber ?? '1');
    } else {
      await SpHelper.remove('profile_saved_ward');
      await SpHelper.remove('profile_saved_ward_name');
      await SpHelper.remove('profile_saved_ward_id');
      await SpHelper.remove('profile_saved_ward_number');
    }
  }

  Future<bool> saveProfile() async {
    if (_selectedDistrict == null || _selectedLocalBody == null) {
      return false;
    }

    _isSavingProfile = true;
    notifyListeners();

    try {
      if (_selectedWard != null) {
        await SpHelper.saveString(
            'profile_saved_ward', _selectedWard!.displayName);
        await SpHelper.saveString(
            'profile_saved_ward_name', _selectedWard!.name);
        await SpHelper.saveString(
            'profile_saved_ward_id', _selectedWard!.id.toString());
        await SpHelper.saveString(
            'profile_saved_ward_number', _selectedWard!.wardNumber ?? '1');
      } else {
        await SpHelper.remove('profile_saved_ward');
        await SpHelper.remove('profile_saved_ward_name');
        await SpHelper.remove('profile_saved_ward_id');
        await SpHelper.remove('profile_saved_ward_number');
      }
      await SpHelper.saveString(
          'profile_saved_district_id', _selectedDistrict!.id.toString());
      await SpHelper.saveString(
          'profile_saved_district', _selectedDistrict!.name);
      await SpHelper.saveString(
          'profile_saved_localbody_id', _selectedLocalBody!.id.toString());
      await SpHelper.saveString(
          'profile_saved_localbody', _selectedLocalBody!.name);

      _isSavingProfile = false;
      _isProfileRecentlySaved = true;
      notifyListeners();
      return true;
    } catch (_) {
      _isSavingProfile = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSavedProfile({bool forceRefresh = false}) async {
    try {
      // 1. Fetch districts if empty or forceRefresh
      if (forceRefresh || _districts.isEmpty) {
        await fetchDistricts();
      }

      final savedDistrictIdStr =
          await SpHelper.getString('profile_saved_district_id');
      final savedDistrictName =
          await SpHelper.getString('profile_saved_district');
      final savedLocalBodyIdStr =
          await SpHelper.getString('profile_saved_localbody_id');
      final savedLocalBodyName =
          await SpHelper.getString('profile_saved_localbody');
      final savedWardIdStr = await SpHelper.getString('profile_saved_ward_id');
      final savedWardName = await SpHelper.getString('profile_saved_ward');
      final savedWardNumber =
          await SpHelper.getString('profile_saved_ward_number');

      if ((savedDistrictIdStr != null || savedDistrictName != null) &&
          _districts.isNotEmpty) {
        final districtId = int.tryParse(savedDistrictIdStr ?? '');
        DistrictModel? matchedDistrict;
        try {
          matchedDistrict = _districts.firstWhere(
            (d) =>
                (districtId != null && d.id == districtId) ||
                (savedDistrictName != null &&
                    d.name.trim().toLowerCase() ==
                        savedDistrictName.trim().toLowerCase()),
          );
        } catch (_) {}

        if (matchedDistrict != null) {
          _selectedDistrict = matchedDistrict;
          notifyListeners();

          // 2. Fetch local bodies for this district
          await fetchLocalBodies(matchedDistrict.id);

          if ((savedLocalBodyIdStr != null || savedLocalBodyName != null) &&
              _localBodies.isNotEmpty) {
            final localBodyId = int.tryParse(savedLocalBodyIdStr ?? '');
            LocalBodyModel? matchedLocalBody;
            try {
              matchedLocalBody = _localBodies.firstWhere(
                (lb) =>
                    (localBodyId != null && lb.id == localBodyId) ||
                    (savedLocalBodyName != null &&
                        lb.name.trim().toLowerCase() ==
                            savedLocalBodyName.trim().toLowerCase()),
              );
            } catch (_) {}

            if (matchedLocalBody != null) {
              _selectedLocalBody = matchedLocalBody;
              notifyListeners();

              // 3. Fetch wards for this local body
              await fetchWards(matchedLocalBody.id);

              if ((savedWardIdStr != null ||
                      savedWardName != null ||
                      savedWardNumber != null) &&
                  _wards.isNotEmpty) {
                final wardId = int.tryParse(savedWardIdStr ?? '');
                WardModel? matchedWard;
                try {
                  matchedWard = _wards.firstWhere(
                    (w) =>
                        (wardId != null && w.id == wardId) ||
                        (savedWardNumber != null &&
                            (w.wardNumber == savedWardNumber ||
                                w.wardNumber == "Ward $savedWardNumber")) ||
                        (savedWardName != null &&
                            (w.displayName.trim().toLowerCase() ==
                                    savedWardName.trim().toLowerCase() ||
                                w.name.trim().toLowerCase() ==
                                    savedWardName.trim().toLowerCase())),
                  );
                } catch (_) {}

                _selectedWard = matchedWard;
              }
              _isProfileRecentlySaved = true;
              notifyListeners();
            }
          }
        }
      } else if (_selectedDistrict != null) {
        // In case district was manually selected, refresh its local bodies and wards
        await fetchLocalBodies(_selectedDistrict!.id);
        if (_selectedLocalBody != null) {
          await fetchWards(_selectedLocalBody!.id);
        }
      }
    } catch (e) {
      debugPrint('[HomeViewModel] loadSavedProfile error: $e');
    }
  }

  Future<void> clearSelections({bool clearSavedPrefs = false}) async {
    _selectedDistrict = null;
    _selectedLocalBody = null;
    _selectedWard = null;
    _localBodies = [];
    _wards = [];
    _isLoadingLocalBodies = false;
    _isLoadingWards = false;
    _isSavingProfile = false;
    _isProfileRecentlySaved = false;

    if (clearSavedPrefs) {
      try {
        await SpHelper.remove('profile_saved_ward');
        await SpHelper.remove('profile_saved_ward_name');
        await SpHelper.remove('profile_saved_ward_id');
        await SpHelper.remove('profile_saved_ward_number');
        await SpHelper.remove('profile_saved_district');
        await SpHelper.remove('profile_saved_district_id');
        await SpHelper.remove('profile_saved_localbody');
        await SpHelper.remove('profile_saved_localbody_id');
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> reset() async {
    await clearSelections();
    _districts = [];
    notifyListeners();
  }
}
