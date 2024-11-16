import 'package:collector/pages/pages2/equipment/history/maintenance/failureMaintenance/failureDetails.dart';
import 'package:collector/pages/pages2/equipment/history/maintenance/failureMaintenance/failureDetailsPage.dart';
import 'package:collector/pages/pages2/equipment/history/maintenance/failureMaintenance/failureEntry.dart'
    as FailureEntry;
import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';

class FailureHistory extends StatefulWidget {
  final String subprocess;
  FailureHistory({required this.subprocess});
  @override
  _FailureHistoryState createState() => _FailureHistoryState();
}

class _FailureHistoryState extends State<FailureHistory> {
  List<FailureEntry.MaintenanceEntry> failureEntries = [];
  Map<String, List<FailureEntry.MaintenanceEntry>> failureEntriesEquipment = {};
  Map<String, List<FailureEntry.MaintenanceEntry>> failureEntriesByTask = {};
  DateTime lastUpdate = DateTime.now();

  bool _updateExisting = false;
  List<FailureDetails> failureDetailList = [];
  FailureData failureData = FailureData();
  @override
  void initState() {
    super.initState();
    _loadFailureEntries();
  }

  Future<void> _loadFailureDetailsEntries() async {
    await failureData.loadFailureDetails();
    setState(() {
      failureDetailList = failureData.FailureDetailsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadFailureEntries();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Image.asset(AppAssets.deltalogo),
            ),
            Text('${widget.subprocess} Failure  Maintenance Checklist'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DataTable(
              columns: [
                DataColumn(label: Text('Equipment')),
                DataColumn(label: Text('Maintenance Task')),
                DataColumn(label: Text('Previuos Occurence')),
                DataColumn(label: Text('Duration of Maintenance ')),
                DataColumn(label: Text('Person Responsible'))
              ],
              rows: _buildFailureRows(),
              border: TableBorder.all(),
            ),
            SizedBox(
              height: 20,
            ),
            IconButton(onPressed: _addNewEntry, icon: Icon(Icons.add))
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildFailureRows() {
    List<DataRow> rows = [];
    Set<String> uniqueEntries = Set<String>();

    failureEntriesEquipment.forEach((equipment, entries) {
      rows.add(DataRow(cells: [
        DataCell(SizedBox.expand(
            child: TextButton(
          child: Text(equipment),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FailureDetailsPage()));
          },
        ))),
        DataCell(SizedBox()),
        DataCell(SizedBox()),
        DataCell(SizedBox()),
        DataCell(SizedBox())
      ]));

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
              children: failureEntriesEquipment.keys.map((equipment) {
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
              children: failureEntriesEquipment[equipment]!.map((entry) {
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
    FailureEntry.TaskState taskState = FailureEntry.TaskState.unactioned;

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
                DropdownButtonFormField<FailureEntry.TaskState>(
                  value: taskState,
                  decoration: InputDecoration(labelText: 'Task State'),
                  onChanged: (value) {
                    setState(() {
                      taskState = value!;
                    });
                  },
                  items: FailureEntry.TaskState.values
                      .map((FailureEntry.TaskState state) {
                    return DropdownMenuItem<FailureEntry.TaskState>(
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
                  FailureEntry.MaintenanceEntry newEntry =
                      FailureEntry.MaintenanceEntry(
                    equipment: equipment,
                    task: task,
                    lastUpdate: lastUpdate,
                    updateCount: updateCount,
                    duration: duration,
                    responsiblePerson: responsiblePerson,
                    taskState: taskState,
                  );

                  if (existingTask == null) {
                    failureEntries.add(newEntry);
                  } else {
                    failureEntries.removeWhere((entry) =>
                        entry.equipment == equipment &&
                        entry.task == existingTask);
                    failureEntries.add(newEntry);
                  }

                  _saveFailureEntries();
                  _updateFailureEntriesByEquipment();
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
      BuildContext context, FailureEntry.MaintenanceEntry entry) async {
    List<TextEditingController> stepsController = [TextEditingController()];
    List<TextEditingController> toolsController = [TextEditingController()];

    TextEditingController situationBeforeController = TextEditingController();
    TextEditingController situationAfterController = TextEditingController();
    bool situationResolved = false;

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
                  onPressed: () {
                    final details = failureData.FailureDetailsList.firstWhere(
                      (details) => details.equipment == entry.equipment,
                      orElse: () {
                        final newDetails = FailureDetails(
                          equipment: entry.equipment,
                          tasks: [],
                        );
                        failureData.FailureDetailsList.add(newDetails);
                        return newDetails;
                      },
                    );

                    final taskDetails = FailureTaskDetails(
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

                    failureData.saveFailureDetails();

                    setState(() {});

                    Navigator.of(dialogContext).pop();
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
    FailureTaskDetails taskDetails = FailureTaskDetails(
        task: task,
        lastUpdate: lastUpdate,
        situationBefore: situationBefore,
        stepsTaken: stepsTaken,
        toolsUsed: toolsUsed,
        situationResolved: situationResolved,
        situationAfter: situationAfter,
        personResponsible:
            personResponsible); // Find the existing maintenance details for the equipment
    FailureDetails? existingDetails = failureDetailList.firstWhereOrNull(
      (details) => details.equipment == equipment,
    );
    if (existingDetails != null) {
      // If the details exist, add the new task to the list of tasks
      existingDetails.tasks.add(taskDetails);
    } else {
      // If no details exist for the equipment, create a new one with the task
      FailureDetails newDetails = FailureDetails(
        equipment: equipment,
        tasks: [taskDetails],
      );
      failureDetailList.add(newDetails);
    }

    // Save the maintenance details list
    _saveFailureDetails(equipment, taskDetails);
  }

  Future<void> _saveFailureDetails(
      String equipment, FailureTaskDetails taskDetails) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file =
          File('${directory.path}/${widget.subprocess}/failure_details.json');
      List<FailureDetails> detailsList = [];

      // Load existing data if the file exists
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        detailsList =
            jsonData.map((item) => FailureDetails.fromJson(item)).toList();
      }

      // Find the existing maintenance details for the equipment
      FailureDetails? existingDetails = detailsList.firstWhereOrNull(
        (details) => details.equipment == equipment,
      );

      if (existingDetails != null) {
        // If the details exist, add the new task to the list of tasks
        existingDetails.tasks.add(taskDetails);
      } else {
        // If no details exist for the equipment, create a new one with the task
        FailureDetails newDetails = FailureDetails(
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

  Widget _getTaskStateIcon(FailureEntry.TaskState taskState) {
    switch (taskState) {
      case FailureEntry.TaskState.unactioned:
        return Icon(Icons.warning, color: Colors.red);
      case FailureEntry.TaskState.inProgress:
        return Icon(Icons.work, color: Colors.orange);
      case FailureEntry.TaskState.completed:
        return Icon(Icons.check_circle, color: Colors.green);
    }
  }

  Future<void> _loadFailureEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${widget.subprocess}/failure.json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        failureEntries = jsonData
            .map((item) => FailureEntry.MaintenanceEntry.fromJson(item))
            .toList();

        // Rebuild maintenanceEntriesByEquipment based on loaded maintenanceEntries
        failureEntriesEquipment = {};
        failureEntries.forEach((entry) {
          if (!failureEntriesEquipment.containsKey(entry.equipment)) {
            failureEntriesEquipment[entry.equipment] = [];
          }
          failureEntriesEquipment[entry.equipment]!.add(entry);
        });
      }
    } catch (e) {
      print('Error loading maintenance entries: $e');
    }
    setState(() {});
  }

  Future<void> _saveFailureEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${widget.subprocess}/failure.json');

      // Update existing task if it exists, otherwise add the new task
      for (var entry in failureEntries) {
        final index = failureEntries.indexWhere(
            (e) => e.equipment == entry.equipment && e.task == entry.task);
        if (index != -1) {
          failureEntries[index] = entry; // Update existing task
        } else {
          failureEntries.add(entry); // Add new task
        }
      }

      String jsonString =
          json.encode(failureEntries.map((entry) => entry.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving maintenance entries: $e');
    }
  }

  void _updateFailureEntriesByEquipment() {
    failureEntriesEquipment.clear();
    failureEntries.forEach((entry) {
      if (!failureEntriesEquipment.containsKey(entry.equipment)) {
        failureEntriesEquipment[entry.equipment] = [];
      }
      failureEntriesEquipment[entry.equipment]!.add(entry);
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
      final file =
          File('${directory.path}/${widget.subprocess}/failure_details.json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        failureDetailList =
            jsonData.map((item) => FailureDetails.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading maintenance details: $e');
    }
    setState(() {});
  }
}
