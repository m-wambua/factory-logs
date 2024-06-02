import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess1Data.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_data_display.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_1_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_2_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_3_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_4_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_5_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_6_details_page1.dart';
import 'package:flutter/material.dart';

class SavedValues {
  String uncoiler = '';
  String briddle1A = '';
  String briddle1B = '';
  String briddle2A = '';
  String briddle2B = '';
  String recoiler = '';

  // Remarks

  String uncoilerRemark = '';
  String briddle1ARemark = '';
  String briddle1BRemark = '';
  String briddle2ARemark = '';
  String briddle2BRemark = '';
  String recoilerRemark = '';
}

SavedValues savedValues = SavedValues();

class SubProcess1Page1 extends StatefulWidget {
  final Function(NotificationModel) onNotificationAdded;
  const SubProcess1Page1({super.key, required this.onNotificationAdded});

  @override
  State<SubProcess1Page1> createState() => _SubProcess1Page1State();
}

class _SubProcess1Page1State extends State<SubProcess1Page1> {
  final TextEditingController _uncoilerController = TextEditingController();
  final TextEditingController _uncoilerRemarkController =
      TextEditingController();

  final TextEditingController _briddle1AController = TextEditingController();
  final TextEditingController _briddle1ARemarkController =
      TextEditingController();

  final TextEditingController _briddle1BController = TextEditingController();
  final TextEditingController _briddle1BRemarkController =
      TextEditingController();

  final TextEditingController _briddle2AController = TextEditingController();
  final TextEditingController _briddle2ARemarkController =
      TextEditingController();

  final TextEditingController _briddle2BController = TextEditingController();
  final TextEditingController _briddle2BRemarkController =
      TextEditingController();

  final TextEditingController _recoilerController = TextEditingController();
  final TextEditingController _recoilerRemarkController =
      TextEditingController();

  final Process1Data process1Data = Process1Data();
  List<NotificationModel> _sampleNotifications = [];
  @override
  void initState() {
    super.initState();
    //Intialize text field with saved values
    _uncoilerController.text = savedValues.uncoiler.toString();
    _briddle1AController.text = savedValues.briddle1A.toString();
    _briddle1BController.text = savedValues.briddle1B.toString();
    _briddle2AController.text = savedValues.briddle2A.toString();
    _briddle2BController.text = savedValues.briddle2B.toString();
    _recoilerController.text = savedValues.recoiler.toString();

    _uncoilerRemarkController.text = savedValues.uncoilerRemark;
    _briddle1ARemarkController.text = savedValues.briddle1ARemark;
    _briddle1BRemarkController.text = savedValues.briddle1BRemark;
    _briddle2ARemarkController.text = savedValues.briddle2ARemark;
    _briddle2BRemarkController.text = savedValues.briddle2BRemark;
    _recoilerRemarkController.text = savedValues.recoilerRemark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TLL Drives'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('Drive Motor Current')),
              DataColumn(label: Text('Rated')),
              DataColumn(label: Text('Drawn')),
              DataColumn(label: Text('Remarks'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('UNCOILER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page1Details1()));
                  },
                )),
                const DataCell(Text('351')),
                DataCell(TextField(
                  controller: _uncoilerController,
                )),
                DataCell(TextField(
                  controller: _uncoilerRemarkController,
                ))
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 1A'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page1Details2()));
                  },
                )),
                const DataCell(Text('191')),
                DataCell(TextField(
                  controller: _briddle1AController,
                )),
                DataCell(TextField(
                  controller: _briddle1ARemarkController,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 1B'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page1Details3()));
                  },
                )),
                const DataCell(Text('375')),
                DataCell(TextField(
                  controller: _briddle1BController,
                )),
                DataCell(TextField(
                  controller: _briddle1BRemarkController,
                ))
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 2A'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page1Details4()));
                  },
                )),
                const DataCell(Text('375')),
                DataCell(TextField(
                  controller: _briddle2AController,
                )),
                DataCell(TextField(
                  controller: _briddle2ARemarkController,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 2B'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page1Details5()));
                  },
                )),
                const DataCell(Text('191')),
                DataCell(TextField(
                  controller: _briddle2BController,
                )),
                DataCell(TextField(
                  controller: _briddle2BRemarkController,
                ))
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('RECOLIER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page1Details6()));
                  },
                )),
                const DataCell(Text('351')),
                DataCell(TextField(
                  controller: _recoilerController,
                )),
                DataCell(TextField(
                  controller: _recoilerRemarkController,
                ))
              ]),
            ]),
            const SizedBox(
              height: 20,
            ),

            // Add buttons for additonal functionality

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Update placeholders with entered values

                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data Saved as draft')));
                    //Update saved values with values from the text field
                    savedValues.uncoiler = _uncoilerController.text.trim();
                    savedValues.briddle1A = _briddle1AController.text.trim();
                    savedValues.briddle1B = _briddle1BController.text.trim();
                    savedValues.briddle2A = _briddle2AController.text.trim();
                    savedValues.briddle2B = _briddle2BController.text.trim();
                    savedValues.recoiler = _recoilerController.text.trim();
                    // Show notification or perform any other action

                    savedValues.uncoilerRemark =
                        _uncoilerRemarkController.text.trim();
                    savedValues.briddle1ARemark =
                        _briddle1ARemarkController.text.trim();
                    savedValues.briddle1BRemark =
                        _briddle1BRemarkController.text.trim();
                    savedValues.briddle2ARemark =
                        _briddle2ARemarkController.text.trim();
                    savedValues.briddle2BRemark =
                        _briddle2BRemarkController.text.trim();
                    savedValues.recoilerRemark =
                        _recoilerRemarkController.text.trim();
                    // Show notification or perform any other action
                  },
                  child: const Text('Save as Draft'),
                ),

                SizedBox(
                  width: 10,
                ),

                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SubProcessDataDisplay()),
                    );
                  },
                  child: const Text('View Saved Data'),

// Create a list of Categories for other components here
                ),
                SizedBox(
                  width: 10,
                ),
                // Add buttons for additional functionality
                ElevatedButton(
                  onPressed: () async {
                    // Update placeholders with entered values
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data Saved as draft')),
                    );

                    // Create a list of categories for each component
                    List<Process1Category> categories = [
                      Process1Category(
                        name: 'UNCOILER',
                        current: int.parse(_uncoilerController.text.trim()),
                        remark: _uncoilerRemarkController.text.trim(),
                      ),
                      // Add categories for other components here
                      Process1Category(
                        name: 'BRIDDLE 1 A',
                        current: int.parse(_briddle1AController.text.trim()),
                        remark: _briddle1ARemarkController.text.trim(),
                      ),

                      Process1Category(
                        name: 'BRIDDLE 1 B',
                        current: int.parse(_briddle1BController.text.trim()),
                        remark: _briddle1BRemarkController.text.trim(),
                      ),

                      Process1Category(
                        name: 'BRIDDLE 2 A',
                        current: int.parse(_briddle2AController.text.trim()),
                        remark: _briddle2ARemarkController.text.trim(),
                      ),

                      Process1Category(
                        name: 'BRIDDLE 2 B',
                        current: int.parse(_briddle2BController.text.trim()),
                        remark: _briddle2BRemarkController.text.trim(),
                      ),

                      Process1Category(
                        name: 'RECOILER',
                        current: int.parse(_recoilerController.text.trim()),
                        remark: _recoilerRemarkController.text.trim(),
                      ),
                    ];

                    // Create a new entry with the categories and current timestamp
                    final newEntry = Process1Entry(
                        categories: categories, lastUpdate: DateTime.now());

                    // Add the new entry to the data list
                    setState(() {
                      process1Data.process1DataList.add(newEntry);
                    });

                    // Save the data
                    await process1Data.saveSubprocess1Data();

                    // Create a new notification
                    final newNotification = NotificationModel(
                        title: 'New Entry Saved',
                        description: 'An entry has been saved and Submitted',
                        timestamp: DateTime.now(),
                        type: NotificationType.LogsCollected);

                    // Add the new notification to the List
                    setState(() {
                      _sampleNotifications.add(newNotification);
                      saveNotificationsToFile(_sampleNotifications);
                    });
                  },
                  child: const Text('Save and Submit All'),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
