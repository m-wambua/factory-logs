import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String? username;
  final String? email;

  final String? phoneNumber;
  final String password;

  final UserRole role;
  final bool? isDisabled;
  final bool? isActive;

  User({
    required this.id,
    this.username,
    this.email,
    this.phoneNumber,
    required this.password,
    required this.role,
    this.isDisabled = false,
    this.isActive = true,
  });

  String toJson() {
    return json.encode({
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': role.toString(),
      'isDisabled': isDisabled,
      'isActive': isActive,
    });
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phoneNumber,
    String? password,
    UserRole? role,
    bool? isDisabled,
  }) {
    return User(
      id: id ?? this.id,
      password: password ?? this.password,
      role: role ?? this.role,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }

  factory User.fromApplication(UserApplication application, UserRole role) {
    return User(
      id: application.id,
      username: application.username,
      email: application.email,
      phoneNumber: application.phoneNumber,
      password: application.password,
      role: role,
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
        role: UserRole.values.firstWhere((e) => e.toString() == json['role'],
            orElse: () => UserRole.user),
        isDisabled: json['isDisabled'],
        isActive: json['isActive']);
  }
  static Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonUsers = users.map((user) => user.toJson()).toList();
    await prefs.setStringList(
        'active_users', jsonUsers.map((user) => json.encode(user)).toList());
  }

  Future<void> saveNewUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users') ?? [];
    users.add(user.toJson());
    await prefs.setStringList('Users', users);
  }
}

enum UserRole { admin, user, manager }

enum SignInMethod { username, email, phoneNumber }

class UserApplication {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String password;
  final DateTime applicationDate;

  UserApplication({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.applicationDate,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'applicationDate': applicationDate.toIso8601String()
      };

  factory UserApplication.fromJson(Map<String, dynamic> json) =>
      UserApplication(
          id: json['id'],
          firstName: json['firstName'],
          lastName: json['lastName'],
          username: json['username'],
          email: json['email'],
          phoneNumber: json['phoneNumber'],
          password: json['password'],
          applicationDate: DateTime.parse(json['applicationDate']));

  static Future<void> saveApplication(
      List<UserApplication> applications) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonApplications =
        applications.map((application) => application.toJson()).toList();
    await prefs.setStringList(
        'user_application',
        jsonApplications
            .map((application) => json.encode(application))
            .toList());
  }

  static Future<void> maintenanceApplications(
      List<UserApplication> applications,
      {int maxEntries = 500}) async {
    if (applications.length > maxEntries) {
      final trimmedApplications =
          applications.sublist(applications.length = maxEntries);
      await saveApplication(trimmedApplications);
    }
  }
}
