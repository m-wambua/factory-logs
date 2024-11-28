import 'dart:convert';
import 'dart:io';
import 'package:collector/pages/pages2/equipment/history/maintenance/preventiveMaintenance/detailsmaintenance.dart';
import 'package:collector/pages/pages2/equipment/history/maintenance/preventiveMaintenance/maintenance_details.dart';
import 'package:collector/pages/pages2/equipment/history/maintenance/preventiveMaintenance/maintenance_entry.dart'
    as MaintenanceEntry;
import 'package:collector/pages/models/notification.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class MyMaintenanceHistory extends StatefulWidget {
  final String subprocess;
  final String equipmentName;
  final String processName;
  final Function(NotificationModel) onNotificationAdded;

  const MyMaintenanceHistory(
      {super.key,
      required this.processName,
      required this.equipmentName,
      required this.subprocess,
      required this.onNotificationAdded});

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
  final List<NotificationModel> _sampleNotification = [];

  List<MaintenanceEntry.MaintenanceEntry> maintenanceEntryList = [];
  @override
  void initState() {
    super.initState();
    _loadMaintenanceEntries(); // Load saved entries when the widget initializes
  }

  Future<void> loadMaintenanceDetails() async {
    await MaintenanceData.loadMaintenanceDetails(
        widget.equipmentName); // Load maintenance details from file
    setState(() {
      maintenanceDetailsList = maintenanceData
          .maintenanceDetailsList; // Assign the first details if available, otherwise null
    });
  }

  Future<void> loadMaintentanceEntries() async {
    try {
      var maintenanceEntry =
          await MaintenanceEntry.MaintenanceEntry.loadMaintenanceEntry(
              widget.equipmentName);
      setState(() {
        maintenanceEntry = maintenanceEntryList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading maintenance list: $e')));
    }
  }

  Future<void> deleteMaintenanceList(int index) async {
    setState(() {
      MaintenanceEntry.MaintenanceEntry.deleteMaintenanceEntry(
          widget.equipmentName);
    });
    await saveMaintenanceEntry();
  }

  Future<void> showDeleteConfirmation(int index) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Are you sure you want to delete this Maintenance Entry?'),
                  Text('This action is permanent and cannot be reverted')
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cance'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  onPressed: () {
                    deleteMaintenanceList(index);
                  },
                  child: Text('Delete'))
            ],
          );
        });
  }

  Future<void> saveMaintenanceEntry() async {
    try {
      await MaintenanceEntry.MaintenanceEntry.saveMaintenanceEntry(
          maintenanceEntryList, widget.equipmentName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving maintenance list: $e')),
      );
    }
  }

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
            Text(
                'Preventive Maintenance Checklist for ${widget.equipmentName}'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                child: DataTable(
                  columns: const [
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
              const SizedBox(
                  height:
                      20), // Add spacing between the data table and the new entry form
              ElevatedButton(
                onPressed: _addNewEntry,
                child: const Text('Add New Entry'),
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
    Set<String> uniqueEntries = <String>{};
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
                      builder: (context) => MaintenanceDetailsPage(
                            subprocess: widget.equipmentName,
                          )));
            },
            child: Text(equipment),
          ))),
          const DataCell(SizedBox()), // Empty cell for task
          const DataCell(SizedBox()), // Empty cell for last update
          const DataCell(SizedBox()), // Empty cell for duration
          const DataCell(SizedBox()), // Empty cell for responsible person
        ]),
      );

      // Add a DataRow for each maintenance entry of this equipment
      for (var entry in entries) {
        bool checklistPresent = entry.checklistItems.isNotEmpty;
        rows.add(
          DataRow(cells: [
            const DataCell(SizedBox()), // Empty cell for equipment
            DataCell(TextButton(
              onPressed: () {
                _addProcedure(context, entry, entry.checklistItems);
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
            DataCell(Row(
              children: [
                TextButton(
                  onPressed: () {
                    _addApprover(context);
                  },
                  child: Text(entry.responsiblePerson),
                ),
                if (checklistPresent)
                  IconButton(
                      onPressed: () {
                        _showCheckListDetailsDialog(
                            context, entry.checklistItems);
                        //Handle list icon on pressed action
                        //You can navigate to another page or show a dialog for checklist items here
                      },
                      icon: const Icon(Icons.list))
              ],
            )), // Display responsible person
          ]),
        );
      }

      // Add an empty row as separator
      rows.add(
          DataRow(cells: List.generate(5, (_) => const DataCell(SizedBox()))));
    });

    return rows;
  }

  void _showCheckListDetailsDialog(
      BuildContext context, List<ChecklistItem> checklistItems) {
    List<Map<String, dynamic>> items =
        []; // List to hold checklist items and their status
    for (var item in checklistItems) {
      items.add({
        'item': item.item, // Make sure to access the actual item string
        'isChecked': false, // initialize with unchecked status
        'comment': '', // initialize empty additional note
      });
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Checklist Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display checklist items with checkbox and optional note field
                for (var item in items)
                  Row(
                    children: [
                      Checkbox(
                        value: item['isChecked'],
                        onChanged: (bool? value) {
                          setState(() {
                            item['isChecked'] = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(child: Text(item['item'] ?? '')),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: const InputDecoration(
                              hintText: 'Additional note'),
                          onChanged: (value) {
                            setState(() {
                              item['comment'] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _scheduleNextTask(
    BuildContext context,
    MaintenanceEntry.MaintenanceEntry entry,
  ) async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Schedule Next Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Date: ${selectedDate.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    selectedDate = pickedDate;
                  }
                },
              ),
              ListTile(
                title: Text('Time: ${selectedTime.format(context)}'),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (pickedTime != null && pickedTime != selectedTime) {
                    selectedTime = pickedTime;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                entry.lastUpdate = selectedDate;

                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Save'),
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
            title: const Text('Add New Entry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Create New Equipment'),
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
                  title: const Text('Update Existing Existing'),
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
                child: const Text('Cancel'),
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
                child: const Text('Next'),
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
          title: const Text('Select Entry to Update'),
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
          title: const Text('Update Task or Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text('Add New Task'),
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
                title: const Text('Update Existing Task'),
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
              child: const Text('Cancel'),
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
              child: const Text('Next'),
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
          title: const Text('Select Task to Update'),
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
    bool addChecklist = false;
    List<ChecklistItem> checklistItems =
        []; // Initialize empty checklist items list

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title:
                  Text(existingTask == null ? 'Add New Entry' : 'Update Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (existingTask == null)
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Equipment'),
                        initialValue: equipment,
                        onChanged: (value) {
                          equipment = value;
                        },
                      ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Task'),
                      initialValue: task,
                      onChanged: (value) {
                        task = value;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Duration'),
                      onChanged: (value) {
                        duration = value;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Responsible Person'),
                      onChanged: (value) {
                        responsiblePerson = value;
                      },
                    ),
                    DropdownButtonFormField<MaintenanceEntry.TaskState>(
                      value: taskState,
                      decoration:
                          const InputDecoration(labelText: 'Task State'),
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: addChecklist,
                          onChanged: (value) async {
                            setState(() {
                              addChecklist = value ?? false;
                            });
                            if (addChecklist) {
                              List<String>? result = await _showChecklistDialog(
                                  context, checklistItems);
                              if (result != null) {
                                setState(() {
                                  checklistItems = result
                                      .map((item) => ChecklistItem(
                                          item: item,
                                          isChecked: false,
                                          comment: ''))
                                      .toList();
                                });
                              }
                            }
                          },
                        ),
                        const Text('Do you wish to add a checklist?'),
                      ],
                    ),
                    if (checklistItems.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Checklist Items:'),
                          const SizedBox(height: 8),
                          ...checklistItems
                              .map((item) => ListTile(title: Text(item.item))),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
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
                        checklistItems: checklistItems,
                      );

                      if (existingTask == null) {
                        maintenanceEntries.add(newEntry);
                        maintenanceEntryList.add(newEntry);
                      } else {
                        maintenanceEntries.removeWhere((entry) =>
                            entry.equipment == equipment &&
                            entry.task == existingTask);
                        maintenanceEntries.add(newEntry);
                      }

                      _saveMaintenanceEntries();
                      saveMaintenanceEntry();
                      _updateMaintenanceEntriesByEquipment();
                      _updateMaintenanceDetailsPage();

                      final newNotification = NotificationModel(
                        title: 'New Maintenance Record Updated',
                        description: 'An entry has been saved and submitted',
                        timestamp: DateTime.now(),
                        type: NotificationType.MaintenanceUpdate,
                      );
                      _sampleNotification.add(newNotification);
                      saveNotificationsToFile(_sampleNotification);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<String>?> _showChecklistDialog(
      BuildContext context, List<ChecklistItem> currentItems) async {
    List<String> checklistItems =
        currentItems.map((item) => item.item).toList();
    TextEditingController checklistController = TextEditingController();
    List<String> newItems = []; // Track new items added

    return await showDialog<List<String>?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Checklist'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: double.maxFinite, // Set maximum width
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 200, // Set a fixed height for the list
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...checklistItems.map((item) => ListTile(
                                  title: Text(item),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        checklistItems.remove(item);
                                      });
                                    },
                                  ),
                                )),
                            ...newItems.map((item) => ListTile(
                                  title: Text(item),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        newItems.remove(item);
                                      });
                                    },
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: checklistController,
                      decoration:
                          const InputDecoration(labelText: 'Checklist Item'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (checklistController.text.isNotEmpty) {
                            newItems.add(checklistController.text);
                            checklistController.clear(); // Clear the text field
                          }
                        });
                      },
                      child: const Text('Add Item'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Combine current items with new items
                List<String> updatedChecklistItems = [
                  ...checklistItems,
                  ...newItems
                ];
                Navigator.of(context).pop(updatedChecklistItems);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addProcedure(
      BuildContext context,
      MaintenanceEntry.MaintenanceEntry entry,
      List<ChecklistItem> currentItems) async {
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
              title: const Text('List of Procedures'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: situationBeforeController,
                      decoration: const InputDecoration(
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
                    const SizedBox(height: 5),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          stepsController.add(TextEditingController());
                        });
                      },
                      child: const Text('Add Step'),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              toolsController.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.build_circle),
                        ),
                        const Text('List of Tools Used'),
                      ],
                    ),
                    for (int i = 0; i < toolsController.length; i++)
                      TextField(
                        controller: toolsController[i],
                        decoration: InputDecoration(
                          labelText: 'Tool ${i + 1}',
                        ),
                      ),
                    const SizedBox(height: 5),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          toolsController.add(TextEditingController());
                        });
                      },
                      child: const Text('Add Tool'),
                    ),
                    const SizedBox(height: 5),
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
                        const Text('Situation Resolved'),
                      ],
                    ),
                    TextField(
                      controller: situationAfterController,
                      decoration: const InputDecoration(
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
                  child: const Text('Cancel'),
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
                        checklist: currentItems);

                    details.tasks.add(taskDetails);
                    MaintenanceData.saveMaintenanceDetails(
                        widget.equipmentName, maintenanceDetailsList);

                    Navigator.of(dialogContext).pop();

                    if (!situationResolved) {
                      await _scheduleNextTask(context, entry);
                    } else {
                      setState(() {});
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveMaintenanceDetails(
      String equipment, MaintenanceTaskDetails taskDetails) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/${widget.equipmentName}/maintenance_details.json');
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
              title: const Text('List of Tools and Equipment Used'),
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
                                  onPressed: () {},
                                  icon: const Icon(Icons.image))
                            ],
                          )),
                      onChanged: (value) {},
                    ),
                  const SizedBox(
                    height: 5,
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          apparatusController.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add)),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Save')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'))
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
          title: const Text('Add Approver'),
          content: const SingleChildScrollView(
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Add your save logic here
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _getTaskStateIcon(MaintenanceEntry.TaskState taskState) {
    switch (taskState) {
      case MaintenanceEntry.TaskState.unactioned:
        return const Icon(Icons.warning, color: Colors.red);
      case MaintenanceEntry.TaskState.inProgress:
        return const Icon(Icons.work, color: Colors.orange);
      case MaintenanceEntry.TaskState.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
    }
  }

  Future<void> _loadMaintenanceEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file =
          File('${directory.path}/${widget.equipmentName}/maintenance.json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        maintenanceEntries = jsonData
            .map((item) => MaintenanceEntry.MaintenanceEntry.fromJson(item))
            .toList();

        // Rebuild maintenanceEntriesByEquipment based on loaded maintenanceEntries
        maintenanceEntriesByEquipment = {};
        for (var entry in maintenanceEntries) {
          if (!maintenanceEntriesByEquipment.containsKey(entry.equipment)) {
            maintenanceEntriesByEquipment[entry.equipment] = [];
          }
          maintenanceEntriesByEquipment[entry.equipment]!.add(entry);
        }
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
          File('${directory.path}/${widget.equipmentName}/maintenance.json');

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
    for (var entry in maintenanceEntries) {
      if (!maintenanceEntriesByEquipment.containsKey(entry.equipment)) {
        maintenanceEntriesByEquipment[entry.equipment] = [];
      }
      maintenanceEntriesByEquipment[entry.equipment]!.add(entry);
    }
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
          '${directory.path}/${widget.equipmentName}/maintenance_details.json');
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
