import 'package:collector/admindash.dart';
import 'package:collector/pages/authorization.dart';
import 'package:collector/pages/pages2/creatorspage.dart';
import 'package:collector/pages/pages2/dailydeltas/delltafilemanager.dart';
import 'package:collector/pages/pages2/trial-supabase.dart';
import 'package:collector/pages/protectedroutes.dart';
import 'package:collector/pages/users.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/pages2/notificationpage.dart';
import 'package:collector/pages/pages2/logout_page.dart';
import 'package:collector/pages/pages2/datafortables/file_manager.dart'
    as FileManager;

class LandingPage extends StatefulWidget {
  final String username;

  const LandingPage({super.key, required this.username});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String _selectedProcess = '';
  final Map<String, String> _buttonStates = {};

  List<NotificationModel> _notifications = [];
  List<String> _processes = [];
  Map<String, List<String>> processNames = {};
  Map<String, List<String>> processSubDeltas = {};

  // Add a controller for sidebar width
  final double sidebarWidth = 250.0;

  @override
  void initState() {
    super.initState();
    loadNotifications();
    _loadProcesses();
  }

  Future<void> _loadProcesses() async {
    processNames = await FileManager.FileManager.loadProcesses();
    _processes = processNames.keys.toList();
    processSubDeltas = await DeltaFileManager.loadDeltas();
    setState(() {});
  }

  Future<void> loadNotifications() async {
    List<NotificationModel> notifications = await loadNotificationsFromFile();
    setState(() {
      _notifications = notifications;
    });
  }

  void _createNewProcess3() async {
    bool createDefault = true;
    String defaultName = 'Process ${_processes.length}';
    String processStatus = 'creation';

    bool? confirmCreate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Process'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You are about to create a new process.'),
            TextField(
              onChanged: (value) {
                createDefault = false;
                defaultName = value;
              },
              decoration: InputDecoration(
                labelText: 'Process Name',
                hintText: defaultName,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              processStatus = 'finalized';
              Navigator.pop(context, true);
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmCreate == true) {
      setState(() {
        _processes.add(defaultName);
        _buttonStates[defaultName] = processStatus;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatorPage(
            processName: defaultName,
            subprocesses: const [],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int notificationCount = _notifications.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Image.asset(AppAssets.deltalogo),
            ),
            const Text('Factory Processes'),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePageSupabase()));
              },
              icon: const Icon(Icons.home)),
          const SizedBox(width: 15),
          IconButton(
              onPressed: _createNewProcess3, icon: const Icon(Icons.add)),
          const SizedBox(width: 15),
          IconButton(onPressed: () {}, icon: const Icon(Icons.code)),
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsPage(
                        notifications: _notifications,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                    child: Text(
                      notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(width: 15),
          ProtectedNavigationButton(
              text: "Admin Dashboard",
              allowedRoles: [UserRole.admin],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminDashBoard(),
                  ),
                );
              }),
          LogoutButton()
        ],
      ),
      body: Row(
        children: [
          // Permanent Sidebar
          Container(
            width: sidebarWidth,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: _buildNavigationItems(),
                  ),
                ),
              ],
            ),
          ),
          // Vertical Divider
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          // Main Content
          Expanded(
            child: Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(builder: (context) {
                  switch (settings.name) {
                    case '/':
                      return const Placeholder();
                    case 'Log Out':
                      return LogoutButton();

                    default:
                      throw Exception('Invalid route: ${settings.name}');
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigationItems() {
    List<Widget> navigationItems = _processes.map((String processName) {
      Color tileColor =
          _buttonStates[processName] == 'creation' ? Colors.red : Colors.green;

      return ListTile(
        title: Text(processName),
        selected: _selectedProcess == processName,
        tileColor: tileColor,
        onTap: () {
          _handleButtonPressed(processName);
          setState(() {
            _selectedProcess = processName;
          });
        },
      );
    }).toList();

    navigationItems.add(ListTile(
      title: const Text('Logout'),
      selected: _selectedProcess == 'Logout',
      onTap: () {
        _handleButtonPressed('Logout');
        setState(() {
          _selectedProcess = 'Logout';
        });
      },
    ));

    return navigationItems;
  }

  void _handleButtonPressed(String processName) async {
    if (_processes.contains(processName)) {
      Navigator.pushNamed(
        context,
        '/$processName',
        arguments: {
          'processName': processName,
          'subprocesses': processNames[processName],
        },
      );
    } else {
      switch (processName) {
        case 'Logout':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogoutPage(currentUser: widget.username),
            ),
          );
          break;
        default:
          throw Exception('Invalid route: $processName');
      }
    }
  }

  void updateButtonState(String processName, String newState) {
    setState(() {
      _buttonStates[processName] = newState;
    });
  }
}
