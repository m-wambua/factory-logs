import 'dart:convert';
import 'dart:io';
import 'package:collector/pages/history/maintenance/preventiveMaintenance/detailsmaintenance.dart';
import 'package:collector/pages/history/maintenance/preventiveMaintenance/maintenance_details.dart';
import 'package:collector/pages/history/maintenance/preventiveMaintenance/maintenance_entry.dart'
    as MaintenanceEntry;
import 'package:collector/pages/history/maintenance/preventiveMaintenance/maintenancehistorysparecode.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class MyMaintenanceHistory extends StatefulWidget {
  final String subprocess;
  final Function(NotificationModel) onNotificationAdded;

  MyMaintenanceHistory(
      {required this.subprocess, required this.onNotificationAdded});

  @override
  _MyMaintenanceHistoryState createState() => _MyMaintenanceHistoryState();
}

class _MyMaintenanceHistoryState extends State<MyMaintenanceHistory> {
  List<MaintenanceEntry.MaintenanceEntry> maintenanceEntries = [];
  Map<String, List<MaintenanceEntry.MaintenanceEntry>>
      maintenanceEntriesByEquipment = {};
  Map<String, List<MaintenanceEntry.MaintenanceEntry>>
      maintenanceEntriesByTask = {};
  DateTime lastUpdate = DateTime.now();
  bool _updateExisting = false;
  List<MaintenanceDetails> maintenanceDetailsList = [];
  MaintenanceData maintenanceData = MaintenanceData();
  MaintenanceDetails? details;
  List<NotificationModel> _sampleNotification = [];
  @override
  void initState() {
    super.initState();
    _loadMaintenanceEntries(); // Load saved entries when the widget initializes
  }

  Future<void> loadMaintenanceDetails() async {
    await maintenanceData
        .loadMaintenanceDetails(); // Load maintenance details from file
    setState(() {
      details = maintenanceData.maintenanceDetailsList.isNotEmpty
          ? maintenanceData.maintenanceDetailsList.first
          : null; // Assign the first details if available, otherwise null
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadMaintenanceEntries();
    return Scaffold(
      appBar: AppBar(
        title: Text('Preventive Maintenance Checklist'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Equipment')),
                    DataColumn(label: Text('Inspection/Maintenance Task')),
                    DataColumn(label: Text('Last Update/Frequency')),
                    DataColumn(label: Text('Duration of Update')),
                    DataColumn(label: Text('Responsible Person')),
                  ],
                  rows:
                      _buildMaintenanceRows(), // Build rows based on grouped data
                  border: TableBorder.all(),
                ),
              ),
              SizedBox(
                  height:
                      20), // Add spacing between the data table and the new entry form
              ElevatedButton(
                onPressed: _addNewEntry,
                child: Text('Add New Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildMaintenanceRows() {
    List<DataRow> rows = [];

    // Iterate over each equipment entry in maintenanceEntriesByEquipment
    maintenanceEntriesByEquipment.forEach((equipment, entries) {
      // Add a DataRow for each equipment with its grouped maintenance entries
      rows.add(
        DataRow(cells: [
          DataCell(SizedBox.expand(
              child: TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MaintenanceDetailsPage()));
            },
            child: Text(equipment),
          ))),
          DataCell(SizedBox()), // Empty cell for task
          DataCell(SizedBox()), // Empty cell for last update
          DataCell(SizedBox()), // Empty cell for duration
          DataCell(SizedBox()), // Empty cell for responsible person
        ]),
      );

      // Add a DataRow for each maintenance entry of this equipment
      entries.forEach((entry) {
        rows.add(
          DataRow(cells: [
            DataCell(SizedBox()), // Empty cell for equipment
            DataCell(TextButton(
              onPressed: () {
                _addProcedure(context, entry);
              },
              child: Row(
                children: [
                  Text(entry.task),
                  _getTaskStateIcon(entry.taskState),
                ],
              ),
            )), // Display task
            DataCell(TextButton(
              onPressed: () {
                // Handle onPressed action
              },
              child: Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(entry.lastUpdate)), // Format DateTime
            )),
            DataCell(Text(entry.duration)), // Display duration
            DataCell(TextButton(
              onPressed: () {
                _addApprover(context);
              },
              child: Text(entry.responsiblePerson),
            )), // Display responsible person
          ]),
        );
      });

      // Add an empty row as separator
      rows.add(DataRow(cells: List.generate(5, (_) => DataCell(SizedBox()))));
    });

    return rows;
  }

  Future<void> _scheduleNextTask(
    BuildContext context,
    MaintenanceEntry.MaintenanceEntry entry,
  ) async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay(hour: 8, minute: 0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Schedule Next Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Date: ${selectedDate.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != selectedDate)
                    selectedDate = pickedDate;
                },
              ),
              ListTile(
                title: Text('Time: ${selectedTime.format(context)}'),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (pickedTime != null && pickedTime != selectedTime)
                    selectedTime = pickedTime;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                entry.lastUpdate = selectedDate;

                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addNewEntry() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Entry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text('Create New Equipment'),
                  leading: Radio(
                    value: false,
                    groupValue: _updateExisting,
                    onChanged: (value) {
                      setState(() {
                        _updateExisting = value as bool;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('Update Existing Existing'),
                  leading: Radio(
                    value: true,
                    groupValue: _updateExisting,
                    onChanged: (value) {
                      setState(() {
                        _updateExisting = value as bool;
                      });
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (_updateExisting) {
                    _showExistingEntriesDialog();
                  } else {
                    _showEntryForm(
                        ''); // Pass an empty string as equipment name
                  }
                },
                child: Text('Next'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showExistingEntriesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Entry to Update'),
          content: SingleChildScrollView(
            child: Column(
              children: maintenanceEntriesByEquipment.keys.map((equipment) {
                return ListTile(
                  title: Text(equipment),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showTaskUpdateDialog(equipment);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showTaskUpdateDialog(String equipment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Task or Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('Add New Task'),
                leading: Radio(
                  value: false,
                  groupValue: _updateExisting,
                  onChanged: (value) {
                    setState(() {
                      _updateExisting = value as bool;
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('Update Existing Task'),
                leading: Radio(
                  value: true,
                  groupValue: _updateExisting,
                  onChanged: (value) {
                    setState(() {
                      _updateExisting = value as bool;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_updateExisting) {
                  _showTaskSelectionDialog(equipment);
                } else {
                  _showEntryForm(equipment);
                }
              },
              child: Text('Next'),
            ),
          ],
        );
      },
    );
  }

  void _showTaskSelectionDialog(String equipment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Task to Update'),
          content: SingleChildScrollView(
            child: Column(
              children: maintenanceEntriesByEquipment[equipment]!.map((entry) {
                return ListTile(
                  title: Text(entry.task),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEntryForm(equipment, existingTask: entry.task);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showEntryForm(String equipment, {String? existingTask}) {
    String task = existingTask ?? '';
    DateTime lastUpdate = DateTime.now(); // Initialize with current date time
    String duration = '';
    String responsiblePerson = '';
    int updateCount = 1;
    MaintenanceEntry.TaskState taskState =
        MaintenanceEntry.TaskState.unactioned;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(existingTask == null ? 'Add New Entry' : 'Update Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                if (existingTask == null)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Equipment'),
                    initialValue: equipment,
                    onChanged: (value) {
                      equipment = value;
                    },
                  ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Task'),
                  initialValue: task,
                  onChanged: (value) {
                    task = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Duration'),
                  onChanged: (value) {
                    duration = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Responsible Person'),
                  onChanged: (value) {
                    responsiblePerson = value;
                  },
                ),
                DropdownButtonFormField<MaintenanceEntry.TaskState>(
                  value: taskState,
                  decoration: InputDecoration(labelText: 'Task State'),
                  onChanged: (value) {
                    setState(() {
                      taskState = value!;
                    });
                  },
                  items: MaintenanceEntry.TaskState.values
                      .map((MaintenanceEntry.TaskState state) {
                    return DropdownMenuItem<MaintenanceEntry.TaskState>(
                      value: state,
                      child: Text(state.toString().split('.').last),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  MaintenanceEntry.MaintenanceEntry newEntry =
                      MaintenanceEntry.MaintenanceEntry(
                    equipment: equipment,
                    task: task,
                    lastUpdate: lastUpdate,
                    updateCount: updateCount,
                    duration: duration,
                    responsiblePerson: responsiblePerson,
                    taskState: taskState,
                  );

                  if (existingTask == null) {
                    maintenanceEntries.add(newEntry);
                  } else {
                    maintenanceEntries.removeWhere((entry) =>
                        entry.equipment == equipment &&
                        entry.task == existingTask);
                    maintenanceEntries.add(newEntry);
                  }

                  _saveMaintenanceEntries();
                  _updateMaintenanceEntriesByEquipment();
                  final newNotification = NotificationModel(
                      title: 'New Maintenance Record Updated',
                      description: ' An Entry has been saved and Submitted',
                      timestamp: DateTime.timestamp(),
                      type: NotificationType.MaintenanceUpdate);
                  setState(() {
                    _sampleNotification.add(newNotification);
                    saveNotificationsToFile(_sampleNotification);
                  });
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addProcedure(
      BuildContext context, MaintenanceEntry.MaintenanceEntry entry) async {
    List<TextEditingController> stepsController = [TextEditingController()];
    List<TextEditingController> toolsController = [TextEditingController()];

    TextEditingController situationBeforeController = TextEditingController();
    TextEditingController situationAfterController = TextEditingController();
    bool situationResolved = false;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('List of Procedures'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: situationBeforeController,
                      decoration: InputDecoration(
                        labelText: 'Situation Before',
                      ),
                    ),
                    for (int i = 0; i < stepsController.length; i++)
                      TextField(
                        controller: stepsController[i],
                        decoration: InputDecoration(
                          labelText: 'Step ${i + 1}',
                        ),
                      ),
                    SizedBox(height: 5),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          stepsController.add(TextEditingController());
                        });
                      },
                      child: Text('Add Step'),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              toolsController.add(TextEditingController());
                            });
                          },
                          icon: Icon(Icons.build_circle),
                        ),
                        Text('List of Tools Used'),
                      ],
                    ),
                    for (int i = 0; i < toolsController.length; i++)
                      TextField(
                        controller: toolsController[i],
                        decoration: InputDecoration(
                          labelText: 'Tool ${i + 1}',
                        ),
                      ),
                    SizedBox(height: 5),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          toolsController.add(TextEditingController());
                        });
                      },
                      child: Text('Add Tool'),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: situationResolved,
                          onChanged: (value) {
                            setState(() {
                              situationResolved = value ?? false;
                            });
                          },
                        ),
                        Text('Situation Resolved'),
                      ],
                    ),
                    TextField(
                      controller: situationAfterController,
                      decoration: InputDecoration(
                        labelText: 'Situation After',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final details =
                        maintenanceData.maintenanceDetailsList.firstWhere(
                      (details) => details.equipment == entry.equipment,
                      orElse: () {
                        final newDetails = MaintenanceDetails(
                          equipment: entry.equipment,
                          tasks: [],
                        );
                        maintenanceData.maintenanceDetailsList.add(newDetails);
                        return newDetails;
                      },
                    );

                    final taskDetails = MaintenanceTaskDetails(
                      task: entry.task,
                      lastUpdate: entry.lastUpdate,
                      situationBefore: situationBeforeController.text,
                      stepsTaken: stepsController
                          .map((controller) => controller.text)
                          .toList(),
                      toolsUsed: toolsController
                          .map((controller) => controller.text)
                          .toList(),
                      situationResolved: situationResolved,
                      situationAfter: situationAfterController.text,
                      personResponsible: entry.responsiblePerson,
                    );

                    details.tasks.add(taskDetails);
                    maintenanceData.saveMaintenanceDetails();

                    Navigator.of(dialogContext).pop();

                    if (!situationResolved) {
                      await _scheduleNextTask(context, entry);
                    } else {
                      setState(() {});
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveProcedure({
    required String equipment,
    required String task,
    required String situationBefore,
    required List<String> stepsTaken,
    required List<String> toolsUsed,
    required bool situationResolved,
    required String situationAfter,
    required String personResponsible,
  }) {
    MaintenanceTaskDetails taskDetails = MaintenanceTaskDetails(
        task: task,
        lastUpdate: lastUpdate,
        situationBefore: situationBefore,
        stepsTaken: stepsTaken,
        toolsUsed: toolsUsed,
        situationResolved: situationResolved,
        situationAfter: situationAfter,
        personResponsible:
            personResponsible); // Find the existing maintenance details for the equipment
    MaintenanceDetails? existingDetails =
        maintenanceDetailsList.firstWhereOrNull(
      (details) => details.equipment == equipment,
    );
    if (existingDetails != null) {
      // If the details exist, add the new task to the list of tasks
      existingDetails.tasks.add(taskDetails);
    } else {
      // If no details exist for the equipment, create a new one with the task
      MaintenanceDetails newDetails = MaintenanceDetails(
        equipment: equipment,
        tasks: [taskDetails],
      );
      maintenanceDetailsList.add(newDetails);
    }

    // Save the maintenance details list
    _saveMaintenanceDetails(equipment, taskDetails);
  }

  Future<void> _saveMaintenanceDetails(
      String equipment, MaintenanceTaskDetails taskDetails) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/${widget.subprocess}/maintenance_details.json');
      List<MaintenanceDetails> detailsList = [];

      // Load existing data if the file exists
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        detailsList =
            jsonData.map((item) => MaintenanceDetails.fromJson(item)).toList();
      }

      // Find the existing maintenance details for the equipment
      MaintenanceDetails? existingDetails = detailsList.firstWhereOrNull(
        (details) => details.equipment == equipment,
      );

      if (existingDetails != null) {
        // If the details exist, add the new task to the list of tasks
        existingDetails.tasks.add(taskDetails);
      } else {
        // If no details exist for the equipment, create a new one with the task
        MaintenanceDetails newDetails = MaintenanceDetails(
          equipment: equipment,
          tasks: [taskDetails],
        );
        detailsList.add(newDetails);
      }

      // Save back to the file
      String jsonString =
          json.encode(detailsList.map((detail) => detail.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving maintenance details: $e');
    }
  }

  Future<void> _addEquipmentUsed(BuildContext context) async {
    List<TextEditingController> apparatusController = [TextEditingController()];
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('List of Tools and Equipment Used'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < apparatusController.length; i++)
                    TextField(
                      controller: apparatusController[i],
                      decoration: InputDecoration(
                          labelText: 'Tool ${i + 1}',
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {}, icon: Icon(Icons.image))
                            ],
                          )),
                      onChanged: (value) {},
                    ),
                  SizedBox(
                    height: 5,
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          apparatusController.add(TextEditingController());
                        });
                      },
                      icon: Icon(Icons.add)),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(onPressed: () {}, child: Text('Save')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'))
                    ],
                  )
                ],
              ),
            );
          });
        });
  }

  void _addApprover(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Approver'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Add your form fields here
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Add your save logic here
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _getTaskStateIcon(MaintenanceEntry.TaskState taskState) {
    switch (taskState) {
      case MaintenanceEntry.TaskState.unactioned:
        return Icon(Icons.warning, color: Colors.red);
      case MaintenanceEntry.TaskState.inProgress:
        return Icon(Icons.work, color: Colors.orange);
      case MaintenanceEntry.TaskState.completed:
        return Icon(Icons.check_circle, color: Colors.green);
    }
  }

  Future<void> _loadMaintenanceEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file =
          File('${directory.path}/${widget.subprocess}/maintenance.json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        maintenanceEntries = jsonData
            .map((item) => MaintenanceEntry.MaintenanceEntry.fromJson(item))
            .toList();

        // Rebuild maintenanceEntriesByEquipment based on loaded maintenanceEntries
        maintenanceEntriesByEquipment = {};
        maintenanceEntries.forEach((entry) {
          if (!maintenanceEntriesByEquipment.containsKey(entry.equipment)) {
            maintenanceEntriesByEquipment[entry.equipment] = [];
          }
          maintenanceEntriesByEquipment[entry.equipment]!.add(entry);
        });
      }
    } catch (e) {
      print('Error loading maintenance entries: $e');
    }
    setState(() {});
  }

  Future<void> _saveMaintenanceEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file =
          File('${directory.path}/${widget.subprocess}/maintenance.json');

      // Update existing task if it exists, otherwise add the new task
      for (var entry in maintenanceEntries) {
        final index = maintenanceEntries.indexWhere(
            (e) => e.equipment == entry.equipment && e.task == entry.task);
        if (index != -1) {
          maintenanceEntries[index] = entry; // Update existing task
        } else {
          maintenanceEntries.add(entry); // Add new task
        }
      }

      String jsonString = json
          .encode(maintenanceEntries.map((entry) => entry.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving maintenance entries: $e');
    }
  }

  void _updateMaintenanceEntriesByEquipment() {
    maintenanceEntriesByEquipment.clear();
    maintenanceEntries.forEach((entry) {
      if (!maintenanceEntriesByEquipment.containsKey(entry.equipment)) {
        maintenanceEntriesByEquipment[entry.equipment] = [];
      }
      maintenanceEntriesByEquipment[entry.equipment]!.add(entry);
    });
  }

  void _updateMaintenanceDetailsPage() async {
    String equipment = '';
    String task = '';
    DateTime lastUpdate = DateTime.now();
    String situationBefor = '';
    List<String> stepsTaken = [];
    List<String> toolsUsed = [];
    bool situationResolved = false;
    String situationAfter = '';
    String personResponsible = '';
  }

  Future<void> _loadMaintenanceDetails() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/${widget.subprocess}/maintenance_details.json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        maintenanceDetailsList =
            jsonData.map((item) => MaintenanceDetails.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading maintenance details: $e');
    }
    setState(() {});
  }
}