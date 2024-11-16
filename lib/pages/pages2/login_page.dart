import 'package:collector/pages/pages2/homepage.dart';
import 'package:collector/pages/pages2/logout_page.dart';
import 'package:collector/pages/welcomePage/loginAndLogout/personel.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedShift = 'A';
  String _selectedHandoverPerson = 'Operator';
  final List<String> _shifts = ['A', 'B', 'C', 'G'];
  final List<String> _handoverPersons =
      PersonnelDataSource.personnel.map((person) => person.name).toList();

  List<String> _teamMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Image.asset(AppAssets.deltalogo),
          ),
          const Text('Login'),
        ],
      )
      
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Select Shift:'),
            DropdownButton<String>(
              value: _selectedShift,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedShift = newValue ?? 'A';
                  _selectedHandoverPerson = _handoverPersons.first;
                });
              },
              items: _shifts.map((String shift) {
                return DropdownMenuItem<String>(
                  value: shift,
                  child: Text(shift),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_selectedShift.isNotEmpty && _selectedShift != 'G')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Handover Person:'),
                  DropdownButton<String>(
                    value: _selectedHandoverPerson,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedHandoverPerson = newValue!;
                      });
                    },
                    items: _handoverPersons.map((person) {
                      return DropdownMenuItem<String>(
                        value: person,
                        child: Text(person),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Team Members:'),
                  Wrap(
                    spacing: 8.0,
                    children: _teamMembers.map((member) {
                      return Chip(
                        label: Text(member),
                        onDeleted: () {
                          setState(() {
                            _teamMembers.remove(member);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  ElevatedButton(
                    onPressed: _selectTeamMembers,
                    child: const Text('Select Team Members'),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Check if the user is logged in
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LandingPage(
                                  username: _selectedHandoverPerson)));
                    },
                    child: const Text('Begin logs'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LogoutPage(
                                    currentUser: _selectedHandoverPerson)));
                      },
                      child: const Text('Logout Page'))
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _selectTeamMembers() async {
    List<String>? selectedMembers = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Team Members'),
          content: SingleChildScrollView(
            child: Column(
              children: _handoverPersons.map((person) {
                return CheckboxListTile(
                  title: Text(person),
                  value: _teamMembers.contains(person),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        _teamMembers.add(person);
                      } else {
                        _teamMembers.remove(person);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _teamMembers);
              },
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selectedMembers != null) {
      setState(() {
        _teamMembers = selectedMembers;
      });
    }
  }

  void _showLoginDialog(BuildContext context) {
    String username = '';
    String password = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please Sign in'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  username = value;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
              )
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _login(context, username, password);
              },
              child: const Text('Ok'),
            )
          ],
        );
      },
    );
  }

  void _login(BuildContext context, String username, String password) {
    bool isAuthenticated = UserDatabase.verifyCredentials(username, password);

    if (isAuthenticated) {
      // Navigate to the landing page
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LandingPage(username: username)));
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
