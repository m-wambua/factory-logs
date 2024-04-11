import 'package:collector/pages/homepage.dart';
import 'package:collector/pages/logout_page.dart';
import 'package:collector/pages/personel.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedShift = 'A';
  String _selectedHandoverPerson = 'Operator';
  List<String> _shifts = ['A', 'B', 'C', 'G'];
  List<String> _handoverPersons =
      PersonnelDataSource.personnel.map((person) => person.name).toList();

  List<String> _teamMembers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Shift:'),
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
            SizedBox(height: 20),
            if (_selectedShift.isNotEmpty && _selectedShift != 'G')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Handover Person:'),
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
                  SizedBox(height: 20),
                  Text('Select Team Members:'),
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
                    child: Text('Select Team Members'),
                  ),
                  SizedBox(
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
                    child: Text('Begin logs'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LogoutPage(
                                    currentUser: _selectedHandoverPerson)));
                      },
                      child: Text('Logout Page'))
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
          title: Text('Select Team Members'),
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
              child: Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
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
          title: Text('Please Sign in'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  username = value;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
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
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _login(context, username, password);
              },
              child: Text('Ok'),
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
        SnackBar(
          content: Text('Invalid username or password.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
