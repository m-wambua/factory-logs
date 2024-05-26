import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class MaintenanceEntry {
  String equipment;
  String task;
  DateTime lastUpdate;
  int updateCount;
  String duration;
  String responsiblePerson;

  MaintenanceEntry({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
    required this.updateCount,
    required this.duration,
    required this.responsiblePerson,
  });

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'task': task,
      'lastUpdate': lastUpdate,
      'duration': duration,
      'responsiblePerson': responsiblePerson
    };
  }

  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    return MaintenanceEntry(
        equipment: json['equipment'],
        task: json['task'],
        lastUpdate: json['lastUpdate'],
        updateCount: json['updateCount'],
        duration: json['duration'],
        responsiblePerson: json['responsiblePerson']);
  }
}

class MyMaintenanceHistory extends StatefulWidget {
  String subprocess;

  MyMaintenanceHistory({required this.subprocess});
  @override
  _MyMaintenanceHistoryState createState() => _MyMaintenanceHistoryState();
}

class _MyMaintenanceHistoryState extends State<MyMaintenanceHistory> {
  List<MaintenanceEntry> maintenanceEntries = [];
  Map<String, List<MaintenanceEntry>> maintenanceEntriesByEquipment = {};
  DateTime lastUpdate = DateTime.now();
  //late final String _subprocess;

  bool _updateExisting = false;
  @override
  void initState() {
    super.initState();
    _loadMaintenanceEntries(); //Load Saved entries when the widget initialized
  }

  @override
  Widget build(BuildContext context) {
    //_subprocess = ModalRoute.of(context)?.settings.arguments as String;

    //final String subprocess = _subprocess;
    //_createMaintenanceFolder(subprocess);

    _loadMaintenanceEntries();
    return Scaffold(
      appBar: AppBar(
        title: Text('Preventive Maintenance Checklist '),
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
                      DataColumn(label: Text('Responsible Person'))
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
          )),
    );
  }

  List<DataRow> _buildMaintenanceRows() {
    List<DataRow> rows = [];

    // Use a Set to store unique entries and avoid duplication
    Set<String> uniqueEntries = Set<String>();

    // Iterate over each equipment entry in maintenanceEntriesByEquipment
    maintenanceEntriesByEquipment.forEach((equipment, entries) {
      // Add a DataRow for each equipment with its grouped maintenance entries
      rows.add(
        DataRow(cells: [
          DataCell(SizedBox.expand(
            child: Text(equipment),
          )), // Display equipment name
          DataCell(SizedBox()), // Empty cell for task
          DataCell(SizedBox()), // Empty cell for last update
          DataCell(SizedBox()), // Empty cell for duration
          DataCell(SizedBox()), // Empty cell for responsible person
        ]),
      );

      // Add a DataRow for each maintenance entry of this equipment
      entries.forEach((entry) {
        // Generate a unique key for each entry based on equipment and task
        String entryKey = '$equipment-${entry.task}';
        // Check if the entry is unique, avoiding duplicates
        if (!uniqueEntries.contains(entryKey)) {
          rows.add(
            DataRow(cells: [
              DataCell(SizedBox()), // Empty cell for equipment
              DataCell(TextButton(
                onPressed: () {
                  _addProcedure(context);
                },
                child: Text(entry.task),
              )), // Display task
              DataCell(TextButton(
                onPressed: () {
                  // Handle onPressed action
                },
                child: Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                    .format(entry.lastUpdate)), // Format DateTime
              )),
// Display last update
              DataCell(Text(entry.duration)), // Display duration
              DataCell(TextButton(
                onPressed: () {
                  _addApprover(context);
                },
                child: Text(entry.responsiblePerson),
              )), // Display responsible person
            ]),
          );
          // Add the entry key to the set to mark it as displayed
          uniqueEntries.add(entryKey);
        }
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
    //Funtion to get the task details for prefilling the form
    MaintenanceEntry? getTaskDetails(String equipment, String task) {
      return maintenanceEntries.firstWhere(
          (entry) => entry.equipment == equipment && entry.task == task);
    }

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
                      }),
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
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_updateExisting) {
                      _showTaskSelectionDoalog(equipment);
                    } else {
                      _showEntryForm(equipment);
                    }
                  },
                  child: Text('Next'))
            ],
          );
        });
  }

  void _showTaskSelectionDoalog(String equipment) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Task to Update'),
            content: SingleChildScrollView(
              child: Column(
                  children:
                      maintenanceEntriesByEquipment[equipment]!.map((entry) {
                return ListTile(
                  title: Text(entry.task),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEntryForm(equipment, existingTask: entry.task);
                  },
                );
              }).toList()),
            ),
          );
        });
  }

  void _showEntryForm(String equipment, {String? existingTask}) {
    // Initialize form field values with empty strings
    String task = existingTask ?? '';
    DateTime lastUpdate = DateTime.now(); // Initialize with current date time
    String duration = '';
    String responsiblePerson = '';
    // Get the current update count for the task
    int updateCount = 0;
    if (existingTask != null) {
      var existingEntry = maintenanceEntries.firstWhere(
          (entry) => entry.equipment == equipment && entry.task == existingTask,
          orElse: () => MaintenanceEntry(
                equipment: equipment,
                task: existingTask,
                lastUpdate: DateTime.now(),
                updateCount: 0, // If entry doesn't exist, set updateCount to 0
                duration: '',
                responsiblePerson: '',
              ));
      updateCount = existingEntry.updateCount + 1; // Increment the updateCount
    }

    //String situationBefore = '';
    //String stepsTaken = '';
    //bool resolutionStatus = false;
    //String taskState = 'Not Actioned';

    // if updating an existing task , prefill the fields

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(existingTask == null ? 'Add New Entry' : 'Update Task'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: equipment,
                  decoration: InputDecoration(labelText: 'Equipment'),
                  onChanged: (value) {
                    equipment = value;
                  },
                  enabled: equipment
                      .isEmpty, // Make equipment editable if it's empty
                ),
                TextFormField(
                  initialValue: task,
                  decoration: InputDecoration(labelText: 'Task'),
                  onChanged: (value) {
                    task = value;
                  },
                  enabled: task.isEmpty,
                ),
                TextButton(
                  onPressed: () {
                    _selectDate(context); //Open the calender widget
                  },
                  child: Text('Last Update/Frequency'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Duration of Update'),
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
                  // Create a new entry with the provided form field values
                  maintenanceEntries.add(MaintenanceEntry(
                    equipment: equipment,
                    task: task,
                    lastUpdate: lastUpdate,
                    updateCount: updateCount,
                    duration: duration,
                    responsiblePerson: responsiblePerson,
                  ));
                });
                _saveMaintenanceEntries();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Calender Widget
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        //Update the last update when the selected dat
        lastUpdate = pickedDate;
      });
    }
  }

  Future<void> _addProcedure(BuildContext context) async {
    List<TextEditingController> proceduresController = [
      TextEditingController()
    ];

    TextEditingController situationBefore = TextEditingController();
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
                    /*Expanded(
                      
                      child: TextField(
                        controller: situationBefore,
                        decoration: InputDecoration(labelText: 'Current Situation',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: (){

                            }, icon: Icon(Icons.attach_file)),
                            IconButton(onPressed: (){}, icon: Icon(Icons.image))

                          ],
                        )
                        ),

                    ))*/
                    TextField(
                      controller: situationBefore,
                      decoration: InputDecoration(
                          labelText:
                              'Current Situation', // Try to find a word that fits here
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.attach_file)),
                              IconButton(
                                  onPressed: () {}, icon: Icon(Icons.image))
                            ],
                          )),
                    ),
                    for (int i = 1; i < proceduresController.length; i++)
                      TextField(
                        controller: proceduresController[i],
                        decoration: InputDecoration(
                            labelText: 'Step: $i',
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
                    TextButton(
                      onPressed: () {
                        setState(() {
                          proceduresController.add(TextEditingController());
                        });
                      },
                      child: Text('Add Steps Taken'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () {
                              _addEquipmentUsed(context);
                            },
                            icon: Icon(Icons.build_circle)),
                        Text('List of Equipment used')
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [
                      Text('Was Situation Resolved ?'),
                      Checkbox(
                          value: false,
                          onChanged: (value) {
                            setState(() {
                              situationResolved = value as bool;
                            });
                          }),
                    ]),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(onPressed: () {}, child: Text('Save')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'))
                      ],
                    )
                  ],
                ),
              ],
            );
          });
        });
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
                  for (int i = 1; i < apparatusController.length; i++)
                    TextField(
                      controller: apparatusController[i],
                      decoration: InputDecoration(
                          labelText: 'Tool $i',
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

  Future<void> _addApprover(BuildContext context) async {
    List<TextEditingController> designatedByControllers = [
      TextEditingController()
    ];

    List<TextEditingController> actionedByController = [
      TextEditingController()
    ];

    List<TextEditingController> approvedByController = [
      TextEditingController()
    ];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(' Add Approvals'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Designated by:'),
                  onChanged: (value) {},
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Actioned by'),
                  onChanged: (value) {},
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Approved by'),
                  onChanged: (value) {},
                )
              ],
            ),
          );
        });
  }

  void _saveMaintenanceEntries() async {
    final String folderPath = 'services/maintenance/files_and_folders/';
    //
    final file = File('$folderPath/maintenance.json');

    try {
      // Read existing data from file if it exists
      Map<String, dynamic> jsonData = {};
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        jsonData = jsonDecode(jsonString);
      }

      // Add new entries to existing data, avoiding duplicates
      maintenanceEntries.forEach((entry) {
        if (!jsonData.containsKey(entry.equipment)) {
          jsonData[entry.equipment] = [];
        }
        // Check if the entry already exists in jsonData, avoiding duplicates
        bool entryExists = jsonData[entry.equipment].any((existingEntry) =>
            existingEntry['task'] == entry.task &&
            existingEntry['lastUpdate'] == entry.lastUpdate &&
            existingEntry['duration'] == entry.duration &&
            existingEntry['responsiblePerson'] == entry.responsiblePerson);
        if (!entryExists) {
          jsonData[entry.equipment].add(entry.toJson());
        }
      });

      // Write updated data back to file
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      print('Error saving maintenance entries: $e');
    }
  }

  void _loadMaintenanceEntries() async {
    try {
      final String folderPath = 'services/preventive_maintenance/';
      final file = File('$folderPath/maintenance.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = jsonDecode(jsonString);

        // Clear existing entries before loading
        maintenanceEntries.clear();
        maintenanceEntriesByEquipment.clear(); // Clear existing map

        // Convert JSON data into maintenance entries
        jsonData.forEach((equipment, entriesData) {
          if (entriesData is List) {
            List<MaintenanceEntry> entries = [];
            entriesData.forEach((entryData) {
              MaintenanceEntry entry = MaintenanceEntry.fromJson(entryData);
              entries.add(entry);

              // Populate maintenanceEntriesByEquipment
              if (!maintenanceEntriesByEquipment.containsKey(equipment)) {
                maintenanceEntriesByEquipment[equipment] = [];
              }
              maintenanceEntriesByEquipment[equipment]!.add(entry);
            });
            maintenanceEntries
                .addAll(entries); // Add all entries to maintenanceEntries list
          }
        });

        setState(() {}); // Trigger UI update
      } else {
        print('Maintenance entries file does not exist.');
      }
    } catch (e, stackTrace) {
      print('Error loading maintenance entries: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _createMaintenanceFolder(String subprocess) async {
    String folderPath = 'services/maintenance/files_and_folders/$subprocess';
    Directory maintenanceDirectory = Directory(folderPath);
    bool exists = maintenanceDirectory.existsSync();
    if (!exists) {
      maintenanceDirectory.createSync(recursive: true);
      // Create subdirectory for files and images
      Directory filesDirectory =
          Directory('${maintenanceDirectory.path}/files');

      Directory imagesDirectory =
          Directory('${maintenanceDirectory.path}/images');
      filesDirectory.createSync();
      imagesDirectory.createSync();
    }
  }
}


/*
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MaintenanceEntry {
  String equipment;
  String task;
  String lastUpdate;
  String duration;
  String responsiblePerson;

  MaintenanceEntry({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
    required this.duration,
    required this.responsiblePerson,
  });

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'task': task,
      'lastUpdate': lastUpdate,
      'duration': duration,
      'responsiblePerson': responsiblePerson
    };
  }

  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    return MaintenanceEntry(
        equipment: json['equipment'],
        task: json['task'],
        lastUpdate: json['lastUpdate'],
        duration: json['duration'],
        responsiblePerson: json['responsiblePerson']);
  }
}

class MyMaintenanceHistory extends StatefulWidget {
  String subprocess;

  MyMaintenanceHistory({required this.subprocess});
  @override
  _MyMaintenanceHistoryState createState() => _MyMaintenanceHistoryState();
}

class _MyMaintenanceHistoryState extends State<MyMaintenanceHistory> {
  List<MaintenanceEntry> maintenanceEntries = [];
  Map<String, List<MaintenanceEntry>> maintenanceEntriesByEquipment = {};

  //late final String _subprocess;

  bool _updateExisting = false;
  @override
  void initState() {
    super.initState();
    _loadMaintenanceEntries(); //Load Saved entries when the widget initialized
  }

  @override
  Widget build(BuildContext context) {
    //_subprocess = ModalRoute.of(context)?.settings.arguments as String;

    //final String subprocess = _subprocess;
    //_createMaintenanceFolder(subprocess);

    _loadMaintenanceEntries();
    return Scaffold(
      appBar: AppBar(
        title: Text('Preventive Maintenance Checklist '),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DataTable(
              columns: [
                DataColumn(label: Text('Equipment')),
                DataColumn(label: Text('Inspection/Maintenance Task')),
                DataColumn(label: Text('Last Update/Frequency')),
                DataColumn(label: Text('Duration of Update')),
                DataColumn(label: Text('Responsible Person'))
              ],
              rows: _buildMaintenanceRows(), // Build rows based on grouped data
              border: TableBorder.all(),
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
    );
  }

  List<DataRow> _buildMaintenanceRows() {
    List<DataRow> rows = [];

    // Use a Set to store unique entries and avoid duplication
    Set<String> uniqueEntries = Set<String>();

    // Iterate over each equipment entry in maintenanceEntriesByEquipment
    maintenanceEntriesByEquipment.forEach((equipment, entries) {
      // Add a DataRow for each equipment with its grouped maintenance entries
      rows.add(
        DataRow(cells: [
          DataCell(SizedBox.expand(
            child: Text(equipment),
          )), // Display equipment name
          DataCell(SizedBox()), // Empty cell for task
          DataCell(SizedBox()), // Empty cell for last update
          DataCell(SizedBox()), // Empty cell for duration
          DataCell(SizedBox()), // Empty cell for responsible person
        ]),
      );

      // Add a DataRow for each maintenance entry of this equipment
      entries.forEach((entry) {
        // Generate a unique key for each entry based on equipment and task
        String entryKey = '$equipment-${entry.task}';
        // Check if the entry is unique, avoiding duplicates
        if (!uniqueEntries.contains(entryKey)) {
          rows.add(
            DataRow(cells: [
              DataCell(SizedBox()), // Empty cell for equipment
              DataCell(TextButton(
                onPressed: () {
                  _addProcedure(context);
                },
                child: Text(entry.task),
              )), // Display task
              DataCell(TextButton(
                onPressed: () {},
                child: Text(entry.lastUpdate),
              )), // Display last update
              DataCell(Text(entry.duration)), // Display duration
              DataCell(TextButton(
                onPressed: () {
                  _addApprover(context);
                },
                child: Text(entry.responsiblePerson),
              )), // Display responsible person
            ]),
          );
          // Add the entry key to the set to mark it as displayed
          uniqueEntries.add(entryKey);
        }
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
    //Funtion to get the task details for prefilling the form
    MaintenanceEntry? getTaskDetails(String equipment, String task) {
      return maintenanceEntries.firstWhere(
          (entry) => entry.equipment == equipment && entry.task == task);
    }

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
                      }),
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
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_updateExisting) {
                      _showTaskSelectionDoalog(equipment);
                    } else {
                      _showEntryForm(equipment);
                    }
                  },
                  child: Text('Next'))
            ],
          );
        });
  }

  void _showTaskSelectionDoalog(String equipment) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Task to Update'),
            content: SingleChildScrollView(
              child: Column(
                  children:
                      maintenanceEntriesByEquipment[equipment]!.map((entry) {
                return ListTile(
                  title: Text(entry.task),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEntryForm(equipment, existingTask: entry.task);
                  },
                );
              }).toList()),
            ),
          );
        });
  }

  void _showEntryForm(String equipment, {String? existingTask}) {
    // Initialize form field values with empty strings
    String task = existingTask ?? '';
    String lastUpdate = '';
    String duration = '';
    String responsiblePerson = '';
    String situationBefore = '';
    String stepsTaken = '';
    bool resolutionStatus = false;
    String taskState = 'Not Actioned';

    // if updating an existing task , prefill the fields

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(existingTask == null ? 'Add New Entry' : 'Update Task'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: equipment,
                  decoration: InputDecoration(labelText: 'Equipment'),
                  onChanged: (value) {
                    equipment = value;
                  },
                  enabled: equipment
                      .isEmpty, // Make equipment editable if it's empty
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Task'),
                  onChanged: (value) {
                    task = value;
                  },
                  enabled: task.isEmpty,
                ),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: 'Last Update/Frequency'),
                  onChanged: (value) {
                    lastUpdate = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Duration of Update'),
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
                  // Create a new entry with the provided form field values
                  maintenanceEntries.add(MaintenanceEntry(
                    equipment: equipment,
                    task: task,
                    lastUpdate: lastUpdate,
                    duration: duration,
                    responsiblePerson: responsiblePerson,
                  ));
                });
                _saveMaintenanceEntries();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addProcedure(BuildContext context) async {
    List<TextEditingController> proceduresController = [
      TextEditingController()
    ];

    TextEditingController situationBefore = TextEditingController();
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
                    /*Expanded(
                      
                      child: TextField(
                        controller: situationBefore,
                        decoration: InputDecoration(labelText: 'Current Situation',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: (){

                            }, icon: Icon(Icons.attach_file)),
                            IconButton(onPressed: (){}, icon: Icon(Icons.image))

                          ],
                        )
                        ),

                    ))*/
                    TextField(
                      controller: situationBefore,
                      decoration: InputDecoration(
                          labelText:
                              'Current Situation', // Try to find a word that fits here
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.attach_file)),
                              IconButton(
                                  onPressed: () {}, icon: Icon(Icons.image))
                            ],
                          )),
                    ),
                    for (int i = 1; i < proceduresController.length; i++)
                      TextField(
                        controller: proceduresController[i],
                        decoration: InputDecoration(
                            labelText: 'Step: $i',
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
                    TextButton(
                      onPressed: () {
                        setState(() {
                          proceduresController.add(TextEditingController());
                        });
                      },
                      child: Text('Add Steps Taken'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () {
                              _addEquipmentUsed(context);
                            },
                            icon: Icon(Icons.build_circle)),
                        Text('List of Equipment used')
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [
                      Text('Was Situation Resolved ?'),
                      Checkbox(
                          value: false,
                          onChanged: (value) {
                            setState(() {
                              situationResolved = value as bool;
                            });
                          }),
                    ]),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(onPressed: () {}, child: Text('Save')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'))
                      ],
                    )
                  ],
                ),
              ],
            );
          });
        });
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
                  for (int i = 1; i < apparatusController.length; i++)
                    TextField(
                      controller: apparatusController[i],
                      decoration: InputDecoration(
                          labelText: 'Tool $i',
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

  Future<void> _addApprover(BuildContext context) async {
    List<TextEditingController> designatedByControllers = [
      TextEditingController()
    ];

    List<TextEditingController> actionedByController = [
      TextEditingController()
    ];

    List<TextEditingController> approvedByController = [
      TextEditingController()
    ];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(' Add Approvals'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Designated by:'),
                  onChanged: (value) {},
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Actioned by'),
                  onChanged: (value) {},
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Approved by'),
                  onChanged: (value) {},
                )
              ],
            ),
          );
        });
  }

  void _saveMaintenanceEntries() async {
    final String folderPath = 'services/maintenance/files_and_folders/';
    //
    final file = File('$folderPath/maintenance.json');

    try {
      // Read existing data from file if it exists
      Map<String, dynamic> jsonData = {};
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        jsonData = jsonDecode(jsonString);
      }

      // Add new entries to existing data, avoiding duplicates
      maintenanceEntries.forEach((entry) {
        if (!jsonData.containsKey(entry.equipment)) {
          jsonData[entry.equipment] = [];
        }
        // Check if the entry already exists in jsonData, avoiding duplicates
        bool entryExists = jsonData[entry.equipment].any((existingEntry) =>
            existingEntry['task'] == entry.task &&
            existingEntry['lastUpdate'] == entry.lastUpdate &&
            existingEntry['duration'] == entry.duration &&
            existingEntry['responsiblePerson'] == entry.responsiblePerson);
        if (!entryExists) {
          jsonData[entry.equipment].add(entry.toJson());
        }
      });

      // Write updated data back to file
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      print('Error saving maintenance entries: $e');
    }
  }

  void _loadMaintenanceEntries() async {
    try {
      final String folderPath = 'services/preventive_maintenance/';
      final file = File('$folderPath/maintenance.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = jsonDecode(jsonString);

        // Clear existing entries before loading
        maintenanceEntries.clear();
        maintenanceEntriesByEquipment.clear(); // Clear existing map

        // Convert JSON data into maintenance entries
        jsonData.forEach((equipment, entriesData) {
          if (entriesData is List) {
            List<MaintenanceEntry> entries = [];
            entriesData.forEach((entryData) {
              MaintenanceEntry entry = MaintenanceEntry.fromJson(entryData);
              entries.add(entry);

              // Populate maintenanceEntriesByEquipment
              if (!maintenanceEntriesByEquipment.containsKey(equipment)) {
                maintenanceEntriesByEquipment[equipment] = [];
              }
              maintenanceEntriesByEquipment[equipment]!.add(entry);
            });
            maintenanceEntries
                .addAll(entries); // Add all entries to maintenanceEntries list
          }
        });

        setState(() {}); // Trigger UI update
      } else {
        print('Maintenance entries file does not exist.');
      }
    } catch (e, stackTrace) {
      print('Error loading maintenance entries: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _createMaintenanceFolder(String subprocess) async {
    String folderPath = 'services/maintenance/files_and_folders/$subprocess';
    Directory maintenanceDirectory = Directory(folderPath);
    bool exists = maintenanceDirectory.existsSync();
    if (!exists) {
      maintenanceDirectory.createSync(recursive: true);
      // Create subdirectory for files and images
      Directory filesDirectory =
          Directory('${maintenanceDirectory.path}/files');

      Directory imagesDirectory =
          Directory('${maintenanceDirectory.path}/images');
      filesDirectory.createSync();
      imagesDirectory.createSync();
    }
  }
}
*/


/*
  Future<void> _createMaintenanceFolder(String subprocess) async {
    final directory = await getApplicationDocumentsDirectory();
    final maintenanceFolder = Directory('${directory.path}/$subprocess');
    if (!(await maintenanceFolder.exists())) {
      await maintenanceFolder.create(recursive: true);
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
        maintenanceEntries =
            jsonData.map((item) => MaintenanceEntry.fromJson(item)).toList();
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
      String jsonString = json
          .encode(maintenanceEntries.map((entry) => entry.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving maintenance entries: $e');
    }
  }
*/

/*

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class MaintenanceEntry {
  String equipment;
  String task;
  DateTime lastUpdate;
  int updateCount;
  String duration;
  String responsiblePerson;
  TaskState taskState;

  MaintenanceEntry(
      {required this.equipment,
      required this.task,
      required this.lastUpdate,
      required this.updateCount,
      required this.duration,
      required this.responsiblePerson,
      this.taskState = TaskState.unactioned});

  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    return MaintenanceEntry(
        equipment: json['equipment'],
        task: json['task'],
        lastUpdate: DateTime.parse(json['lastUpdate']),
        updateCount: json['updateCount'],
        duration: json['duration'],
        responsiblePerson: json['responsiblePerson'],
        taskState: TaskState.values[json['taskState']]);
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'task': task,
      'lastUpdate': lastUpdate.toIso8601String(),
      'updateCount': updateCount,
      'duration': duration,
      'responsiblePerson': responsiblePerson,
      'taskState': taskState.index
    };
  }
}

enum TaskState {
  unactioned,
  inProgress,
  completed,
}

class MyMaintenanceHistory extends StatefulWidget {
  String subprocess;

  MyMaintenanceHistory({required this.subprocess});
  @override
  _MyMaintenanceHistoryState createState() => _MyMaintenanceHistoryState();
}

class _MyMaintenanceHistoryState extends State<MyMaintenanceHistory> {
  List<MaintenanceEntry> maintenanceEntries = [];
  Map<String, List<MaintenanceEntry>> maintenanceEntriesByEquipment = {};
  Map<String, List<MaintenanceEntry>> maintenanceEntriesByTask = {};
  DateTime lastUpdate = DateTime.now();

  //late final String _subprocess;

  bool _updateExisting = false;
  @override
  void initState() {
    super.initState();
    _loadMaintenanceEntries(); //Load Saved entries when the widget initialized
  }

  @override
  Widget build(BuildContext context) {
    //_subprocess = ModalRoute.of(context)?.settings.arguments as String;

    //final String subprocess = _subprocess;
    //_createMaintenanceFolder(subprocess);

    _loadMaintenanceEntries();
    return Scaffold(
      appBar: AppBar(
        title: Text('Preventive Maintenance Checklist '),
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
                      DataColumn(label: Text('Responsible Person'))
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
          )),
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
            child: Text(equipment),
          )),
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
                ))), // Display task
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
    //Funtion to get the task details for prefilling the form
    MaintenanceEntry? getTaskDetails(String equipment, String task) {
      return maintenanceEntries.firstWhere(
          (entry) => entry.equipment == equipment && entry.task == task);
    }

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
                      }),
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
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_updateExisting) {
                      _showTaskSelectionDoalog(equipment);
                    } else {
                      _showEntryForm(equipment);
                    }
                  },
                  child: Text('Next'))
            ],
          );
        });
  }

  void _showTaskSelectionDoalog(String equipment) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Task to Update'),
            content: SingleChildScrollView(
              child: Column(
                  children:
                      maintenanceEntriesByEquipment[equipment]!.map((entry) {
                return ListTile(
                  title: Text(entry.task),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEntryForm(equipment, existingTask: entry.task);
                  },
                );
              }).toList()),
            ),
          );
        });
  }

  void _showEntryForm(String equipment, {String? existingTask}) {
    // Initialize form field values with empty strings
    String task = existingTask ?? '';
    DateTime lastUpdate = DateTime.now(); // Initialize with current date time
    String duration = '';
    String responsiblePerson = '';
    // Get the current update count for the task
    int updateCount = 0;
    if (existingTask != null) {
      var existingEntry = maintenanceEntries.firstWhere(
          (entry) => entry.equipment == equipment && entry.task == existingTask,
          orElse: () => MaintenanceEntry(
                equipment: equipment,
                task: existingTask,
                lastUpdate: DateTime.now(),
                updateCount: 0, // If entry doesn't exist, set updateCount to 0
                duration: '',
                responsiblePerson: '',
              ));
      updateCount = existingEntry.updateCount + 1; // Increment the updateCount
    }

    //String situationBefore = '';
    //String stepsTaken = '';
    //bool resolutionStatus = false;
    //String taskState = 'Not Actioned';

    // if updating an existing task , prefill the fields

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(existingTask == null ? 'Add New Entry' : 'Update Task'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: equipment,
                  decoration: InputDecoration(labelText: 'Equipment'),
                  onChanged: (value) {
                    setState(() {
                      equipment = value;
                    });
                  },
                  enabled: equipment
                      .isEmpty, // Make equipment editable if it's empty
                ),
                TextFormField(
                  initialValue: task,
                  decoration: InputDecoration(labelText: 'Task'),
                  onChanged: (value) {
                    setState(() {
                      task = value;
                    });
                  },
                  enabled: task.isEmpty,
                ),
                TextButton(
                  onPressed: () {
                    _selectDate(context); //Open the calender widget
                  },
                  child: Text('Last Update/Frequency'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Duration of Update'),
                  onChanged: (value) {
                    setState(() {
                      duration = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Responsible Person'),
                  onChanged: (value) {
                    setState(() {
                      responsiblePerson = value;
                    });
                  },
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
                  // Create a new entry with the provided form field values
                  maintenanceEntries.add(MaintenanceEntry(
                    equipment: equipment,
                    task: task,
                    lastUpdate: lastUpdate,
                    updateCount: updateCount,
                    duration: duration,
                    responsiblePerson: responsiblePerson,
                  ));
                });
                _saveMaintenanceEntries();

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Calender Widget
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        //Update the last update when the selected dat
        lastUpdate = pickedDate;
      });
    }
  }

  Future<void> _addProcedure(
      BuildContext context, MaintenanceEntry entry) async {
    List<TextEditingController> proceduresController = [
      TextEditingController()
    ];

    TextEditingController situationBefore = TextEditingController();
    bool situationResolved = entry.taskState == TaskState.completed;

    TextEditingController yesSituationResolved = TextEditingController();
    TextEditingController noSituationNotResolved = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            void updateTaskState() {
              setState(() {
                if (situationResolved) {
                  entry.taskState = TaskState.completed;
                } else if (situationBefore.text.isNotEmpty ||
                    proceduresController
                        .any((controller) => controller.text.isNotEmpty)) {
                  entry.taskState = TaskState.inProgress;
                } else {
                  entry.taskState = TaskState.unactioned;
                }
              });
            }

            return AlertDialog(
              title: Text('List of Procedures'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /*Expanded(
                      
                      child: TextField(
                        controller: situationBefore,
                        decoration: InputDecoration(labelText: 'Current Situation',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: (){

                            }, icon: Icon(Icons.attach_file)),
                            IconButton(onPressed: (){}, icon: Icon(Icons.image))

                          ],
                        )
                        ),

                    ))*/
                    TextField(
                      controller: situationBefore,
                      decoration: InputDecoration(
                          labelText:
                              'Situation Before', // Try to find a word that fits here
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.attach_file)),
                              IconButton(
                                  onPressed: () {}, icon: Icon(Icons.image))
                            ],
                          )),
                      onChanged: (value) => updateTaskState(),
                    ),
                    for (int i = 1; i < proceduresController.length; i++)
                      TextField(
                        controller: proceduresController[i],
                        decoration: InputDecoration(
                            labelText: 'Step: $i',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {}, icon: Icon(Icons.image))
                              ],
                            )),
                        onChanged: (value) => updateTaskState(),
                      ),
                    SizedBox(
                      height: 5,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          proceduresController.add(TextEditingController());
                        });
                      },
                      child: Text('Add Steps Taken'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () {
                              _addEquipmentUsed(context);
                            },
                            icon: Icon(Icons.build_circle)),
                        Text('List of Equipment used')
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Was Situation Resolved ?'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          semanticLabel: 'Yes',
                          value: situationResolved,
                          onChanged: (value) {
                            setState(() {
                              situationResolved = value ?? false;
                              updateTaskState();
                            });
                          },
                        ),
                        Text('Yes'),
                        Checkbox(
                          semanticLabel: 'No',
                          value:
                              !situationResolved, // Inverse value for the "No" checkbox
                          onChanged: (value) {
                            setState(() {
                              situationResolved =
                                  !(value ?? true); // Invert the value
                              updateTaskState();
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                    SizedBox(height: 3),
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Description of status ',
                          suffixIcon: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.attach_file),
                              ),
                              IconButton(
                                  onPressed: () {}, icon: Icon(Icons.image))
                            ],
                          )),
                      onChanged: (value) {},
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(onPressed: () {}, child: Text('Save')),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          });
        });
  }

  Widget _getTaskStateIcon(TaskState state) {
    switch (state) {
      case TaskState.unactioned:
        return Icon(Icons.clear, color: Colors.red);
      case TaskState.inProgress:
        return Icon(Icons.build, color: Colors.amber);
      case TaskState.completed:
        return Icon(Icons.check, color: Colors.green);
      default:
        return Icon(Icons.help);
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
                  for (int i = 1; i < apparatusController.length; i++)
                    TextField(
                      controller: apparatusController[i],
                      decoration: InputDecoration(
                          labelText: 'Tool $i',
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

  Future<void> _addApprover(BuildContext context) async {
    List<TextEditingController> designatedByControllers = [
      TextEditingController()
    ];

    List<TextEditingController> actionedByController = [
      TextEditingController()
    ];

    List<TextEditingController> approvedByController = [
      TextEditingController()
    ];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(' Add Approvals'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Designated by:'),
                  onChanged: (value) {},
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Actioned by'),
                  onChanged: (value) {},
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Approved by'),
                  onChanged: (value) {},
                )
              ],
            ),
          );
        });
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

  Future<void> _loadMaintenanceEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file =
          File('${directory.path}/${widget.subprocess}/maintenance.json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        maintenanceEntries =
            jsonData.map((item) => MaintenanceEntry.fromJson(item)).toList();

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

  void _createMaintenanceFolder(String subprocess) async {
    String folderPath = 'services/maintenance/files_and_folders/$subprocess';
    Directory maintenanceDirectory = Directory(folderPath);
    bool exists = maintenanceDirectory.existsSync();
    if (!exists) {
      maintenanceDirectory.createSync(recursive: true);
      // Create subdirectory for files and images
      Directory filesDirectory =
          Directory('${maintenanceDirectory.path}/files');

      Directory imagesDirectory =
          Directory('${maintenanceDirectory.path}/images');
      filesDirectory.createSync();
      imagesDirectory.createSync();
    }
  }
}
*/