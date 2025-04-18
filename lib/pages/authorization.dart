import 'package:collector/admindash.dart';
import 'package:collector/main.dart';
import 'package:collector/pages/apis/apis.dart';
import 'package:collector/pages/pages2/login_page.dart';
import 'package:collector/pages/pages2/welcome_page.dart';
import 'package:collector/pages/users.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // Added import for Provider

import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  List<UserActivity> _userActivities = [];
  List<User> _users = [];
  List<UserApplication> _pendingApplications = [];
  List<UserApplication> _acceptedApplications = [];
  List<UserApplication> _rejectedApplications = [];

  Map<String, dynamic> _appStatus = {
    'lastOpened': DateTime.now().toIso8601String(),
    'lastClosed': DateTime.now().toIso8601String(),
    'normalShutdown': true,
  };

  // Getters
  User? get currentUser => _currentUser;
  List<UserActivity> get userActivities => _userActivities;
  List<User> get users => _users;
  List<UserApplication> get pendingApplications => _pendingApplications;
  List<User> get activeUsers =>
      _users.where((user) => user.isActive ?? false).toList();

  // Return the list of active users
  AuthProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _ensureDirectoriesExist();
      await _loadAppStatus(); // Make sure app status is loaded first

      // Wait for all data to be loaded before continuing
      await Future.wait([
        _loadUsers(),
        _loadUserActivities(),
        _loadApplications(),
      ]);
      print("Data initialization complete"); // Add debug logging
    } catch (e) {
      print("Error initializing data: $e");
      // Initialize with empty data as fallback
      _users = [];
      _userActivities = [];
      _pendingApplications = [];
    }
    notifyListeners(); // Notify listeners after all data is loaded
  }

  Future<void> _ensureDirectoriesExist() async {
    final directory = await getApplicationDocumentsDirectory();
    final paths = [
      _pendingApplicationsPath,
      _acceptedApplicationsPath,
      _rejectedApplicationsPath,
      _usersFilePath,
      _activitiesFilePath,
      _appStatusFilePath,
    ];

    final resolvedPaths = await Future.wait(paths);

    for (final path in resolvedPaths) {
      final file = File(path);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
    }
  }

  Future<String> get _appStatusFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/app_status.json';
  }

  Future<void> _loadAppStatus() async {
    try {
      final file = File(await _appStatusFilePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        _appStatus = json.decode(jsonString);
        _appStatus['lastOpened'] = DateTime.now().toIso8601String();
        _appStatus['normalShutdown'] = false;
        await _saveAppStatus();
      } else {
        await _saveAppStatus();
      }
    } catch (e) {
      print("Error loading app status: $e");
      _appStatus = {
        'lastOpened': DateTime.now().toIso8601String(),
        'lastClosed': DateTime.now().toIso8601String(),
        'normalShutdown': true,
      };
    }
  }

  Future<void> _saveAppStatus() async {
    try {
      final file = File(await _appStatusFilePath);
      await file.writeAsString(json.encode(_appStatus));
    } catch (e) {
      print("Error saving app status: $e");
    }
  }

  Future<void> recordNormalShutdown() async {
    try {
      _appStatus['lastClosed'] = DateTime.now().toIso8601String();
      _appStatus['normalShutdown'] = true;
      await _saveAppStatus();
    } catch (e) {
      print("Error recording normal shutdown: $e");
    }
  }

  // File paths
  Future<String> get _pendingApplicationsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/pending_applications.json';
  }

  Future<String> get _acceptedApplicationsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/accepted_applications.json';
  }

  Future<String> get _rejectedApplicationsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/rejected_applications.json';
  }

  Future<String> get _usersFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/users.json';
  }

  Future<String> get _activitiesFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/user_activities.json';
  }

  // Load applications
  Future<void> _loadApplications() async {
    try {
      // Load pending applications
      final pendingFile = File(await _pendingApplicationsPath);
      if (await pendingFile.exists()) {
        final jsonString = await pendingFile.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _pendingApplications =
            jsonList.map((json) => UserApplication.fromJson(json)).toList();
      }

      // Load accepted applications
      final acceptedFile = File(await _acceptedApplicationsPath);
      if (await acceptedFile.exists()) {
        final jsonString = await acceptedFile.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _acceptedApplications =
            jsonList.map((json) => UserApplication.fromJson(json)).toList();
      }

      // Load rejected applications
      final rejectedFile = File(await _rejectedApplicationsPath);
      if (await rejectedFile.exists()) {
        final jsonString = await rejectedFile.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _rejectedApplications =
            jsonList.map((json) => UserApplication.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error loading applications: $e");
      // Initialize empty lists if loading fails
      _pendingApplications = [];
      _acceptedApplications = [];
      _rejectedApplications = [];
    }
    notifyListeners();
  }

  // Save applications
  Future<void> _saveApplications() async {
    try {
      // Save pending applications
      final pendingFile = File(await _pendingApplicationsPath);
      await pendingFile.writeAsString(json
          .encode(_pendingApplications.map((app) => app.toJson()).toList()));

      // Save accepted applications
      final acceptedFile = File(await _acceptedApplicationsPath);
      await acceptedFile.writeAsString(json
          .encode(_acceptedApplications.map((app) => app.toJson()).toList()));

      // Save rejected applications
      final rejectedFile = File(await _rejectedApplicationsPath);
      await rejectedFile.writeAsString(json
          .encode(_rejectedApplications.map((app) => app.toJson()).toList()));
    } catch (e) {
      print("Error saving applications: $e");
    }
  }

  Future<void> _loadUserActivities() async {
    try {
      final file = File(await _activitiesFilePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        if (jsonString.isNotEmpty) {
          // Check for empty files
          final List<dynamic> jsonList = json.decode(jsonString);
          _userActivities =
              jsonList.map((json) => UserActivity.fromJson(json)).toList();
          print("Loaded ${_userActivities.length} user activities");
        } else {
          _userActivities = [];
          print("Activities file exists but is empty");
        }
      } else {
        _userActivities = [];
        print("Activities file doesn't exist yet");
      }
    } catch (e) {
      print("Error loading user activities: $e");
      _userActivities = [];
    }
  }

  Future<void> _loadUsers() async {
    try {
      final file = File(await _usersFilePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        if (jsonString.isNotEmpty) {
          final List<dynamic> jsonList = json.decode(jsonString);
          _users = jsonList
              .whereType<Map<String, dynamic>>()
              .map((json) => User.fromJson(json))
              .toList();
          print("Loaded ${_users.length} users");
        } else {
          _users = [];
          print("Users file exists but is empty");
        }
      } else {
        _users = [];
        print("Users file doesn't exist yet");
      }
    } catch (e) {
      print("Error loading users: $e");
      _users = [];
    }
    notifyListeners();
  }

  Future<void> _saveUsers() async {
    try {
      final file = File(await _usersFilePath);
      final jsonList = _users.map((user) => user.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      print("Saved ${_users.length} users to file");
    } catch (e) {
      print("Error saving users: $e");
    }
  }

  Future<void> _saveActivities() async {
    try {
      final file = File(await _activitiesFilePath);
      final jsonList =
          _userActivities.map((activity) => activity.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      print("Saved ${_userActivities.length} activities to file");
    } catch (e) {
      print("Error saving activities: $e");
    }
  }

  Future<bool> signIn(
      String identifier, String password, SignInMethod method) async {
    try {
      // Get admin credentials from the admin config file
      final adminConfigFile = File(await _adminConfigFilePath);
      if (await adminConfigFile.exists()) {
        final adminConfig = json.decode(await adminConfigFile.readAsString());
        final adminUsername = adminConfig['admin_username'];
        final adminPassword = adminConfig['admin_password'];

        if ((method == SignInMethod.username && identifier == adminUsername) ||
            (method == SignInMethod.email && identifier == adminUsername)) {
          if (password == adminPassword) {
            _currentUser = User(
                id: 'admin',
                role: UserRole.admin,
                password: adminPassword,
                email: adminUsername,
                username: adminUsername);
            logUserActivity(adminUsername, 'Login');

            notifyListeners();
            return true;
          }
        }
      }

      final matchingUser = _users.firstWhere(
        (user) {
          switch (method) {
            case SignInMethod.username:
              return user.username == identifier;
            case SignInMethod.email:
              return user.email == identifier;
            case SignInMethod.phoneNumber:
              return user.phoneNumber == identifier;
          }
        },
        orElse: () => User(
            id: '',
            username: '',
            role: UserRole.user,
            password: '',
            email: '',
            phoneNumber: ''),
      );

      if (matchingUser.id.isNotEmpty) {
        if (matchingUser.password == password) {
          _currentUser = matchingUser;
          logUserActivity(identifier, 'Login');

          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error during sign in: $e");
      return false;
    }
  }

  Future<String> get _adminConfigFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/admin_config.json';
  }

  Future<void> initializeAdmin({
    required String username,
    required String password,
  }) async {
    _currentUser = User(
        id: 'admin',
        username: username,
        role: UserRole.admin,
        password: password);

    // Store admin credentials in a JSON file
    final adminConfig = {
      'admin_username': username,
      'admin_password': password,
      'created_at': DateTime.now().toIso8601String(),
    };

    final file = File(await _adminConfigFilePath);
    await file.writeAsString(json.encode(adminConfig));

    notifyListeners();
  }

// Add this method to validate admin credentials from JSON file
  Future<bool> validateAdminCredentials(
      String username, String password) async {
    try {
      final file = File(await _adminConfigFilePath);
      if (await file.exists()) {
        final adminConfig = json.decode(await file.readAsString());
        final storedUsername = adminConfig['admin_username'];
        final storedPassword = adminConfig['admin_password'];

        return username == storedUsername && password == storedPassword;
      }
      return false;
    } catch (e) {
      print("Error validating admin credentials: $e");
      return false;
    }
  }

  void handleApplication(UserApplication application, bool approved,
      {UserRole? role, String? rejectionReason}) {
    if (approved) {
      _users.add(User.fromApplication(application, role ?? UserRole.user));
      logUserActivity(application.username, 'Account Approved');
    } else {
      logUserActivity(application.username, 'Application Rejected');
    }
    _pendingApplications.removeWhere((a) => a.id == application.id);
    notifyListeners();
  }

  void logUserActivity(String username, String actionType) async {
    final newActivity = (UserActivity(
        username: username,
        timestamp: DateTime.now().toIso8601String(),
        actionType: actionType));
    _userActivities.add(newActivity);

    await UserActivity.saveActivities(_userActivities);

    await UserActivity.maintainActivityLog(_userActivities);
    notifyListeners();
  }

  void signOut() {
    if (_currentUser != null) {
      logUserActivity(_currentUser!.username ?? 'Unknown', 'Logout');
    }
    _currentUser = null;

    notifyListeners();
  }

  bool hasPermission(List<UserRole> allowedRoles) {
    if (_currentUser == null) {
      return false;
    }
    return allowedRoles.contains(_currentUser!.role);
  }

  Future<void> updateUserRole(User user, UserRole newRole) async {
    try {
      final updatedUser = user.copyWith(
        role: newRole,
      );

      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = updatedUser;
        await _saveUsers();
        logUserActivity(user.username ?? 'Unknown',
            'Role Updated to ${newRole.toString().split('.').last}');
      }
      notifyListeners();
    } catch (e) {
      print("Error updating user role: $e");
    }
  }

  Future<void> toggleUserStatus(String userId) async {
    final userIndex = _users.indexWhere((user) => user.id == userId);
    if (userIndex != -1) {
      _users[userIndex] = User(
        id: _users[userIndex].id,
        username: _users[userIndex].username,
        email: _users[userIndex].email,
        role: _users[userIndex].role,
        isDisabled: _users[userIndex].isDisabled,
        phoneNumber: _users[userIndex].phoneNumber,
        password: _users[userIndex].password,
      );
      await User.saveUsers(_users);
      notifyListeners();
    }
  }

  // Add this method to validate admin credentials

  Future<void> sendPassWordResetEmail(String email) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        throw Exception("Invalid email address");
      }

      debugPrint("Sending password reset email to: $email");

      final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/auth/reset-passwword'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await getAuthToken()}',
          },
          body: jsonEncode({'email': email}));
      if (response.statusCode == 200) {
        debugPrint("Password reset email sent successfully");
      } else if (response.statusCode == 404) {
        throw Exception("User with this email not found");
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? "Failed to send password reset email");
      }
    } catch (e) {
      debugPrint("Error sending password reset email: $e");
      rethrow;
    }
  }

  Future<String> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    // final storedToken = prefs.getString(AUTH_TOKEN_KEY) ?? '';
    return '';
  }

  Future<void> disableUser(User user) async {
    try {
      final updatedUser = user.copyWith(
        status: UserStatus.disabled,
        isDisabled: true,
      );

      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = updatedUser;
        await _saveUsers();
        logUserActivity(user.username ?? 'Unknown', 'User Disabled');
      }
      notifyListeners();
    } catch (e) {
      print("Error disabling user: $e");
    }
  }

  Future<void> deleteUser(User user) async {
    try {
      final updatedUser = user.copyWith(
        status: UserStatus.deleted,
      );

      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = updatedUser;
        await _saveUsers();
        logUserActivity(user.username ?? 'Unknown', 'User Deleted');
      }
      notifyListeners();
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  Future<void> enableUser(User user) async {
    try {
      final updatedUser = user.copyWith(
        status: UserStatus.approved,
        isDisabled: false,
      );

      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = updatedUser;
        await _saveUsers();
        logUserActivity(user.username ?? 'Unknown', 'User Enabled');
      }
      notifyListeners();
    } catch (e) {
      print("Error enabling user: $e");
    }
  }

  Future<void> addUserActivity(UserActivity activity) async {
    try {
      _userActivities.add(activity);
      await _saveActivities(); // Use the class method for consistency
      print("Added activity: ${activity.actionType} for ${activity.username}");
      notifyListeners();
    } catch (e) {
      print("Error adding user activity: $e");
    }
  }

  Future<void> addPendingApplication(UserApplication application) async {
    _pendingApplications.add(application);
    await _saveApplications();

    // Maintain maximum of 500 pending applications
    if (_pendingApplications.length > 500) {
      _pendingApplications =
          _pendingApplications.sublist(_pendingApplications.length - 500);
      await _saveApplications();
    }

    notifyListeners();
  }

  // Approve application
  Future<void> approveApplication(int index, UserRole role) async {
    final application = _pendingApplications[index];

    // Create new user from application
    final newUser = User.fromApplication(application, role);
    _users.add(newUser);
    await _saveUsers();

    // Move application to accepted list
    _acceptedApplications.add(application);
    _pendingApplications.removeAt(index);
    await _saveApplications();

    // Log activity
    final activity = UserActivity(
        username: application.username,
        actionType: "Account Approved",
        timestamp: DateTime.now().toIso8601String());
    _userActivities.add(activity);
    await _saveActivities();

    notifyListeners();
  }

  // Reject application
  Future<void> rejectApplication(int index, String reason) async {
    final application = _pendingApplications[index];

    // Move application to rejected list with reason
    _rejectedApplications.add(application);
    _pendingApplications.removeAt(index);
    await _saveApplications();

    // Log activity
    final activity = UserActivity(
        username: application.username,
        actionType: "Application Rejected: $reason",
        timestamp: DateTime.now().toIso8601String());
    _userActivities.add(activity);
    await _saveActivities();

    notifyListeners();
  }

  Future<void> debugPrintStoredData() async {
    try {
      final usersFile = File(await _usersFilePath);
      if (await usersFile.exists()) {
        print('Stored users:');
        print(await usersFile.readAsString());
      }

      final pendingFile = File(await _pendingApplicationsPath);
      if (await pendingFile.exists()) {
        print('Pending applications:');
        print(await pendingFile.readAsString());
      }

      final acceptedFile = File(await _acceptedApplicationsPath);
      if (await acceptedFile.exists()) {
        print('Accepted applications:');
        print(await acceptedFile.readAsString());
      }
    } catch (e) {
      print("Error reading debug data: $e");
    }
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback? onLogoutComplete;

  const LogoutButton({super.key, this.onLogoutComplete});

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool? shouldLogout = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                title: const Text('Confirm Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Yes'),
                  )
                ]));

    if (shouldLogout == true) {
      authProvider.signOut();

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const Center(
                child: CircularProgressIndicator(),
              ));

      await Future.delayed(const Duration(seconds: 2));

      Navigator.of(context).pop();

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const WelcomePage()));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Successfully loged out"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ));

      onLogoutComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
        onPressed: () => _handleLogout(context),
        tooltip: 'Logout',
        icon: const Icon(Icons.logout));
  }
}
