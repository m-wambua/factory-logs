import 'package:collector/pages/logout_page.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/notificationpage.dart';
import 'package:flutter/material.dart';
import 'package:collector/pages/process_1/process_1.dart';
import 'package:collector/pages/process_2/process_2.dart';
import 'package:collector/pages/process_3/process_3.dart';
import 'package:collector/pages/process_4/process_4.dart';

class LandingPage extends StatefulWidget {
  final String username;
  const LandingPage({super.key, required this.username});
  @override
  _LandingPageState createState() => _LandingPageState();
}

// a list of notification example
List<NotificationModel> _sampleNotifications = [
  NotificationModel(
    title: 'Notification 1',
    description: 'Description of Notification 1',
    timestamp: DateTime.now(),
    isRead: false,
    type: NotificationType.MaintenanceUpdate
  ),
  NotificationModel(
    title: 'Notification 2',
    description: 'Description of Notification 2',
    timestamp: DateTime.now(),
    isRead: false,
    type: NotificationType.LogsCollected
  ),
  // Add more sample notifications as needed
];

int getNotificationCount() {
  //Assuming
  return _sampleNotifications.length;
}

class _LandingPageState extends State<LandingPage> {
  String _selectedProcess = '';
  final Map<String, bool> _buttonStates = {
    'Process 1': false,
    'Process 2': false,
    'Process 3': false,
    'Process 4': false,
    'Logout': false,
  };

  @override
  Widget build(BuildContext context) {
    int notificationCount=getNotificationCount();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Factory Processes'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
          const SizedBox(
            width: 15,
          ),
          Stack(children: [

            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsPage(
                              notifications: _sampleNotifications,
                            )));
              },
              icon: const Icon(Icons.notifications)),
              if (notificationCount>0)
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:BorderRadius.circular(10),

                  ),
                  constraints: const BoxConstraints(minWidth: 10,
                  minHeight: 10),
                  child: (Text(
                    notificationCount.toString(),style: const TextStyle(color: Colors.white,fontSize: 12),
                    textAlign: TextAlign.center,
                  )),
                ))
          ],),
          
          const SizedBox(
            width: 15,
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.list)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: _buildNavigationItems(),
        ),
      ),
      body: Stack(
        children: [
          Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(builder: (context) {
                switch (settings.name) {
                  case '/':
                    return const Placeholder(); // Home page
                  case 'Process 1':
                    return const Process1Page();
                  case 'Process 2':
                    return const Process2Page();
                  case 'Process 3':
                    return const Process3Page();
                  case 'Process 4':
                    return const Process4Page();
                  case 'Log Out':
                    return LogoutPage(currentUser: widget.username);

                  default:
                    throw Exception('Invalid route: ${settings.name}');
                }
              });
            },
          ),
          //LoginPage(), // Display LoginPage on top of the LandingPage
        ],
      ),
    );
  }

  List<Widget> _buildNavigationItems() {
    return _buttonStates.keys.map((String label) {
      return ListTile(
        title: Text(label),
        selected: _selectedProcess == label,
        onTap: () {
          Navigator.pop(context); // Close the drawer
          _handleButtonPressed(label);
          setState(() {
            _selectedProcess = label;
          });
        },
      );
    }).toList();
  }

  void _handleButtonPressed(String label) {
    setState(() {
      _buttonStates[label] = !_buttonStates[label]!;
    });
    switch (label) {
      case 'Process 1':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Process1Page()),
        );
        break;
      case 'Process 2':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Process2Page()),
        );
        break;
      case 'Process 3':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Process3Page()),
        );
        break;
      case 'Process 4':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Process4Page()),
        );
        break;

      case 'Logout':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    LogoutPage(currentUser: widget.username)));
      default:
        throw Exception('Invalid route: $label');
    }
  }
}
