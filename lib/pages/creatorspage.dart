import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/subprocesscreator.dart';
import 'package:flutter/material.dart';

class CreatorPage extends StatefulWidget {
  final String processName;

  const CreatorPage({Key? key, required this.processName}) : super(key: key);

  @override
  _CreatorPageState createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  List<String> _subprocesses = [
    'Subprocess 1',
    'Subprocess 2',
    'Subprocess 3',
    'Subprocess 4',
    'Subprocess 5',
    'Subprocess 6',
    'Subprocess 7',
  ];

  List<NotificationModel> _notifications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creator\'s Page - ${widget.processName}'),
        actions: [
          IconButton(
            onPressed: () {
              // Save functionality if needed
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // List of subprocess tiles
              for (int index = 0; index < _subprocesses.length; index++)
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(_subprocesses[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteSubprocess(index);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubprocessCreatorPage(
                                  subprocessName: _subprocesses[index])));
                    },
                    onLongPress: () {
                      _renameSubprocess(index);
                    },
                  ),
                ),
              SizedBox(height: 20),
              // Add button for creating new subprocess
              ElevatedButton(
                onPressed: () {
                  _createNewSubprocess();
                },
                child: Text('Add New Subprocess'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewSubprocess() async {
    String? newSubprocessName;

    newSubprocessName = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempSubprocessName = '';
        return AlertDialog(
          title: Text('Create New Subprocess'),
          content: TextField(
            decoration: InputDecoration(
              labelText: 'Subprocess Name',
            ),
            onChanged: (value) {
              tempSubprocessName = value.trim();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context,
                    tempSubprocessName.isEmpty ? null : tempSubprocessName);
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );

    if (newSubprocessName != null && newSubprocessName.isNotEmpty) {
      setState(() {
        _subprocesses.add(newSubprocessName!);
      });
    }
  }

  void _deleteSubprocess(int index) {
    setState(() {
      _subprocesses.removeAt(index);
    });
  }

  void _renameSubprocess(int index) async {
    String? newSubprocessName;

    newSubprocessName = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempSubprocessName = '';
        return AlertDialog(
          title: Text('Rename Subprocess'),
          content: TextField(
            decoration: InputDecoration(
              labelText: 'New Name',
            ),
            onChanged: (value) {
              tempSubprocessName = value.trim();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, '');
              },
              child: Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context,
                    tempSubprocessName.isEmpty ? null : tempSubprocessName);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newSubprocessName != null && newSubprocessName.isNotEmpty) {
      setState(() {
        _subprocesses[index] = newSubprocessName!;
      });
    }
  }
}