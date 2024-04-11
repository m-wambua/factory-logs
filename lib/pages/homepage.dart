import 'package:collector/pages/login_page.dart';
import 'package:collector/pages/logout_page.dart';
import 'package:collector/pages/personel.dart';
import 'package:flutter/material.dart';
import 'package:collector/pages/process_1/process_1.dart';
import 'package:collector/pages/process_2/process_2.dart';
import 'package:collector/pages/process_3/process_3.dart';
import 'package:collector/pages/process_4/process_4.dart';

class LandingPage extends StatefulWidget {
  final String username;
  const LandingPage({Key? key, required this.username}) : super(key: key);
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String _selectedProcess = '';
  Map<String, bool> _buttonStates = {
    'Process 1': false,
    'Process 2': false,
    'Process 3': false,
    'Process 4': false,
    'Logout':false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Factory Processes'),
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
                    return Placeholder(); // Home page
                  case 'Process 1':
                    return Process1Page();
                  case 'Process 2':
                    return Process2Page();
                  case 'Process 3':
                    return Process3Page();
                  case 'Process 4':
                    return Process4Page();
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
          MaterialPageRoute(builder: (context) => Process1Page()),
        );
        break;
      case 'Process 2':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Process2Page()),
        );
        break;
      case 'Process 3':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Process3Page()),
        );
        break;
      case 'Process 4':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Process4Page()),
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
