import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  final UserService _userService = UserService();
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // Initialize the provider by checking if a user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentUser = await _userService.getCurrentUser();
    } catch (e) {
      print('Error initializing user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Log in a user
  Future<void> login(String email, String password) async {
    try {
      _currentUser = await _userService.loginUser(email, password);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Register a new user
  Future<void> register(String email, String password, {String? name}) async {
    try {
      _currentUser = await _userService.registerUser(email, password, name: name);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Log out the current user
  Future<void> logout() async {
    await _userService.logout();
    _currentUser = null;
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile(String name, {String? photoUrl}) async {
    try {
      _currentUser = await _userService.updateUserProfile(name, photoUrl);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
} 