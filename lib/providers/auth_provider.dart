import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role = 'user',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'] ?? 'user',
    );
  }
}

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  // Mockup users
  final Map<String, User> _mockUsers = {
    'user@gmail.com': User(
      id: '1',
      email: 'user@gmail.com',
      firstName: 'John',
      lastName: 'Doe',
      role: 'user',
    ),
    'admin@gmail.com': User(
      id: '2',
      email: 'admin@gmail.com',
      firstName: 'Admin',
      lastName: 'User',
      role: 'admin',
    ),
  };

  final Map<String, String> _mockPasswords = {
    'user@gmail.com': '111',
    'admin@gmail.com': '222',
  };

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      final mockUser = _mockUsers[email];
      final correctPassword = _mockPasswords[email];

      if (mockUser != null && correctPassword == password) {
        _user = mockUser;
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _user = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Check if email already exists
      if (_mockUsers.containsKey(email)) {
        return false;
      }

      // Create new user
      final newUser = User(
        id: (DateTime.now().millisecondsSinceEpoch % 10000).toString(),
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      // Add to mock database
      _mockUsers[email] = newUser;
      _mockPasswords[email] = password;

      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    
    if (userEmail != null && _mockUsers.containsKey(userEmail)) {
      _user = _mockUsers[userEmail];
      notifyListeners();
    }
  }
}
