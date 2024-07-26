import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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

  MyMaintenanceHistory({super.key, required this.subprocess});
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
        title: const Text('Preventive Maintenance Checklist '),
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
                      DataColumn(label: Text('Responsible Person'))
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
          )),
    );
  }

  List<DataRow> _buildMaintenanceRows() {
    List<DataRow> rows = [];

    // Use a Set to store unique entries and avoid duplication
    Set<String> uniqueEntries = <String>{};

    // Iterate over each equipment entry in maintenanceEntriesByEquipment
    maintenanceEntriesByEquipment.forEach((equipment, entries) {
      // Add a DataRow for each equipment with its grouped maintenance entries
      rows.add(
        DataRow(cells: [
          DataCell(SizedBox.expand(
            child: Text(equipment),
          )), // Display equipment name
          const DataCell(SizedBox()), // Empty cell for task
          const DataCell(SizedBox()), // Empty cell for last update
          const DataCell(SizedBox()), // Empty cell for duration
          const DataCell(SizedBox()), // Empty cell for responsible person
        ]),
      );

      // Add a DataRow for each maintenance entry of this equipment
      for (var entry in entries) {
        // Generate a unique key for each entry based on equipment and task
        String entryKey = '$equipment-${entry.task}';
        // Check if the entry is unique, avoiding duplicates
        if (!uniqueEntries.contains(entryKey)) {
          rows.add(
            DataRow(cells: [
              const DataCell(SizedBox()), // Empty cell for equipment
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
      }

      // Add an empty row as separator
      rows.add(DataRow(cells: List.generate(5, (_) => const DataCell(SizedBox()))));
    });

    return rows;
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
    //Funtion to get the task details for prefilling the form
    MaintenanceEntry? getTaskDetails(String equipment, String task) {
      return maintenanceEntries.firstWhere(
          (entry) => entry.equipment == equipment && entry.task == task);
    }

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
                      }),
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
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_updateExisting) {
                      _showTaskSelectionDoalog(equipment);
                    } else {
                      _showEntryForm(equipment);
                    }
                  },
                  child: const Text('Next'))
            ],
          );
        });
  }

  void _showTaskSelectionDoalog(String equipment) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Task to Update'),
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
                  decoration: const InputDecoration(labelText: 'Equipment'),
                  onChanged: (value) {
                    equipment = value;
                  },
                  enabled: equipment
                      .isEmpty, // Make equipment editable if it's empty
                ),
                TextFormField(
                  initialValue: task,
                  decoration: const InputDecoration(labelText: 'Task'),
                  onChanged: (value) {
                    task = value;
                  },
                  enabled: task.isEmpty,
                ),
                TextButton(
                  onPressed: () {
                    _selectDate(context); //Open the calender widget
                  },
                  child: const Text('Last Update/Frequency'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Duration of Update'),
                  onChanged: (value) {
                    duration = value;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Responsible Person'),
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
              child: const Text('Cancel'),
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
              child: const Text('Save'),
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
              title: const Text('List of Procedures'),
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
                                  icon: const Icon(Icons.attach_file)),
                              IconButton(
                                  onPressed: () {}, icon: const Icon(Icons.image))
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
                                    onPressed: () {}, icon: const Icon(Icons.image))
                              ],
                            )),
                        onChanged: (value) {},
                      ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          proceduresController.add(TextEditingController());
                        });
                      },
                      child: const Text('Add Steps Taken'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () {
                              _addEquipmentUsed(context);
                            },
                            icon: const Icon(Icons.build_circle)),
                        const Text('List of Equipment used')
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
                      const Text('Was Situation Resolved ?'),
                      Checkbox(
                          value: false,
                          onChanged: (value) {
                            setState(() {
                              situationResolved = value as bool;
                            });
                          }),
                    ]),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(onPressed: () {}, child: const Text('Save')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'))
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
              title: const Text('List of Tools and Equipment Used'),
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
                                  onPressed: () {}, icon: const Icon(Icons.image))
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
            title: const Text(' Add Approvals'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Designated by:'),
                  onChanged: (value) {},
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Actioned by'),
                  onChanged: (value) {},
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Approved by'),
                  onChanged: (value) {},
                )
              ],
            ),
          );
        });
  }

  void _saveMaintenanceEntries() async {
    const String folderPath = 'services/maintenance/files_and_folders/';
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
      for (var entry in maintenanceEntries) {
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
      }

      // Write updated data back to file
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      print('Error saving maintenance entries: $e');
    }
  }

  void _loadMaintenanceEntries() async {
    try {
      const String folderPath = 'services/preventive_maintenance/';
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
            for (var entryData in entriesData) {
              MaintenanceEntry entry = MaintenanceEntry.fromJson(entryData);
              entries.add(entry);

              // Populate maintenanceEntriesByEquipment
              if (!maintenanceEntriesByEquipment.containsKey(equipment)) {
                maintenanceEntriesByEquipment[equipment] = [];
              }
              maintenanceEntriesByEquipment[equipment]!.add(entry);
            }
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
  List<DateTime> updateTimes;

  MaintenanceEntry({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
    required this.updateCount,
    required this.duration,
    required this.responsiblePerson,
    required this.updateTimes,
  });

  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    return MaintenanceEntry(
      equipment: json['equipment'],
      task: json['task'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      updateCount: json['updateCount'],
      duration: json['duration'],
      responsiblePerson: json['responsiblePerson'],
      updateTimes: (json['updateTimes'] as List<dynamic>)
          .map((time) => DateTime.parse(time as String))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'task': task,
      'lastUpdate': lastUpdate.toIso8601String(),
      'updateCount': updateCount,
      'duration': duration,
      'responsiblePerson': responsiblePerson,
      'updateTimes': updateTimes.map((time) => time.toIso8601String()).toList(),
    };
  }
}

class TaskEntry {
  String task;
  DateTime lastUpdate;
  String duration;
  String responsiblePerson;
  int updateCount;
  List<DateTime> updateTimes;

  TaskEntry({
    required this.task,
    required this.lastUpdate,
    required this.duration,
    required this.responsiblePerson,
    this.updateCount = 0,
    List<DateTime>? updateTimes,
  }) : this.updateTimes = updateTimes ?? [];
}

class MyMaintenanceHistory extends StatefulWidget {
  final String subprocess;

  MyMaintenanceHistory({required this.subprocess});

  @override
  _MyMaintenanceHistoryState createState() => _MyMaintenanceHistoryState();
}

class _MyMaintenanceHistoryState extends State<MyMaintenanceHistory> {
  List<MaintenanceEntry> maintenanceEntries = [];
  Map<String, List<MaintenanceEntry>> maintenanceEntriesByEquipment = {};
  DateTime lastUpdate = DateTime.now();
  bool _updateExisting = false;

  @override
  void initState() {
    super.initState();
    _createMaintenanceFolder(widget.subprocess);
    _loadMaintenanceEntries();
  }

  @override
  Widget build(BuildContext context) {
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
                    DataColumn(label: Text('Responsible Person'))
                  ],
                  rows: _buildMaintenanceRows(),
                  border: TableBorder.all(),
                ),
              ),
              SizedBox(height: 20),
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

    Set<String> uniqueEntries = Set<String>();

    maintenanceEntriesByEquipment.forEach((equipment, entries) {
      rows.add(
        DataRow(cells: [
          DataCell(SizedBox.expand(child: Text(equipment))),
          DataCell(SizedBox()),
          DataCell(SizedBox()),
          DataCell(SizedBox()),
          DataCell(SizedBox()),
        ]),
      );

      entries.forEach((entry) {
        String entryKey = '$equipment-${entry.task}';
        if (!uniqueEntries.contains(entryKey)) {
          rows.add(
            DataRow(cells: [
              DataCell(SizedBox()),
              DataCell(TextButton(
                onPressed: () {
                  _addProcedure(context);
                },
                child: Text(entry.task),
              )),
              DataCell(
                Row(
                  children: [
                    Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                        .format(entry.lastUpdate)),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        _showUpdateTimesDialog(entry.updateTimes);
                      },
                      child: Text('(${entry.updateCount})'),
                    ),
                  ],
                ),
              ),
              DataCell(Text(entry.duration)),
              DataCell(TextButton(
                onPressed: () {
                  _addApprover(context);
                },
                child: Text(entry.responsiblePerson),
              )),
            ]),
          );
          uniqueEntries.add(entryKey);
        }
      });

      rows.add(DataRow(cells: List.generate(5, (_) => DataCell(SizedBox()))));
    });

    return rows;
  }

  void _showUpdateTimesDialog(List<DateTime> updateTimes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Times'),
          content: SingleChildScrollView(
            child: Column(
              children: updateTimes.map((time) {
                return ListTile(
                  title: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(time)),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
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
                  title: Text('Update Existing Equipment'),
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
                    _showEntryForm('');
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
    DateTime lastUpdate = DateTime.now();
    String duration = '';
    String responsiblePerson = '';
    int updateCount = 0;
    List<DateTime> updateTimes = [];

    if (existingTask != null) {
      var existingEntry = maintenanceEntries.firstWhere(
        (entry) => entry.equipment == equipment && entry.task == existingTask,
        orElse: () => MaintenanceEntry(
          equipment: equipment,
          task: existingTask,
          lastUpdate: DateTime.now(),
          updateCount: 0,
          duration: '',
          responsiblePerson: '',
          updateTimes: [],
        ),
      );
      lastUpdate = existingEntry.lastUpdate;
      updateCount = existingEntry.updateCount;
      duration = existingEntry.duration;
      responsiblePerson = existingEntry.responsiblePerson;
      updateTimes = existingEntry.updateTimes;
    }

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
                  readOnly: existingTask != null,
                  onChanged: (value) {
                    equipment = value;
                  },
                ),
                TextFormField(
                  initialValue: task,
                  decoration: InputDecoration(labelText: 'Task'),
                  readOnly: existingTask !=
                      null, // Make task field uneditable if updating existing task
                  onChanged: (value) {
                    task = value;
                  },
                ),
                Row(
                  children: [
                    Text('Last Update: ${lastUpdate.toString()} '),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          updateCount++;
                          updateTimes.add(DateTime.now());
                        });
                      },
                      child: Text('(${updateCount})'),
                    ),
                  ],
                ),
                TextFormField(
                  initialValue: duration,
                  decoration: InputDecoration(labelText: 'Duration'),
                  onChanged: (value) {
                    duration = value;
                  },
                ),
                TextFormField(
                  initialValue: responsiblePerson,
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
                DateTime currentTime = DateTime.now();
                MaintenanceEntry newEntry = MaintenanceEntry(
                  equipment: equipment,
                  task: task,
                  lastUpdate: currentTime,
                  updateCount: updateCount,
                  duration: duration,
                  responsiblePerson: responsiblePerson,
                  updateTimes: updateTimes,
                );

                if (existingTask != null) {
                  var existingEntries =
                      maintenanceEntriesByEquipment[equipment]!;
                  var existingIndex = existingEntries
                      .indexWhere((entry) => entry.task == existingTask);
                  existingEntries[existingIndex] = newEntry;
                } else {
                  if (maintenanceEntriesByEquipment.containsKey(equipment)) {
                    maintenanceEntriesByEquipment[equipment]!.add(newEntry);
                  } else {
                    maintenanceEntriesByEquipment[equipment] = [newEntry];
                  }
                  maintenanceEntries.add(newEntry);
                }
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

  void _addProcedure(BuildContext context) {
// Implementation for adding a procedure
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Procedure'), // Adjust title as needed
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Add your form fields here for adding a procedure
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
                // Implement logic for saving procedure
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addApprover(BuildContext context) {
    // Implementation for adding an approver
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Approver'), // Adjust title as needed
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Add your form fields here for adding an approver
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
                // Implement logic for saving approver
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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

  MaintenanceEntry({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
    required this.updateCount,
    required this.duration,
    required this.responsiblePerson,
  });

  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    return MaintenanceEntry(
      equipment: json['equipment'],
      task: json['task'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      updateCount: json['updateCount'],
      duration: json['duration'],
      responsiblePerson: json['responsiblePerson'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'task': task,
      'lastUpdate': lastUpdate.toIso8601String(),
      'updateCount': updateCount,
      'duration': duration,
      'responsiblePerson': responsiblePerson,
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
  TaskState taskState = TaskState.unactioned;

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
                  _addProcedure(context);
                },
                child: Row(
                  children: [
                    Text(entry.task),
                    _getTaskStateIcon(taskState),
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
                  taskState = TaskState.completed;
                } else if (situationBefore.text.isNotEmpty ||
                    proceduresController
                        .any((controller) => controller.text.isNotEmpty)) {
                  taskState = TaskState.inProgress;
                } else {
                  taskState = TaskState.unactioned;
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

  MaintenanceEntry({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
    required this.updateCount,
    required this.duration,
    required this.responsiblePerson,
    required this.taskState,
  });

  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    return MaintenanceEntry(
      equipment: json['equipment'],
      task: json['task'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      updateCount: json['updateCount'],
      duration: json['duration'],
      responsiblePerson: json['responsiblePerson'],
      taskState: TaskState.values[json['taskState']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'task': task,
      'lastUpdate': lastUpdate.toIso8601String(),
      'updateCount': updateCount,
      'duration': duration,
      'responsiblePerson': responsiblePerson,
      'taskState': taskState.index,
    };
  }
}

enum TaskState {
  unactioned,
  inProgress,
  completed,
}

class MyMaintenanceHistory extends StatefulWidget {
  final String subprocess;

  MyMaintenanceHistory({required this.subprocess});

  @override
  _MyMaintenanceHistoryState createState() => _MyMaintenanceHistoryState();
}

class _MyMaintenanceHistoryState extends State<MyMaintenanceHistory> {
  List<MaintenanceEntry> maintenanceEntries = [];
  Map<String, List<MaintenanceEntry>> maintenanceEntriesByEquipment = {};
  Map<String, List<MaintenanceEntry>> maintenanceEntriesByTask = {};
  DateTime lastUpdate = DateTime.now();
  bool _updateExisting = false;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceEntries(); // Load saved entries when the widget initializes
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
          DataCell(SizedBox.expand(child: Text(equipment))),
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
                _addProcedure(context);
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
    TaskState taskState = TaskState.unactioned;

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
                DropdownButtonFormField<TaskState>(
                  value: taskState,
                  decoration: InputDecoration(labelText: 'Task State'),
                  onChanged: (value) {
                    setState(() {
                      taskState = value!;
                    });
                  },
                  items: TaskState.values.map((TaskState state) {
                    return DropdownMenuItem<TaskState>(
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
                  MaintenanceEntry newEntry = MaintenanceEntry(
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

  Future<void> _addProcedure(BuildContext context) async {
    List<TextEditingController> proceduresController = [
      TextEditingController()
    ];

    TextEditingController situationBefore = TextEditingController();
    bool situationResolved = false;

    TextEditingController yesSituationResolved = TextEditingController();
    TextEditingController noSituationNotResolved = TextEditingController();

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
                            });
                          },
                        ),
                        Text('No'),
                      ],
                    ),
                    SizedBox(height: 3),
                    TextField(
                      controller: situationBefore,
                      decoration: InputDecoration(
                          labelText:
                              'Status Update', // Try to find a word that fits here
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

  Widget _getTaskStateIcon(TaskState taskState) {
    switch (taskState) {
      case TaskState.unactioned:
        return Icon(Icons.warning, color: Colors.red);
      case TaskState.inProgress:
        return Icon(Icons.work, color: Colors.orange);
      case TaskState.completed:
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

  void _updateMaintenanceDetailsPage() async{

  }
}

*/
/*
import 'dart:convert';
import 'dart:io';
import 'package:collector/pages/history/maintenance/detailsmaintenance.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class MaintenanceEntry {
  String equipment;
  String task;
  DateTime lastUpdate;
  int updateCount;
  String duration;
  String responsiblePerson;
  TaskState taskState;

  MaintenanceEntry({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
    required this.updateCount,
    required this.duration,
    required this.responsiblePerson,
    required this.taskState,
  });

  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    return MaintenanceEntry(
      equipment: json['equipment'],
      task: json['task'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      updateCount: json['updateCount'],
      duration: json['duration'],
      responsiblePerson: json['responsiblePerson'],
      taskState: TaskState.values[json['taskState']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'task': task,
      'lastUpdate': lastUpdate.toIso8601String(),
      'updateCount': updateCount,
      'duration': duration,
      'responsiblePerson': responsiblePerson,
      'taskState': taskState.index,
    };
  }

  MaintenanceDetails toMaintenanceDetails() {
    return MaintenanceDetails(
        equipment: equipment,
        task: task,
        lastUpdate: lastUpdate,
        situationBefore: '',
        stepsTaken: [],
        toolsUsed: [],
        situationResolved: false,
        situationAfter: '',
        personResponsible: responsiblePerson);
  }
}

enum TaskState {
  unactioned,
  inProgress,
  completed,
}

class MaintenanceDetails {
  String equipment;
  String task;
  DateTime lastUpdate;
  String situationBefore;
  List<String> stepsTaken;
  List<String> toolsUsed;
  bool situationResolved;
  String situationAfter;
  String personResponsible;

  MaintenanceDetails({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
    required this.situationBefore,
    required this.stepsTaken,
    required this.toolsUsed,
    required this.situationResolved,
    required this.situationAfter,
    required this.personResponsible,
  });

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'task': task,
      'lastUpdate': lastUpdate.toIso8601String(),
      'situationBefore': situationBefore,
      'stepsTaken': stepsTaken,
      'toolsUsed': toolsUsed,
      'situationResolved': situationResolved,
      'situationAfter': situationAfter,
      'personResponsible': personResponsible,
    };
  }

  factory MaintenanceDetails.fromJson(Map<String, dynamic> json) {
    return MaintenanceDetails(
      equipment: json['equipment'],
      task: json['task'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      situationBefore: json['situationBefore'],
      stepsTaken: List<String>.from(json['stepsTaken']),
      toolsUsed: List<String>.from(json['toolsUsed']),
      situationResolved: json['situationResolved'],
      situationAfter: json['situationAfter'],
      personResponsible: json['personResponsible'],
    );
  }
  MaintenanceDetails toMaintenanceDetails() {
    return MaintenanceDetails(
      equipment: equipment,
      task: task,
      lastUpdate: lastUpdate,
      situationBefore: '',
      stepsTaken: [],
      toolsUsed: [],
      situationResolved: false,
      situationAfter: '',
      personResponsible: personResponsible,
    );
  }
}

class MyMaintenanceHistory extends StatefulWidget {
  final String subprocess;

  MyMaintenanceHistory({required this.subprocess});

  @override
  _MyMaintenanceHistoryState createState() => _MyMaintenanceHistoryState();
}

class _MyMaintenanceHistoryState extends State<MyMaintenanceHistory> {
  List<MaintenanceEntry> maintenanceEntries = [];
  Map<String, List<MaintenanceEntry>> maintenanceEntriesByEquipment = {};
  Map<String, List<MaintenanceEntry>> maintenanceEntriesByTask = {};
  DateTime lastUpdate = DateTime.now();
  bool _updateExisting = false;
  List<MaintenanceDetails> maintenanceDetailsList = [];

  @override
  void initState() {
    super.initState();
    _loadMaintenanceEntries(); // Load saved entries when the widget initializes
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
                      builder: (context) => MaintenanceDetailsPage(
                            details: entries.first.toMaintenanceDetails(),
                          )));
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

  void _viewMaintenanceDetails(String equipment) {
    // Find the corresponding MaintenanceDetails
    MaintenanceDetails? details = maintenanceDetailsList
        .firstWhereOrNull((details) => details.equipment == equipment);
    if (details != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MaintenanceDetailsPage(
          details: details,
        ),
      ));
    } else {
      // Handle case where no details are found
    }
  }

  void _showEntryForm(String equipment, {String? existingTask}) {
    String task = existingTask ?? '';
    DateTime lastUpdate = DateTime.now(); // Initialize with current date time
    String duration = '';
    String responsiblePerson = '';
    int updateCount = 1;
    TaskState taskState = TaskState.unactioned;

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
                DropdownButtonFormField<TaskState>(
                  value: taskState,
                  decoration: InputDecoration(labelText: 'Task State'),
                  onChanged: (value) {
                    setState(() {
                      taskState = value!;
                    });
                  },
                  items: TaskState.values.map((TaskState state) {
                    return DropdownMenuItem<TaskState>(
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
                  MaintenanceEntry newEntry = MaintenanceEntry(
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

  Future<void> _addProcedure(
      BuildContext context, MaintenanceEntry entry) async {
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
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {}, icon: Icon(Icons.attach_file)),
                          IconButton(onPressed: () {}, icon: Icon(Icons.image)),
                        ],
                      ),
                    ),
                  ),
                  for (int i = 1; i < stepsController.length; i++)
                    TextField(
                      controller: stepsController[i],
                      decoration: InputDecoration(
                        labelText: 'Step $i',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () {}, icon: Icon(Icons.image)),
                          ],
                        ),
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
                  for (int i = 1; i < toolsController.length; i++)
                    TextField(
                      controller: toolsController[i],
                      decoration: InputDecoration(
                        labelText: 'Tool $i',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () {}, icon: Icon(Icons.image)),
                          ],
                        ),
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
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {}, icon: Icon(Icons.attach_file)),
                          IconButton(onPressed: () {}, icon: Icon(Icons.image)),
                        ],
                      ),
                    ),
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
                  List<String> steps = stepsController
                      .map((controller) => controller.text)
                      .toList();
                  List<String> tools = toolsController
                      .map((controller) => controller.text)
                      .toList();

                  MaintenanceDetails newDetails = MaintenanceDetails(
                    equipment: entry.equipment,
                    task: entry.task,
                    lastUpdate: entry.lastUpdate,
                    situationBefore: situationBeforeController.text,
                    stepsTaken: steps,
                    toolsUsed: tools,
                    situationResolved: situationResolved,
                    situationAfter: situationAfterController.text,
                    personResponsible: entry.responsiblePerson,
                  );

                  _saveMaintenanceDetails(newDetails);
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
            ],
          );
        });
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
    MaintenanceDetails details = MaintenanceDetails(
        equipment: equipment,
        task: task,
        lastUpdate: lastUpdate,
        situationBefore: situationBefore,
        stepsTaken: stepsTaken,
        toolsUsed: toolsUsed,
        situationResolved: situationResolved,
        situationAfter: situationAfter,
        personResponsible: personResponsible);
    _saveMaintenanceDetails(details);
  }

  Future<void> _saveMaintenanceDetails(MaintenanceDetails details) async {
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

      // Add the new details
      detailsList.add(details);

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

  Widget _getTaskStateIcon(TaskState taskState) {
    switch (taskState) {
      case TaskState.unactioned:
        return Icon(Icons.warning, color: Colors.red);
      case TaskState.inProgress:
        return Icon(Icons.work, color: Colors.orange);
      case TaskState.completed:
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
*/
/*
import 'dart:convert';
import 'dart:io';
import 'package:collector/pages/history/maintenance/detailsmaintenance.dart';
import 'package:collector/pages/history/maintenance/maintenance_details.dart';
import 'package:collector/pages/history/maintenance/maintenance_entry.dart' as MaintenanceEntry;
import 'package:collector/pages/history/maintenance/maintenancehistorysparecode.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class MaintenanceDetailsPage extends StatelessWidget {
  final MaintenanceDetails details;

  MaintenanceDetailsPage({required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Maintenance Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Equipment: ${details.equipment}'),
            ...details.tasks.map((task) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Task: ${task.task}'),
                  Text('Last Update: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(task.lastUpdate)}'),
                  Text('Situation Before: ${task.situationBefore}'),
                  Text('Steps Taken: ${task.stepsTaken.join(', ')}'),
                  Text('Tools Used: ${task.toolsUsed.join(', ')}'),
                  Text('Situation Resolved: ${task.situationResolved}'),
                  Text('Situation After: ${task.situationAfter}'),
                  Text('Person Responsible: ${task.personResponsible}'),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class MyMaintenanceHistory extends StatefulWidget {
  final String subprocess;

  MyMaintenanceHistory({required this.subprocess});

  @override
  _MyMaintenanceHistoryState createState() => _MyMaintenanceHistoryState();
}

class _MyMaintenanceHistoryState extends State<MyMaintenanceHistory> {
  List<MaintenanceEntry.MaintenanceEntry> maintenanceEntries = [];
  Map<String, List<MaintenanceEntry.MaintenanceEntry>> maintenanceEntriesByEquipment = {};
  Map<String, List<MaintenanceEntry.MaintenanceEntry>> maintenanceEntriesByTask = {};
  DateTime lastUpdate = DateTime.now();
  bool _updateExisting = false;
  List<MaintenanceDetails> maintenanceDetailsList = [];

  @override
  void initState() {
    super.initState();
    _loadMaintenanceEntries(); // Load saved entries when the widget initializes
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
                      builder: (context) => MaintenanceDetailsPage(
                            details: maintenanceDetailsList.firstWhere((details) => details.equipment==equipment,orElse: ()=>MaintenanceDetails(equipment: equipment, tasks: [])),
                          )));
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

  void _viewMaintenanceDetails(String equipment) {
    // Find the corresponding MaintenanceDetails
    MaintenanceDetails? details = maintenanceDetailsList
        .firstWhereOrNull((details) => details.equipment == equipment);
    if (details != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MaintenanceDetailsPage(
          details: details,
        ),
      ));
    } else {
      // Handle case where no details are found
    }
  }

  void _showEntryForm(String equipment, {String? existingTask}) {
    String task = existingTask ?? '';
    DateTime lastUpdate = DateTime.now(); // Initialize with current date time
    String duration = '';
    String responsiblePerson = '';
    int updateCount = 1;
    MaintenanceEntry.TaskState taskState = MaintenanceEntry.TaskState.unactioned;

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
                  items:MaintenanceEntry.TaskState.values.map((MaintenanceEntry.TaskState state) {
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
                  MaintenanceEntry .MaintenanceEntry newEntry = MaintenanceEntry. MaintenanceEntry(
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
void _addProcedure(BuildContext context, MaintenanceEntry. MaintenanceEntry entry) async {
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
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: () {}, icon: Icon(Icons.attach_file)),
                          IconButton(onPressed: () {}, icon: Icon(Icons.image)),
                        ],
                      ),
                    ),
                  ),
                  for (int i = 0; i < stepsController.length; i++)
                    TextField(
                      controller: stepsController[i],
                      decoration: InputDecoration(
                        labelText: 'Step ${i + 1}',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: () {}, icon: Icon(Icons.image)),
                          ],
                        ),
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
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(onPressed: () {}, icon: Icon(Icons.image)),
                          ],
                        ),
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
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: () {}, icon: Icon(Icons.attach_file)),
                          IconButton(onPressed: () {}, icon: Icon(Icons.image)),
                        ],
                      ),
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
                  setState(() {
                    final details = maintenanceDetailsList.firstWhere(
                      (details) => details.equipment == entry.equipment,
                      orElse: () => MaintenanceDetails(
                        equipment: entry.equipment,
                        tasks: [],
                      ),
                    );

                    final taskDetails = details.tasks.firstWhere(
                      (task) => task.task == entry.task,
                      orElse: () {
                        final newTask = MaintenanceTaskDetails(
                          task: entry.task,
                          lastUpdate: entry.lastUpdate,
                          situationBefore: situationBeforeController.text,
                          stepsTaken: stepsController.map((controller) => controller.text).toList(),
                          toolsUsed: toolsController.map((controller) => controller.text).toList(),
                          situationResolved: situationResolved,
                          situationAfter: situationAfterController.text,
                          personResponsible: entry.responsiblePerson,
                        );
                        details.tasks.add(newTask);
                        return newTask;
                      },
                    );

                    taskDetails.situationBefore = situationBeforeController.text;
                    taskDetails.stepsTaken = stepsController.map((controller) => controller.text).toList();
                    taskDetails.toolsUsed = toolsController.map((controller) => controller.text).toList();
                    taskDetails.situationAfter = situationAfterController.text;
                    taskDetails.situationResolved = situationResolved;

                    if (!maintenanceDetailsList.contains(details)) {
                      maintenanceDetailsList.add(details);
                    }
                  });

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
    MaintenanceTaskDetails taskDetails = MaintenanceTaskDetails(
        
        task: task,
        lastUpdate: lastUpdate,
        situationBefore: situationBefore,
        stepsTaken: stepsTaken,
        toolsUsed: toolsUsed,
        situationResolved: situationResolved,
        situationAfter: situationAfter,
        personResponsible: personResponsible); // Find the existing maintenance details for the equipment
  MaintenanceDetails? existingDetails = maintenanceDetailsList.firstWhereOrNull(
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
  _saveMaintenanceDetails(equipment,taskDetails);
  }
Future<void> _saveMaintenanceDetails(String equipment, MaintenanceTaskDetails taskDetails) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${widget.subprocess}/maintenance_details.json');
    List<MaintenanceDetails> detailsList = [];

    // Load existing data if the file exists
    if (await file.exists()) {
      String jsonString = await file.readAsString();
      List<dynamic> jsonData = json.decode(jsonString);
      detailsList = jsonData.map((item) => MaintenanceDetails.fromJson(item)).toList();
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
    String jsonString = json.encode(detailsList.map((detail) => detail.toJson()).toList());
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

  Widget _getTaskStateIcon( MaintenanceEntry.TaskState taskState) {
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
        maintenanceEntries =
            jsonData.map((item) => MaintenanceEntry.MaintenanceEntry.fromJson(item)).toList();

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
*/


/*
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
    await maintenanceData.loadMaintenanceDetails(
        widget.subprocess); // Load maintenance details from file
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
        title:
            Text('Preventive Maintenance Checklist for ${widget.subprocess} '),
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
                      builder: (context) => MaintenanceDetailsPage(
                            subprocess: widget.subprocess,
                          )));
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
        bool checklistPresent = entry.checklistItems.isNotEmpty;
        rows.add(
          DataRow(cells: [
            DataCell(SizedBox()), // Empty cell for equipment
            DataCell(TextButton(
              onPressed: () {
                _addProcedure(
                    context, entry, entry.checklistItems, widget.subprocess);
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
                      icon: Icon(Icons.list))
              ],
            )), // Display responsible person
          ]),
        );
      });

      // Add an empty row as separator
      rows.add(DataRow(cells: List.generate(5, (_) => DataCell(SizedBox()))));
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
        'additionalNote': '', // initialize empty additional note
      });
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checklist Details'),
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
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(child: Text(item['item'] ?? '')),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration:
                              InputDecoration(hintText: 'Additional note'),
                          onChanged: (value) {
                            setState(() {
                              item['additionalNote'] = value;
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
              child: Text('Close'),
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
    DateTime lastUpdate = DateTime.now();
    String duration = '';
    String responsiblePerson = '';
    int updateCount = 1;
    MaintenanceEntry.TaskState taskState =
        MaintenanceEntry.TaskState.unactioned;
    bool addChecklist = false;
    List<ChecklistItem> checklistItems = [];

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
                      decoration:
                          InputDecoration(labelText: 'Responsible Person'),
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
                    SizedBox(height: 10),
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
                        Text('Do you wish to add a checklist?'),
                      ],
                    ),
                    if (checklistItems.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Checklist Items:'),
                          SizedBox(height: 8),
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
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Create a new MaintenanceEntry
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

                    setState(() {
                      // Find or create the MaintenanceDetails for the given equipment
                      final details =
                          maintenanceData.maintenanceDetailsList.firstWhere(
                        (details) => details.equipment == equipment,
                        orElse: () {
                          final newDetails = MaintenanceDetails(
                            equipment: equipment,
                            tasks: [],
                          );
                          maintenanceData.maintenanceDetailsList
                              .add(newDetails);
                          return newDetails;
                        },
                      );

                      // Create a new MaintenanceTaskDetails
                      MaintenanceTaskDetails taskDetails =
                          MaintenanceTaskDetails(
                        task: task,
                        lastUpdate: lastUpdate,
                        situationBefore: '', // Initialize with empty string
                        stepsTaken: [], // Initialize with empty list
                        toolsUsed: [], // Initialize with empty list
                        situationResolved: false, // Initialize with false
                        situationAfter: '', // Initialize with empty string
                        personResponsible: responsiblePerson,
                        checklist: checklistItems,
                      );

                      // Add or update the task in the MaintenanceDetails object
                      final existingTaskIndex = details.tasks
                          .indexWhere((task) => task.task == existingTask);

                      if (existingTaskIndex != -1) {
                        details.tasks[existingTaskIndex] = taskDetails;
                      } else {
                        details.tasks.add(taskDetails);
                      }

                      // Save the updated MaintenanceDetails list
                      maintenanceData.saveMaintenanceDetails(widget.subprocess);

                      // Update entries by equipment (assuming this updates UI or state)
                      _updateMaintenanceEntriesByEquipment();

                      // Add notification
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
                  child: Text('Save'),
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
          title: Text('Edit Checklist'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
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
                                    icon: Icon(Icons.delete),
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
                                    icon: Icon(Icons.delete),
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
                      decoration: InputDecoration(labelText: 'Checklist Item'),
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
                      child: Text('Add Item'),
                    ),
                    SizedBox(height: 16),
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
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addProcedure(
      BuildContext context,
      MaintenanceEntry.MaintenanceEntry entry,
      List<ChecklistItem> currentItems,
      String subprocess) async {
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
                    final maintenanceData = MaintenanceData();

                    // Load existing maintenance details
                    await maintenanceData.loadMaintenanceDetails(subprocess);

                    // Find or create the MaintenanceDetails for the given equipment
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

                    // Create a new MaintenanceTaskDetails object
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
                      checklist: currentItems,
                    );

                    // Add or update the task in the MaintenanceDetails object
                    final existingTaskIndex = details.tasks
                        .indexWhere((task) => task.task == entry.task);

                    if (existingTaskIndex != -1) {
                      details.tasks[existingTaskIndex] = taskDetails;
                    } else {
                      details.tasks.add(taskDetails);
                    }

                    // Save the updated MaintenanceDetails list
                    await maintenanceData.saveMaintenanceDetails(subprocess);

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
      final directory =
          'pages/history/preventive_maintenance'; // Update directory path
      final file =
          File('$directory/maintenance_details_${widget.subprocess}.json');

      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);

        List<MaintenanceEntry.MaintenanceEntry> loadedEntries =
            jsonData.map((item) {
          return MaintenanceEntry.MaintenanceEntry.fromJson(
              item); // Assuming MaintenanceEntry.fromJson method handles conversion
        }).toList();

        // Clear current maintenanceEntries and add loaded entries
        maintenanceEntries.clear();
        maintenanceEntries.addAll(loadedEntries);

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

  void _updateMaintenanceEntriesByEquipment() {
    maintenanceEntriesByEquipment.clear();
    maintenanceEntries.forEach((entry) {
      if (!maintenanceEntriesByEquipment.containsKey(entry.equipment)) {
        maintenanceEntriesByEquipment[entry.equipment] = [];
      }
      maintenanceEntriesByEquipment[entry.equipment]!.add(entry);
    });
  }
}
*/




/*import 'dart:convert';
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
    _loadMaintenanceEntries();
    _loadMaintenanceDetails();
  }

  void _loadMaintenanceDetails() {
    maintenanceData.loadMaintenanceDetails(widget.subprocess).then((_) {
      setState(() {
        // Ensure UI is updated after loading data
        print('Maintenance details loaded and state updated');
      });
    });
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
        print('Maintenance entries loaded: $maintenanceEntries');
      }
    } catch (e) {
      print('Error loading maintenance entries: $e');
    }
    setState(() {
      // Ensure UI is updated after loading data
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadMaintenanceEntries();
    // loadMaintenanceDetails();

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Preventive Maintenance Checklist for ${widget.subprocess} '),
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
                      builder: (context) => MaintenanceDetailsPage(
                            subprocess: widget.subprocess,
                          )));
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
        bool checklistPresent = entry.checklistItems.isNotEmpty;
        rows.add(
          DataRow(cells: [
            DataCell(SizedBox()), // Empty cell for equipment
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
                      icon: Icon(Icons.list))
              ],
            )), // Display responsible person
          ]),
        );
      });

      // Add an empty row as separator
      rows.add(DataRow(cells: List.generate(5, (_) => DataCell(SizedBox()))));
    });

    return rows;
  }

  void _showCheckListDetailsDialog(
      BuildContext context, List<ChecklistItem> checklistItems) {
    List<Map<String, dynamic>> items =
        []; // List to hold checklist items and their status
    for (var item in checklistItems) {
      items.add({
        'name': item,
        'checked': false, // initialize with unchecked status
        'additionalNote': '', // initialize empty additional note
      });
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Checklist Details'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display checklist items with checkbox and optiona note field

                  for (var item in items)
                    Row(
                      children: [
                        Checkbox(
                            value: item['checked'],
                            onChanged: (bool? value) {
                              setState(() {
                                item['checked'] = value ?? false;
                              });
                            }),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(child: Text(item['name'])),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            flex: 2,
                            child: TextField(
                              decoration:
                                  InputDecoration(hintText: 'Additional note'),
                              onChanged: (value) {
                                setState(() {
                                  item['additionalNote'] = value;
                                });
                              },
                            ))
                      ],
                    )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'))
            ],
          );
        });
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
    DateTime lastUpdate = DateTime.now();
    String duration = '';
    String responsiblePerson = '';
    int updateCount = 1;
    MaintenanceEntry.TaskState taskState =
        MaintenanceEntry.TaskState.unactioned;
    bool addChecklist = false;
    List<ChecklistItem> checklistItems = [];

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
                      decoration:
                          InputDecoration(labelText: 'Responsible Person'),
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
                    SizedBox(height: 10),
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
                        Text('Do you wish to add a checklist?'),
                      ],
                    ),
                    if (checklistItems.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Checklist Items:'),
                          SizedBox(height: 8),
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
                        checklistItems: checklistItems,
                      );

                      if (existingTask == null) {
                        maintenanceEntries.add(newEntry);
                      } else {
                        maintenanceEntries.removeWhere((entry) =>
                            entry.equipment == equipment &&
                            entry.task == existingTask);
                        maintenanceEntries.add(newEntry);
                      }
                      maintenanceData.maintenanceDetailsList.add(
                        MaintenanceDetails(
                          equipment: equipment,
                          tasks: [
                            MaintenanceTaskDetails(
                              task: task,
                              lastUpdate: lastUpdate,
                              situationBefore: '',
                              stepsTaken: [],
                              toolsUsed: [],
                              situationResolved: false,
                              situationAfter: '',
                              personResponsible: responsiblePerson,
                              checklist: checklistItems,
                            ),
                          ],
                        ),
                      );
                      maintenanceData.saveMaintenanceDetails(widget.subprocess);
                      _updateMaintenanceEntriesByEquipment();

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
                  child: Text('Save'),
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
    List<String> newItems = []; // Track new items added

    return await showDialog<List<String>?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Checklist'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
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
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        checklistItems.remove(item);
                                      });
                                    },
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Checklist Item'),
                      onFieldSubmitted: (value) {
                        setState(() {
                          if (value.isNotEmpty) {
                            newItems.add(value);
                          }
                        });
                      },
                    ),
                    SizedBox(height: 16),
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
              child: Text('Save'),
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
                        checklist: currentItems);

                    details.tasks.add(taskDetails);
                    maintenanceData.saveMaintenanceDetails(widget.subprocess);

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
}
*/