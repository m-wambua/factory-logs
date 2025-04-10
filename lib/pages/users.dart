import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class User {
  final String id;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? password;
  final UserRole? role;
  final bool? isDisabled;
  final bool? isActive;
  final UserStatus status;

  User({
    required this.id,
    this.username,
    this.email,
    this.phoneNumber,
    this.password,
    this.role,
    this.isDisabled = false,
    this.isActive = true,
    this.status = UserStatus.pending
  });

  // Convert User object to JSON string
 
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role?.toString(), // Convert enum to string
      'password': password,
      'isDisabled': isDisabled,
      'isActive': isActive,
      'status': status.toString(), // Add status to JSON
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phoneNumber,
    String? password,
    UserRole? role,
    bool? isDisabled,
    UserStatus? status,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      role: role ?? this.role,
      isDisabled: isDisabled ?? this.isDisabled,
      status: status ?? this.status,
    );
  }

  factory User.fromApplication(UserApplication application, UserRole role) {
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate unique ID
      username: application.username,
      email: application.email,
      phoneNumber: application.phoneNumber,
      role: role,
      password: application.password,
      isDisabled: false,
      isActive: true,
    );
  }
   factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
      role: _parseUserRole(json['role'] ?? 'UserRole.user'),
      isDisabled: json['isDisabled'] ?? false,
      isActive: json['isActive'] ?? true,
      status: _parseUserStatus(json['status'] ?? 'UserStatus.pending'),
    );
  }

  static UserRole _parseUserRole(String role) {
    switch (role) {
      case 'UserRole.admin':
        return UserRole.admin;
      case 'UserRole.manager':
        return UserRole.manager;
      case 'UserRole.user':
        return UserRole.user;
      default:
        return UserRole.user;
    }
  }

  static UserStatus _parseUserStatus(String status) {
    switch (status) {
      case 'UserStatus.approved':
        return UserStatus.approved;
      case 'UserStatus.rejected':
        return UserStatus.rejected;
      case 'UserStatus.pending':
        return UserStatus.pending;
      default:
        return UserStatus.pending;
    }
  }
  static Future<String> get _usersFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/users.json';
  }

  static Future<void> saveUsers(List<User> users) async {
    try {
      final file = File(await _usersFilePath);
      final jsonUsers = users.map((user) => user.toJson()).toList();
      await file.writeAsString(json.encode(jsonUsers));
    } catch (e) {
      print("Error saving users: $e");
    }
  }

  static Future<List<User>> loadUsers() async {
    try {
      final file = File(await _usersFilePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print("Error loading users: $e");
    }
    return [];
  }
}

// Helper function to save a new user


enum UserRole {
  admin,
  user,
  manager,
}

enum UserStatus { pending, approved, rejected, deleted,disabled }

enum SignInMethod {
  username,
  email,
  phoneNumber,
}

class UserApplication {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String password;
  final DateTime applicationDate;

  UserApplication({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.password,
    required this.applicationDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'password': password,
        'applicationDate': applicationDate.toIso8601String()
      };
  factory UserApplication.fromJson(Map<String, dynamic> json) =>
      UserApplication(
          username: json['username'],
          applicationDate: DateTime.parse(json['applicationDate']),
          email: json['email'],
          firstName: json['firstName'],
          lastName: json['lastName'],
          phoneNumber: json['phoneNumber'],
          password: json['password'],
          id: json['id']);
static Future<String> get _applicationsFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/applications.json';
  }

  static Future<void> saveApplications(List<UserApplication> applications) async {
    try {
      final file = File(await _applicationsFilePath);
      final jsonApplications = applications.map((app) => app.toJson()).toList();
      await file.writeAsString(json.encode(jsonApplications));
    } catch (e) {
      print("Error saving applications: $e");
    }
  }

  static Future<List<UserApplication>> loadApplications() async {
    try {
      final file = File(await _applicationsFilePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((json) => UserApplication.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print("Error loading applications: $e");
    }
    return [];
  }

  static Future<void> maintainApplications(List<UserApplication> applications,
      {int maxEntries = 500}) async {
    if (applications.length > maxEntries) {
      applications = applications.sublist(applications.length - maxEntries);
      await saveApplications(applications);
    }
  }
}
