import 'package:flutter/material.dart';

class MaintenanceTablePage extends StatefulWidget {
  const MaintenanceTablePage({Key? key}) : super(key: key);

  @override
  _MaintenanceTablePageState createState() => _MaintenanceTablePageState();
}

class _MaintenanceTablePageState extends State<MaintenanceTablePage> {
  // Sample data - you'll replace this with your actual data source
  final List<Map<String, dynamic>> _maintenanceData = [
    {
      'task': 'HVAC System Check',
      'status': 'inprogress',
      'lastUpdate': '2024-01-15',
      'duration': '2 hours',
      'responsible': 'John Doe',
      'checklist': 'Partial'
    },
    {
      'task': 'Generator Inspection',
      'status': 'completed',
      'lastUpdate': '2024-02-01',
      'duration': '3 hours',
      'responsible': 'Jane Smith',
      'checklist': 'Complete'
    },
  ];

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
                  rows: _maintenanceData.map((data) {
                    return DataRow(cells: [
                      DataCell(TextButton(
                        child: Text(data['task']),
                        onPressed: () {},
                      )),
                      DataCell(Text(data['status'])),
                      DataCell(Text(data['lastUpdate'])),
                      DataCell(Text(data['duration'])),
                      DataCell(Text(data['responsible'])),
                      DataCell(Text(data['checklist'])),
                      DataCell(IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // TODO: Implement update logic
                          _showUpdateDialog(data);
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

  void _showUpdateDialog(Map<String, dynamic> data) {
    List<TextEditingController> stepsController = [TextEditingController()];
    List<TextEditingController> toolsController = [TextEditingController()];
    TextEditingController situationBeforeController = TextEditingController();
    TextEditingController situationAfterController = TextEditingController();
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
                      maxLines: 5,
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
                    TextFormField(
                      decoration: InputDecoration(labelText: "Last Update"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    for (int i = 0; i < stepsController.length; i++)
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: "Steps ${i + 1}"),
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
                    for (int j = 0; j < toolsController.length; j++)
                      TextFormField(
                        decoration: InputDecoration(labelText: "Tools Used"),
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
                      height: 10,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Status"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      maxLines: 5,
                      maxLength: 200,
                      decoration: InputDecoration(
                          labelText: "Situation After",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          filled: true,
                          fillColor: Colors.grey[200]),
                    )
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {},
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
                mainAxisSize: MainAxisSize.min, // Add this to control column size
                children: [
                  TextFormField(
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
                      onPressed: () {},
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
