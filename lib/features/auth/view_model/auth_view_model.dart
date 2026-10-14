import 'package:flutter/material.dart';
import 'package:suchigo_collector/models/collector_model.dart';
import 'package:suchigo_collector/services/api_client.dart';

enum UserRole { collector, adminPortal }

class AuthViewModel extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  String? _errorMessage;
  AuthResponseModel? _authResponse;
  CollectorVehicleModel? _vehicle;
  CollectorBagStatusModel? _bagStatus;

  UserRole _loginSelectedRole = UserRole.collector;
  bool _obscureLoginPassword = true;

  UserRole _registerSelectedRole = UserRole.collector;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthResponseModel? get authResponse => _authResponse;
  CollectorModel? get collector => _apiClient.currentCollector;
  CollectorVehicleModel? get vehicle => _vehicle;
  CollectorBagStatusModel? get bagStatus => _bagStatus;
  bool get isLoggedIn => _apiClient.authToken != null;
  String? get userRole => _apiClient.userRole;
  bool get isAdmin => _apiClient.userRole == 'admin';

  UserRole get loginSelectedRole => _loginSelectedRole;
  bool get obscureLoginPassword => _obscureLoginPassword;

  UserRole get registerSelectedRole => _registerSelectedRole;
  bool get obscureRegisterPassword => _obscureRegisterPassword;
  bool get obscureRegisterConfirmPassword => _obscureRegisterConfirmPassword;

  void setLoginRole(UserRole role) {
    _loginSelectedRole = role;
    notifyListeners();
  }

  void toggleObscureLoginPassword() {
    _obscureLoginPassword = !_obscureLoginPassword;
    notifyListeners();
  }

  void setRegisterRole(UserRole role) {
    _registerSelectedRole = role;
    notifyListeners();
  }

  void toggleObscureRegisterPassword() {
    _obscureRegisterPassword = !_obscureRegisterPassword;
    notifyListeners();
  }

  void toggleObscureRegisterConfirmPassword() {
    _obscureRegisterConfirmPassword = !_obscureRegisterConfirmPassword;
    notifyListeners();
  }

  void notifyFormChanged() {
    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
    String? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _authResponse = await _apiClient.login(
        username: username,
        password: password,
        role: role,
      );

      // If login succeeds and collector ID exists, load additional profile details
      if (_authResponse?.collector != null) {
        final collectorId = _authResponse!.collector!.id;
        try {
          _vehicle = await _apiClient.getCollectorVehicle(collectorId);
        } catch (_) {}

        try {
          _bagStatus = await _apiClient.getCollectorBagStatus(collectorId);
        } catch (_) {}
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkSavedSession() async {
    await _apiClient.ensureSessionLoaded();
    if (_apiClient.authToken != null && _apiClient.authToken!.isNotEmpty) {
      if (_apiClient.currentCollector != null) {
        final collectorId = _apiClient.currentCollector!.id;
        try {
          _vehicle = await _apiClient.getCollectorVehicle(collectorId);
        } catch (_) {}
        try {
          _bagStatus = await _apiClient.getCollectorBagStatus(collectorId);
        } catch (_) {}
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> fetchCollectorVehicle() async {
    final collectorId =
        _authResponse?.collector?.id ?? _apiClient.currentCollector?.id;
    if (collectorId != null) {
      try {
        _vehicle = await _apiClient.getCollectorVehicle(collectorId);
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> logout() async {
    _isLoading = false;
    _errorMessage = null;
    await _apiClient.clearSession();
    _authResponse = null;
    _vehicle = null;
    _bagStatus = null;
    notifyListeners();
  }
}
