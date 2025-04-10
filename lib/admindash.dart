import 'dart:convert';

import 'package:collector/pages/authorization.dart';
import 'package:collector/pages/protectedroutes.dart';
import 'package:collector/pages/users.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashBoard extends StatefulWidget {
  const AdminDashBoard({super.key});

  @override
  _AdminDashBoardState createState() => _AdminDashBoardState();
}

class _AdminDashBoardState extends State<AdminDashBoard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Protectedroutes(
        allowedRoles: const [UserRole.admin],
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text("Admin Dashboard"),
                ElevatedButton(
                  onPressed: () async {
                    await Provider.of<AuthProvider>(context, listen: false)
                        .debugPrintStoredData();
                  },
                  child: const Text('Debug: Print Stored Data'),
                )
              ],
            ),
            bottom: TabBar(controller: _tabController, tabs: const [
              Tab(
                text: "Pending Applications",
              ),
              Tab(
                text: "Active Users",
              ),
              Tab(
                text: "User Activity",
              ),
              Tab(
                text: "Users",
              )
            ]),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              const PendingApplicationsTab(),
              ActiveUsersTab(),
              const UserActivityTab(),
              const UserTab()
            ],
          ),
        ));
  }
}

class PendingApplicationsTab extends StatelessWidget {
  const PendingApplicationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final pendingApplications = authProvider.pendingApplications;
    if (pendingApplications.isEmpty) {
      return const Center(
        child: Text("No pending applications"),
      );
    }
    return ListView.builder(
        itemCount: pendingApplications.length,
        itemBuilder: (context, index) {
          final application = pendingApplications[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('Application #${index + 1}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Application from: ${application.firstName} ${application.lastName}"),
                  Text('Username: ${application.username}'),
                  Text("Email: ${application.email}"),
                  Text(
                      "Applied: ${_formatDate(application.applicationDate.toString())}")
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () {
                        _showApprovalDialog(context, index, application);
                      },
                      icon: const Icon(
                        Icons.check,
                        color: Colors.green,
                      )),
                  IconButton(
                      onPressed: () {
                        _showRejectionDialog(context, index, application);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ))
                ],
              ),
            ),
          );
        });
  }

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _showApprovalDialog(
      BuildContext context, int index, UserApplication application) {
    UserRole selectedRole = UserRole.user;

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  title: const Text('Approve Application'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Select role for the new user:"),
                      DropdownButton<UserRole>(
                          value: selectedRole,
                          items: UserRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.toString().split('.').last),
                            );
                          }).toList(),
                          onChanged: (UserRole? newRole) {
                            if (newRole != null) {
                              setState(() {
                                selectedRole = newRole;
                              });
                            }
                          })
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          authProvider.approveApplication(index, selectedRole);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Application approved successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text('Approve'))
                  ],
                )));
  }

  void _showRejectionDialog(
      BuildContext context, int index, UserApplication application) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Reject Application'),
              content: TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: "Rejection Reason",
                  hintText: "Enter reason for rejection",
                ),
                maxLines: 3,
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      if (reasonController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a rejection reason'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      authProvider.rejectApplication(
                          index, reasonController.text.trim());
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Application rejected'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    child: const Text("Reject"))
              ],
            ));
  }
}

class ActiveUsersTab extends StatelessWidget {
  final _searchController = TextEditingController();

  ActiveUsersTab({super.key});

  // Helper method to check if a user is currently active
  bool isUserActive(String username, List<UserActivity> activities) {
    // Sort activities by timestamp in descending order
    final userActivities = activities
        .where((activity) => activity.username! == username)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // If user has no activities, they're not active
    if (userActivities.isEmpty) return false;

    // Check if their most recent activity was a login
    return userActivities.first.actionType.toLowerCase() == 'login';
  }

  // Get unique users from activity log
  List<String> getActiveUsers(List<UserActivity> activities) {
    final uniqueUsers = activities
        .map((activity) => activity.username)
        .toSet()
        .where((username) => isUserActive(username, activities))
        .toList();
    return uniqueUsers;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final activities = authProvider.userActivities;
    final activeUsers = getActiveUsers(activities);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search Users',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Implement search if needed
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: activeUsers.length,
            itemBuilder: (context, index) {
              final username = activeUsers[index];
              // Get last activity time for this user
              final lastActivity = activities
                  .where((activity) => activity.username == username)
                  .reduce(
                      (a, b) => a.timestamp.compareTo(b.timestamp) > 0 ? a : b);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(username[0].toUpperCase()),
                  ),
                  title: Text(username),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last Active: ${lastActivity.timestamp}'),
                      const Text('Status: Active'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'disable',
                        child: ListTile(
                          leading: Icon(Icons.block),
                          title: Text('Force Logout'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'activity',
                        child: ListTile(
                          leading: Icon(Icons.history),
                          title: Text('View Activity'),
                        ),
                      ),
                      const PopupMenuItem(
                          value: "delete",
                          child: ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('delete account'),
                          ))
                    ],
                    onSelected: (value) async {
                      switch (value) {
                        case 'disable':
                          _showForceLogoutDialog(context, username);
                          break;
                        case 'activity':
                          _showUserActivityDialog(
                              context, username, activities);
                        case 'delete':
                          _showDeleteAccountDialog(context, index);
                          break;
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showForceLogoutDialog(BuildContext context, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Logout User'),
        content: const Text('Are you sure you want to force logout this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () async {
              // Add a logout activity
              final newActivity = UserActivity(
                username: username,
                timestamp: DateTime.now().toIso8601String(),
                actionType: 'Logout (Forced by Admin)',
              );

              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              authProvider.addUserActivity(newActivity);
              Navigator.pop(context);
            },
            child: const Text('Force Logout'),
          ),
        ],
      ),
    );
  }

  void _showUserActivityDialog(
      BuildContext context, String username, List<UserActivity> allActivities) {
    final userActivities = allActivities
        .where((activity) => activity.username == username)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Activity History - $username'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: userActivities.length,
            itemBuilder: (context, index) {
              final activity = userActivities[index];
              return ListTile(
                leading: Icon(
                  activity.actionType.toLowerCase() == 'login'
                      ? Icons.login
                      : Icons.logout,
                ),
                title: Text(activity.actionType),
                subtitle: Text(activity.timestamp),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, int index) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Account"),
              content: const Text("Are you sure you want to delete your account?"),
              actions: [
                TextButton(
                    onPressed: () async {
                      //   await _deleteAccount(index);
                      Navigator.pop(context);
                    },
                    child: const Text("Yes")),
                TextButton(
                    onPressed: () => Navigator.pop(context), child: const Text("No")),
              ],
            ));
  }
}

class UserActivityTab extends StatelessWidget {
  const UserActivityTab({super.key});

  // Helper method to format timestamp
  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('MMM d, y h:mm a').format(dateTime);
  }

  // Helper method to get appropriate icon for action type
  IconData _getActionIcon(String actionType) {
    if (actionType.toLowerCase().contains('login')) {
      return Icons.login;
    } else if (actionType.toLowerCase().contains('logout')) {
      return Icons.logout;
    } else if (actionType.toLowerCase().contains('approved')) {
      return Icons.check_circle;
    } else if (actionType.toLowerCase().contains('rejected')) {
      return Icons.cancel;
    } else if (actionType.toLowerCase().contains('disabled')) {
      return Icons.block;
    } else if (actionType.toLowerCase().contains('deleted')) {
      return Icons.delete;
    } else if (actionType.toLowerCase().contains('role')) {
      return Icons.assignment_ind;
    } else {
      return Icons.info;
    }
  }

  // Helper method to get color for action type
  Color _getActionColor(String actionType) {
    if (actionType.toLowerCase().contains('login')) {
      return Colors.green;
    } else if (actionType.toLowerCase().contains('logout')) {
      return Colors.blue;
    } else if (actionType.toLowerCase().contains('approved')) {
      return Colors.green;
    } else if (actionType.toLowerCase().contains('rejected')) {
      return Colors.red;
    } else if (actionType.toLowerCase().contains('disabled')) {
      return Colors.orange;
    } else if (actionType.toLowerCase().contains('deleted')) {
      return Colors.red;
    } else if (actionType.toLowerCase().contains('role')) {
      return Colors.purple;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final activities = authProvider.userActivities;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Activity',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton(
                icon: const Icon(Icons.filter_list),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: '24h',
                    child: Text('Last 24 Hours'),
                  ),
                  const PopupMenuItem(
                    value: '7d',
                    child: Text('Last 7 Days'),
                  ),
                  const PopupMenuItem(
                    value: '30d',
                    child: Text('Last 30 Days'),
                  ),
                ],
                onSelected: (value) {
                  // Handle filter selection
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: activities.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No activity records found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getActionColor(activity.actionType)
                              .withOpacity(0.1),
                          child: Icon(
                            _getActionIcon(activity.actionType),
                            color: _getActionColor(activity.actionType),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                activity.username,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              _formatTimestamp(activity.timestamp),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            activity.actionType,
                            style: TextStyle(
                              color: _getActionColor(activity.actionType),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class UserActivity {
  final String username;
  final String actionType;
  final String timestamp;

  UserActivity(
      {required this.username,
      required this.timestamp,
      required this.actionType});

  Map<String, dynamic> toJson() =>
      {"username": username, 'actionType': actionType, 'timestamp': timestamp};

  factory UserActivity.fromJson(Map<String, dynamic> json) => UserActivity(
      username: json['username'],
      timestamp: json['timestamp'],
      actionType: json['actionType']);

  static Future<void> saveActivities(List<UserActivity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonActivities =
        activities.map((activity) => activity.toJson()).toList();
    await prefs.setStringList('user_activities',
        jsonActivities.map((activity) => json.encode(activity)).toList());
  }

  static Future<List<UserActivity>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final savedActivities = prefs.getStringList('user_activities') ?? [];

    return savedActivities.map((jsonString) {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return UserActivity.fromJson(jsonMap);
    }).toList();
  }

  static Future<void> maintainActivityLog(List<UserActivity> activities,
      {int maxEntries = 500}) async {
    if (activities.length > maxEntries) {
      final trimmedActivites =
          activities.sublist(activities.length - maxEntries);
      await saveActivities(trimmedActivites);
    }
  }
}

class UserTab extends StatelessWidget {
  const UserTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final users = authProvider.users;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: _getUserIconColor(user.status),
                      ),
                      title: Text(
                        user.username ?? "N/A",
                        style: TextStyle(
                          decoration: user.status == UserStatus.deleted ||
                                  user.status == UserStatus.disabled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email: ${user.email ?? "N/A"}"),
                          Text("Phone: ${user.phoneNumber ?? "N/A"}"),
                          Text("Role: ${user.role.toString().split('.').last}"),
                          Text(
                              "Status: ${user.status.toString().split('.').last}"),
                          // Last login time could be helpful for admins
                        ],
                      ),
                      trailing: _buildPopupMenu(context, user, authProvider),
                    ),
                    if (user.status != UserStatus.deleted &&
                        user.status != UserStatus.disabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Password reset button instead of viewing password
                            TextButton.icon(
                              icon: const Icon(Icons.lock_reset),
                              label: const Text("Send Password Reset Link"),
                              onPressed: () {
                                // Show confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Send Password Reset Email?"),
                                      content: Text(
                                          "This will send a password reset link to ${user.email}. Continue?"),
                                      actions: [
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        TextButton(
                                          child: const Text("Send"),
                                          onPressed: () {
                                            // Call your password reset service
                                            //   authProvider.sendPasswordResetEmail(user.email);
                                            Navigator.of(context).pop();
                                            // Show success message
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "Password reset email sent to ${user.email}"),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildRoleUpdateButton(context, user, authProvider),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPopupMenu(
      BuildContext context, User user, AuthProvider authProvider) {
    return PopupMenuButton<String>(
      onSelected: (String choice) async {
        switch (choice) {
          case 'delete':
            _showDeleteConfirmation(context, user, authProvider);
            break;
          case 'disable':
            _showDisableConfirmation(context, user, authProvider);
            break;
          case 'enable':
            _showEnableConfirmation(context, user, authProvider);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        final List<PopupMenuEntry<String>> items = [];

        if (user.status != UserStatus.deleted) {
          items.add(
            const PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete User'),
              ),
            ),
          );
        }

        if (user.status != UserStatus.disabled) {
          items.add(
            const PopupMenuItem<String>(
              value: 'disable',
              child: ListTile(
                leading: Icon(Icons.block, color: Colors.orange),
                title: Text('Disable User'),
              ),
            ),
          );
        } else {
          items.add(
            const PopupMenuItem<String>(
              value: 'enable',
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Enable User'),
              ),
            ),
          );
        }

        return items;
      },
    );
  }

  Widget _buildRoleUpdateButton(
      BuildContext context, User user, AuthProvider authProvider) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.edit),
      label: const Text('Update Role'),
      onPressed: () => _showRoleUpdateDialog(context, user, authProvider),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Color _getUserIconColor(UserStatus status) {
    switch (status) {
      case UserStatus.deleted:
        return Colors.red;
      case UserStatus.disabled:
        return Colors.orange;
      case UserStatus.approved:
        return Colors.green;
      case UserStatus.pending:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, User user, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Are you sure you want to delete ${user.username}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                authProvider.deleteUser(user);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('User ${user.username} has been deleted')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDisableConfirmation(
      BuildContext context, User user, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disable User'),
          content: Text('Are you sure you want to disable ${user.username}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Disable'),
              onPressed: () {
                authProvider.disableUser(user);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('User ${user.username} has been disabled')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showEnableConfirmation(
      BuildContext context, User user, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable User'),
          content: Text('Are you sure you want to enable ${user.username}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () {
                authProvider.enableUser(user);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('User ${user.username} has been enabled')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showRoleUpdateDialog(
      BuildContext context, User user, AuthProvider authProvider) {
    UserRole selectedRole = user.role ?? UserRole.user;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update User Role'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: UserRole.values.map((role) {
                  return RadioListTile<UserRole>(
                    title: Text(role.toString().split('.').last),
                    value: role,
                    groupValue: selectedRole,
                    onChanged: (UserRole? value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Update'),
                  onPressed: () {
                    authProvider.updateUserRole(user, selectedRole);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'User ${user.username}\'s role updated to ${selectedRole.toString().split('.').last}'),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
