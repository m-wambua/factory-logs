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
                      DataCell(Text(data['task'])),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Maintenance Task'),
          content: Text('Implement update logic for: ${data['task']}'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewMaintenanceTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Maintenance Task'),
          content: Text('Implement add new task logic here'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
