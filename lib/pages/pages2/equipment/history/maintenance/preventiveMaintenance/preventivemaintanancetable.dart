import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    this.checklist = const [],
    this.checklistStatus = 'not uploaded',
    this.situationBefore = '',
    this.stepsTaken = const [],
    this.toolsUsed = const [],
    this.situationAfter = '',
  })  : lastUpdate = lastUpdate ?? DateTime.now(),
        elapsedTime = elapsedTime ?? Duration.zero;
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
  const MaintenanceTablePage({Key? key}) : super(key: key);

  @override
  _MaintenanceTablePageState createState() => _MaintenanceTablePageState();
}

class _MaintenanceTablePageState extends State<MaintenanceTablePage> {
  // Sample data - you'll replace this with your actual data source
  List<MaintenanceTask> _maintenanceData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Maintenance'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  columns: [
                    DataColumn(
                        label: Text('Equipment\nMaintenance Task',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                        label: Text('Last\nUpdate',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Duration\nof Task',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Responsible',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Task\nChecklist',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _maintenanceData.map((task) {
                    return DataRow(cells: [
                      DataCell(TextButton(
                        child: Text(task.task),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MaintenanceTaskDetailsPage(task: task)));
                        },
                      )),
                      DataCell(Text(task.status)),
                      DataCell(Text(DateFormat('yyyy-MM-dd HH:mm')
                          .format(task.lastUpdate))),
                      DataCell(Text(
                          '${task.elapsedTime.inHours} hrs ${task.elapsedTime.inMinutes % 60} mins}')),
                      DataCell(Text(task.responsible)),
                      DataCell(Text(task.checklistStatus)),
                      DataCell(IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // TODO: Implement update logic
                          _showUpdateDialog(task);
                        },
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
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
                          setState(() {});
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
