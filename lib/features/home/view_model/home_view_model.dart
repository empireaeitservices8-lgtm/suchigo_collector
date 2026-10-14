import 'package:flutter/material.dart';
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
      if (wards.isNotEmpty) {
        _wards = wards;
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
      _isLoadingWards = false;
      notifyListeners();
    } catch (_) {
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
      ];
      _isLoadingWards = false;
      notifyListeners();
    }
  }

  void selectDistrict(DistrictModel? district) {
    _selectedDistrict = district;
    _selectedLocalBody = null;
    _selectedWard = null;
    notifyListeners();
    if (district != null) {
      fetchLocalBodies(district.id);
    }
  }

  void selectLocalBody(LocalBodyModel? localBody) {
    _selectedLocalBody = localBody;
    _selectedWard = null;
    notifyListeners();
    if (localBody != null) {
      fetchWards(localBody.id);
    }
  }

  Future<void> selectWard(WardModel? ward) async {
    _selectedWard = ward;
    notifyListeners();
    if (ward != null) {
      await SpHelper.saveString('profile_saved_ward', ward.displayName);
      await SpHelper.saveString(
          'profile_saved_ward_number', ward.wardNumber ?? '1');
    } else {
      await SpHelper.remove('profile_saved_ward');
      await SpHelper.remove('profile_saved_ward_number');
    }
  }

  Future<bool> saveProfile() async {
    if (_selectedDistrict == null ||
        _selectedLocalBody == null ||
        _selectedWard == null) {
      return false;
    }

    _isSavingProfile = true;
    notifyListeners();

    try {
      await SpHelper.saveString(
          'profile_saved_ward', _selectedWard!.displayName);
      await SpHelper.saveString(
          'profile_saved_ward_number', _selectedWard!.wardNumber ?? '1');
      await SpHelper.saveString(
          'profile_saved_district', _selectedDistrict!.name);
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
}
