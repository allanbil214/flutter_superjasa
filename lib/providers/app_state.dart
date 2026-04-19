import 'package:flutter/material.dart';
import '../data/services/mock_data_service.dart';
import '../data/models/user_model.dart';

class AppState extends ChangeNotifier {
  final MockDataService _dataService = MockDataService();
  
  UserModel? _currentUser;
  UserRole? _currentRole;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  UserRole? get currentRole => _currentRole;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  MockDataService get dataService => _dataService;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> loginAsRole(UserRole role) async {
    setLoading(true);
    try {
      _currentRole = role;
      
      // Load users and find first active user with this role
      final users = await _dataService.getUsers();
      
      UserModel? defaultUser;
      
      switch (role) {
        case UserRole.customer:
          defaultUser = users.firstWhere(
            (u) => u.role == UserRole.customer && u.isActive,
            orElse: () => users.first,
          );
          break;
        case UserRole.employee:
          defaultUser = users.firstWhere(
            (u) => u.role == UserRole.employee && u.isActive,
            orElse: () => users.first,
          );
          break;
        case UserRole.admin:
          defaultUser = users.firstWhere(
            (u) => u.role == UserRole.admin && u.isActive,
            orElse: () => users.first,
          );
          break;
        case UserRole.superAdmin:
          defaultUser = users.firstWhere(
            (u) => u.role == UserRole.superAdmin && u.isActive,
            orElse: () => users.first,
          );
          break;
      }
      
      _currentUser = defaultUser;
      
      // Preload common data
      await _dataService.getDivisions();
      await _dataService.getServices();
      
      // Load notifications for this user
      if (_currentUser != null) {
        await _dataService.getNotificationsByUser(_currentUser!.id);
      }
    } catch (e) {
      debugPrint('Error logging in: $e');
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  void updateCurrentUser({
    String? name,
    String? phone,
    String? address,
    String? avatar,
  }) {
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        email: _currentUser!.email,
        phone: phone ?? _currentUser!.phone,
        role: _currentUser!.role,
        avatar: avatar ?? _currentUser!.avatar,
        address: address ?? _currentUser!.address,
        isActive: _currentUser!.isActive,
        createdAt: _currentUser!.createdAt,
      );
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _currentRole = null;
    notifyListeners();
  }

  void switchRole(UserRole newRole) async {
    await loginAsRole(newRole);
  }
  
  // Helper getters
  String get welcomeMessage {
    if (_currentUser == null) return '';
    return 'Halo, ${_currentUser!.name}!';
  }
  
  int get currentUserId => _currentUser?.id ?? 0;
  
  bool get isCustomer => _currentRole == UserRole.customer;
  bool get isEmployee => _currentRole == UserRole.employee;
  bool get isAdmin => _currentRole == UserRole.admin;
  bool get isSuperAdmin => _currentRole == UserRole.superAdmin;
}