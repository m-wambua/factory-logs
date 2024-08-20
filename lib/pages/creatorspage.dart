import 'package:collector/pages/file_manager.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/subprocesscreator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreatorPage extends StatefulWidget {
  final String processName;
  final void Function(String processName, String newState) updateButtonState;

  const CreatorPage({
    Key? key,
    required this.processName,
    required this.updateButtonState, // Accept the call back
  }) : super(key: key);

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
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creator\'s Page - ${widget.processName}'),
        actions: [
          IconButton(
            onPressed: () {
              // Save functionality if needed
              _saveProcessAndSubprocesses();
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

  void _saveProcessAndSubprocesses() async {
    setState(() {
      _isSaving = true;
    });
    

    try {
      // Load the existing processes from the JSON file
      Map<String, List<String>> existingProcesses =
          await FileManager.loadProcesses();

      // Add or update the current process with its subprocesses
      existingProcesses[widget.processName] = _subprocesses;

      // Save the updated processes back to the JSON file
      await FileManager.saveProcesses(existingProcesses);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Process and Subprocesses saved successfully!')),
      );

      // Update Landing
      Navigator.pop(context); // Go back to landing page
      widget.updateButtonState(
          widget.processName, 'finalized'); // Update process state

      // Navigate to the dynamic page with subprocess data
      Navigator.pushNamed(
        context,
        '/${widget.processName}',
        arguments: {
          'processName': widget.processName,
          'subprocesses': _subprocesses,
        },
      );
    } catch (e) {
      print('Error saving process and subprocesses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save process and subprocesses')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}
