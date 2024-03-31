import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedShift = 'A';
  String _selectedHandoverPerson = 'Operator';
  List<String> _shifts = ['A', 'B', 'C', 'G'];
  List<String> _handoverPersons = [
    'Operator',
    'Person 1',
    'Person 2',
    'Person 3',
    'Person 4',
    'Person 5',
    'Person 6'
  ];
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
                        TextFormField();
                      },
                      child: Text('Login'))
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
/*
   _showLoginDialog(context: context, builder: (BuildContext context)
  
  {
    return AlertDialog(
      title: Text('Please Sign in'),
      actions: <Widget>[
        TextFormField(
          decoration: InputDecoration(
            label: 'Username'
          ),
          keyboardType: TextInputType.text,
          
        ),

        SizedBox( height: 20,),
        TextFormField(decoration: InputDecoration(labelText: 'Password'),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        ),
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
              child: Text('Cancel'),)

      ],
    )
  })
  */
}
