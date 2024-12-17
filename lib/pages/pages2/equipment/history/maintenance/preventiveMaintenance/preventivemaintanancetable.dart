import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class MaintenanceTask {
  String task;
  String status;
  DateTime lastUpdate;
  Duration elapsedTime;
  String responsible;
  List<ChecklistItem> checklist;
  String checklistStatus;
  String situationBefore;
  List<String> stepsTaken;
  List<String> toolsUsed;
  String situationAfter;

  MaintenanceTask({
    required this.task,
    this.status = 'incomplete',
    DateTime? lastUpdate,
    Duration? elapsedTime,
    this.responsible = '',
    List<ChecklistItem>? checklist,
    this.checklistStatus = 'not uploaded',
    this.situationBefore = '',
    List<String>? stepsTaken,
    List<String>? toolsUsed,
    this.situationAfter = '',
  })  : lastUpdate = lastUpdate ?? DateTime.now(),
        elapsedTime = elapsedTime ?? Duration.zero,
        checklist = checklist ?? [],
        stepsTaken = stepsTaken ?? [],
        toolsUsed = toolsUsed ?? [];

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'status': status,
      'lastUpdate': lastUpdate.toIso8601String(),
      'elapsedTime': elapsedTime.inSeconds.toString(),
      'responsible': responsible,
      'checklist': checklist.map((e) => e.toJson()).toList(),
      'checklistStatus': checklistStatus,
      'situationBefore': situationBefore,
      'stepsTaken': stepsTaken,
      'toolsUsed': toolsUsed,
      'situationAfter': situationAfter,
    };
  }

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      task: json['task'],
      status: json['status'] ?? 'incomplete',
      lastUpdate: DateTime.parse(json['lastUpdate']),
      elapsedTime: Duration(seconds: int.parse(json['elapsedTime'] ?? 0)),
      responsible: json['responsible'] ?? '',
      checklist: (json['checklist'] as List?)
              ?.map((e) => ChecklistItem.fromJson(e))
              .toList() ??
          [],
      checklistStatus: json['checklistStatus'] ?? 'not uploaded',
      situationBefore: json['situationBefore'] ?? '',
      stepsTaken: List<String>.from(json['stepsTaken'] ?? []),
      toolsUsed: List<String>.from(json['toolsUsed'] ?? []),
      situationAfter: json['situationAfter'] ?? '',
    );
  }

  void updateStatus(String newStatus) {
    status = newStatus;
    lastUpdate = DateTime.now();

    if (newStatus == 'complete') {
      elapsedTime = DateTime.now().difference(lastUpdate);
    }
  }

  void updateChecklistStatus() {
    if (checklist.isEmpty) {
      checklistStatus = 'not uploaded';
    } else if (checklist.every((item) => item.isCompleted)) {
      checklistStatus = 'completed';
    } else if (checklist.any((item) => !item.isCompleted)) {
      checklistStatus = 'incomplete';
    }
  }

  static Future<void> saveMaintenanceList(
      List<MaintenanceTask> maintenanceTasks, String equipmentName) async {
    try {
      const baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/history/maintenance/preventiveMaintenance/preventivemaintenancestorage';
      final santizedEquipmentName = equipmentName.replaceAll('/', '_');

      final equipmentDirPath = path.join(baseDir, santizedEquipmentName);
      final equipmentDir = Directory(equipmentDirPath);

      if (!await equipmentDir.exists()) {
        print("Creating equipment folder at: $equipmentDirPath");
        await equipmentDir.create(recursive: true);
        if (await equipmentDir.exists()) {
          print("Created equipment folder: $equipmentDirPath");
        } else {
          print("FAiled to create equipment folder.");
          return;
        }
      }

      final filePath = path.join(equipmentDirPath,
          '${santizedEquipmentName}_preventivemaintenance.json');
      final file = File(filePath);
      final jsonList = maintenanceTasks.map((mt) => mt.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      print(
          "Successfully wroet ${maintenanceTasks.length} maintenance tasks to file: $filePath");
    } catch (e) {
      print("Error saving maintenance task: $e");
      rethrow;
    }
  }

  static Future<List<MaintenanceTask>> loadMaintenanceList(
      String equipmentName) async {
    try {
      const baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/history/maintenance/preventiveMaintenance/preventivemaintenancestorage';
      final santizedEquipmentName = equipmentName.replaceAll('/', '_');
      final equipmentDirPath = path.join(baseDir, santizedEquipmentName);

      final filePath = path.join(equipmentDirPath,
          '${santizedEquipmentName}_preventivemaintenance.json');

      final file = File(filePath);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        final maintenanceList =
            jsonList.map((json) => MaintenanceTask.fromJson(json)).toList();
        print("Loaded ${maintenanceList.length} mainteance list from file");
        return maintenanceList;
      } else {
        print("No maintenance list found for equipment: $filePath");
        return [];
      }
    } catch (e) {
      print("Error loading maintenance list: $e");
      rethrow;
    }
  }

  static Future<void> deleteMaintenanceList(String equipmentName) async {
    try {
      const baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/history/maintenance/preventiveMaintenance/preventivemaintenancestorage';
      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');

      final equipmentDirPath = path.join(baseDir, sanitizedEquipmentName);
      final equipmentDir = Directory(equipmentDirPath);
      if (await equipmentDir.exists()) {
        await equipmentDir.delete(recursive: true);
        print("Successfully deleted equipment folder: $equipmentDirPath");
      } else {
        print("Equipment folder does not exist: $equipmentDirPath");
      }
    } catch (e) {
      print("Error deleting maintenance list: $e");
      rethrow;
    }
  }
}

class ChecklistItem {
  String item;
  bool isCompleted;
  String? reason;

  ChecklistItem({
    required this.item,
    this.isCompleted = false,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {'item': item, 'isCompleted': isCompleted, 'reason': reason};
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
        item: json['item'],
        isCompleted: json['isCompleted'] ?? false,
        reason: json['reason']);
  }
}

class MaintenanceTaskDetailsPage extends StatelessWidget {
  final MaintenanceTask task;
  const MaintenanceTaskDetailsPage({Key? key, required this.task})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.task),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task: ${task.task}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Status: ${task.status}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            Text('Responsible:${task.responsible}'),
            SizedBox(
              height: 10,
            ),
            Text(
              'Last Updated: ${DateFormat('yyyy-MM-dd HH:mm').format(task.lastUpdate)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Elapsed Time: ${task.elapsedTime.inHours} hours ${task.elapsedTime.inMinutes % 60} minutes ',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            _buildSectionTitle('Situation Before'),
            Text(task.situationBefore.isNotEmpty
                ? task.situationBefore
                : "No details Provided"),
            SizedBox(height: 10),
            _buildSectionTitle('Steps Taken'),
            if (task.stepsTaken.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    task.stepsTaken.map((step) => Text('* $step')).toList(),
              )
            else
              Text("No steps recorded"),
            SizedBox(height: 10),
            _buildSectionTitle('Tools USed'),
            if (task.toolsUsed.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    task.toolsUsed.map((tool) => Text('* $tool')).toList(),
              )
            else
              Text('No tools recorded'),
            SizedBox(height: 10),
            Text(
              'Checklist Status: ${task.checklistStatus}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: ListView.builder(
              itemCount: task.checklist.length,
              itemBuilder: (context, index) {
                var checklistItem = task.checklist[index];
                return ListTile(
                  title: Text(checklistItem.item),
                  trailing: Text(
                      checklistItem.isCompleted ? 'Completed' : 'Incompleted'),
                  subtitle: checklistItem.reason != null
                      ? Text('Reason: ${checklistItem.reason}')
                      : null,
                );
              },
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline),
      ),
    );
  }
}

class MaintenanceTablePage extends StatefulWidget {
  final String equipmentName;
  final String processName;
  final String subprocessName;
  const MaintenanceTablePage(
      {Key? key,
      required this.equipmentName,
      required this.processName,
      required this.subprocessName})
      : super(key: key);

  @override
  _MaintenanceTablePageState createState() => _MaintenanceTablePageState();
}

class _MaintenanceTablePageState extends State<MaintenanceTablePage> {
  // Sample data - you'll replace this with your actual data source
  List<MaintenanceTask> _maintenanceData = [];
  @override
  void initState() {
    super.initState();
    _loadMaintenanceList();
  }

  Future<void> _loadMaintenanceList() async {
    try {
      final loadMaintenanceList =
          await MaintenanceTask.loadMaintenanceList(widget.equipmentName);
      setState(() {
        _maintenanceData = loadMaintenanceList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading maintenance task: $e')));
    }
  }

  Future<void> _saveMaintenanceList() async {
    try {
      await MaintenanceTask.saveMaintenanceList(
          _maintenanceData, widget.equipmentName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving maintenance task: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Maintenance'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMaintenanceDataTable(),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _addNewMaintenanceTask,
              child: Text('Add New Maintenance Task'),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(MaintenanceTask task) {
    List<TextEditingController> stepsController = task.stepsTaken.isNotEmpty
        ? task.stepsTaken
            .map((step) => TextEditingController(text: step))
            .toList()
        : [TextEditingController()];

    List<TextEditingController> toolsController = task.toolsUsed.isNotEmpty
        ? task.toolsUsed
            .map((tool) => TextEditingController(text: tool))
            .toList()
        : [TextEditingController()];
    List<TextEditingController> reasonController = List.generate(
        task.checklist.length,
        (index) =>
            TextEditingController(text: task.checklist[index].reason ?? ''));
    TextEditingController situationBeforeController =
        TextEditingController(text: task.situationBefore);
    TextEditingController situationAfterController =
        TextEditingController(text: task.situationAfter);
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Update Maintenance Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      maxLines: 3,
                      maxLength: 200,
                      controller: situationBeforeController,
                      decoration: InputDecoration(
                          labelText: "Situation Before/Reason",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                            20,
                          )),
                          filled: true,
                          fillColor: Colors.grey[200]),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Steps Taken',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...List.generate(
                        stepsController.length,
                        (index) => TextField(
                              controller: stepsController[index],
                              decoration: InputDecoration(
                                  labelText: 'Step ${index + 1}',
                                  border: OutlineInputBorder()),
                            )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if (stepsController.length > 1) {
                                  stepsController.removeLast();
                                }
                              });
                            },
                            icon: Icon(Icons.remove)),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                stepsController.add(TextEditingController());
                              });
                            },
                            icon: Icon(Icons.add)),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Tools Used',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...List.generate(
                        toolsController.length,
                        (index) => TextField(
                              controller: toolsController[index],
                              decoration: InputDecoration(
                                  labelText: 'Tool ${index + 1}',
                                  border: OutlineInputBorder()),
                            )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if (toolsController.length > 1) {
                                  toolsController.removeLast();
                                }
                              });
                            },
                            icon: Icon(Icons.remove)),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                toolsController.add(TextEditingController());
                              });
                            },
                            icon: Icon(Icons.add)),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: situationAfterController,
                      maxLines: 3,
                      maxLength: 200,
                      decoration: InputDecoration(
                          labelText: "Situation After",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          filled: true,
                          fillColor: Colors.grey[200]),
                    ),
                    Text("Checklist Items"),
                    Text(
                      'Checklist',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...List.generate(task.checklist.length, (index) {
                      return Column(
                        children: [
                          Text(task.checklist[index].item),
                          Row(
                            children: [
                              Checkbox(
                                value: task.checklist[index].isCompleted,
                                onChanged: (bool? value) {
                                  setState(
                                    () {
                                      task.checklist[index].isCompleted =
                                          value ?? false;
                                    },
                                  );
                                },
                              ),
                              Text('Yes'),
                            ],
                          ),
                          if (!task.checklist[index].isCompleted)
                            TextField(
                              controller: reasonController[index],
                              decoration: InputDecoration(
                                  labelText: 'Reason for incomplete'),
                              onChanged: (value) {
                                task.checklist[index].reason = value;
                              },
                            )
                        ],
                      );
                    }),
                    DropdownButtonFormField<String>(
                        value: task.status,
                        items: ['incomplete', 'in progress', 'completed']
                            .map((status) => DropdownMenuItem(
                                value: status, child: Text(status)))
                            .toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            setState(() {
                              task.updateStatus(newStatus);
                            });
                          }
                        })
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          task.situationBefore = situationBeforeController.text;
                          task.situationAfter = situationAfterController.text;
                          task.stepsTaken = stepsController
                              .map((controller) => controller.text)
                              .where((step) => step.isNotEmpty)
                              .toList();

                          task.toolsUsed = toolsController
                              .map((controller) => controller.text)
                              .where((tool) => tool.isNotEmpty)
                              .toList();

                          task.updateChecklistStatus();
                          setState(() {
                            _saveMaintenanceList().then((_) {
                              _loadMaintenanceList();
                            });
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.green),
                        )),
                    TextButton(
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  Widget _buildColumnsLabelRow() {
    return Container(
      color: Colors.grey[200],
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text('Equipment \n Maintenance Task '),
              )),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Status'),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Last Updated'),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Duration of Task'),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Responsible'),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Task CheckList'),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Actions'),
                ),
              )
            ],
          )),
    );
  }

  Widget _buildMaintenanceDataTable() {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
        4: FlexColumnWidth(2),
        5: FlexColumnWidth(2),
        6: FlexColumnWidth(1),
      },
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            border: Border(
              bottom: BorderSide(
                  color: Colors.grey), // Horizontal line under header
            ),
          ),
          children: _buildTableHeaders([
            'Equipment \n Maintenance Task',
            'Status',
            'Last Updated',
            'Elapsed Time',
            'Responsible',
            'Checklist Status',
            'Actions',
          ]),
        ),

        // Rows from data
        for (var task in _maintenanceData)
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: Colors.grey), // Horizontal line above each row
              ),
            ),
            children: [
              _buildTableCell(
                child: TextButton(
                  child: Text(
                    task.task,
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MaintenanceTaskDetailsPage(task: task),
                      ),
                    );
                  },
                ),
              ),
              _buildTableCell(
                child: Text(
                  task.status,
                  textAlign: TextAlign.center,
                ),
              ),
              _buildTableCell(
                child: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(task.lastUpdate),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildTableCell(
                child: Text(
                  '${task.elapsedTime.inHours} hrs ${task.elapsedTime.inMinutes % 60} mins',
                  textAlign: TextAlign.center,
                ),
              ),
              _buildTableCell(
                child: Text(
                  task.responsible,
                  textAlign: TextAlign.center,
                ),
              ),
              _buildTableCell(
                child: Text(
                  task.checklistStatus,
                  textAlign: TextAlign.center,
                ),
              ),
              _buildTableCell(
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showUpdateDialog(task);
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Reusable TableCell builder
  Widget _buildTableCell({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: child),
    );
  }

  /// Builds header cells for the Table widget
  List<Widget> _buildTableHeaders(List<String> headers) {
    return headers.map((header) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            header,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildColumnsLabelRows2() {
    List<String> columnLabels = [
      'Equipment \n Maintenance Task',
      'Status',
      'Last Updated',
      'Duration of Task',
      'Responsible',
      'Task CheckList',
      'Actions'
    ];
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: columnLabels.map((label) {
            return Expanded(
                child: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ));
          }).toList(),
        ),
      ),
    );
  }

  void _addNewMaintenanceTask() {
    bool addCheckList = false;
    TextEditingController taskController = TextEditingController();
    TextEditingController responsibleController = TextEditingController();
    List<TextEditingController> checklistitemsController = [
      TextEditingController()
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Maintenance Task'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Add this to control column size
                children: [
                  TextFormField(
                      controller: taskController,
                      decoration: InputDecoration(
                        labelText: "Equipment/Maintenance Task",
                        border: OutlineInputBorder(), // Add border
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter equipment/maintenance task';
                        }
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: responsibleController,
                    decoration: InputDecoration(
                      labelText: "Responsible",
                      border: OutlineInputBorder(), // Add border
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Add Checklist?",
                      ),
                      Checkbox(
                          value: addCheckList,
                          onChanged: (value) {
                            setState(() {
                              addCheckList = value ?? false;
                            });
                          }),
                    ],
                  ),
                  if (addCheckList == true) ...[
                    // Wrap the dynamic checklist items in a SizedBox or Flexible
                    SizedBox(
                      width: double.infinity, // Provide width constraint
                      child: Column(
                        children: List.generate(
                          checklistitemsController.length,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: checklistitemsController[i],
                              decoration: InputDecoration(
                                labelText: "Add Checklist Item",
                                border: OutlineInputBorder(), // Add border
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if (checklistitemsController.length > 1) {
                                  checklistitemsController.removeLast();
                                }
                              });
                            },
                            icon: Icon(Icons.remove)),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                checklistitemsController
                                    .add(TextEditingController());
                              });
                            },
                            icon: Icon(Icons.add)),
                      ],
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
                        List<ChecklistItem> checklist = addCheckList
                            ? checklistitemsController
                                .where(
                                    (controller) => controller.text.isNotEmpty)
                                .map((controller) =>
                                    ChecklistItem(item: controller.text))
                                .toList()
                            : [];

                        MaintenanceTask newTask = MaintenanceTask(
                            task: taskController.text,
                            responsible: responsibleController.text,
                            checklist: checklist);
                        setState(() {
                          _maintenanceData.add(newTask);
                          _saveMaintenanceList().then((value) {
                            _loadMaintenanceList();
                          });
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.green),
                      )),
                  TextButton(
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          );
        });
      },
    );
  }
}
