import 'package:collector/pages/personel.dart';
import 'package:flutter/material.dart';

class LogoutPage extends StatefulWidget {
  final String currentUser;

  LogoutPage({required this.currentUser});

  @override
  _LogoutPageState createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  String _selectedPerson = '';
  TextEditingController _handoverController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout / Handover'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logged in as: ${widget.currentUser}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            /*
            TextField(
              controller: _handoverController,
              decoration: InputDecoration(
                labelText: 'Handover to',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedPerson = value;
                });
              },
            ),
            */
DropdownButtonFormField<Person>(
  decoration: InputDecoration(
    labelText: 'Handover to',
    border: OutlineInputBorder(),
  ),
  value:null,
  items: PersonnelDataSource.personnel.map((person)=>DropdownMenuItem<Person>(
    value: person,
    child: Text(person.name),)).toList(), 
    onChanged: (value){
      setState(() {
        _selectedPerson=value!.name;
      });
    }),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _confirmHandover();
              },
              child: Text('Confirm Handover'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmHandover() {
    if (_selectedPerson.isNotEmpty) {
      // Implement logic for handover
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Handover'),
            content: Text('Are you sure you want to handover to $_selectedPerson?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement handover logic
                  Navigator.pop(context);
                  _handoverController.clear();
                  setState(() {
                    _selectedPerson = '';
                  });
                  // Show success message
                  _showHandoverSuccess();
                },
                child: Text('Confirm'),
              ),
            ],
          );
        },
      );
    } else {
      // Show error message if no person selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the person you want to handover to.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showHandoverSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Handover Successful'),
          content: Text('You have successfully handed over to $_selectedPerson.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}