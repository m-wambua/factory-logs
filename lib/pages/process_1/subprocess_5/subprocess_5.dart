import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess4Data.dart';
import 'package:collector/pages/process_1/subprocess_5/subprocess5Data.dart';
import 'package:collector/pages/process_1/subprocess_5/subprocess_data_display.dart';
import 'package:flutter/material.dart';

class SavedValues {
  String pos_1 = '';
  String pos_2 = '';
  String pos_3 = '';
  String pos_4 = '';

  String pos_1Remark = '';
  String pos_2Remark = '';
  String pos_3Remark = '';
  String pos_4Remark = '';
}

SavedValues savedValues = SavedValues();

class SubProcess5Page1 extends StatefulWidget {
  final Function(NotificationModel) onNotificationAdded;
  const SubProcess5Page1({super.key, required this.onNotificationAdded});

  @override
  State<SubProcess5Page1> createState() => _SubProcess5Page1State();
}

class _SubProcess5Page1State extends State<SubProcess5Page1> {
  final TextEditingController _pos_1Controller = TextEditingController();
  final TextEditingController _pos_2Controller = TextEditingController();
  final TextEditingController _pos_3Controller = TextEditingController();
  final TextEditingController _pos_4Controller = TextEditingController();

  final TextEditingController _pos_1ControllerRemark = TextEditingController();
  final TextEditingController _pos_2ControllerRemark = TextEditingController();
  final TextEditingController _pos_3ControllerRemark = TextEditingController();
  final TextEditingController _pos_4ControllerRemark = TextEditingController();
  //TextEditingController _pos_5Controller = TextEditingController();
  Process5Data process5data = Process5Data();
  List<NotificationModel> _sampleNotifications = [];
  @override
  void initState() {
    super.initState();
    _pos_1Controller.text = savedValues.pos_1.toString();
    _pos_2Controller.text = savedValues.pos_2.toString();
    _pos_3Controller.text = savedValues.pos_3.toString();
    _pos_4Controller.text = savedValues.pos_4.toString();

    _pos_1ControllerRemark.text = savedValues.pos_1Remark;
    _pos_2ControllerRemark.text = savedValues.pos_2Remark;
    _pos_3ControllerRemark.text = savedValues.pos_3Remark;
    _pos_4ControllerRemark.text = savedValues.pos_4Remark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          child: const Text('TLL CROWNING'),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('READINGS')),
              DataColumn(label: Text('RATED')),
              DataColumn(label: Text('DRAWN')),
              DataColumn(label: Text('Remarks'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                const DataCell(Text('1')),
                const DataCell(Text(' ')),
                DataCell(TextField(
                  controller: _pos_1Controller,
                )),
                DataCell(TextField(
                  controller: _pos_1ControllerRemark,
                ))
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                const DataCell(Text('2')),
                const DataCell(Text(' ')),
                DataCell(TextField(
                  controller: _pos_2Controller,
                )),
                DataCell(TextField(
                  controller: _pos_2ControllerRemark,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                const DataCell(Text('3')),
                const DataCell(Text(' ')),
                DataCell(TextField(
                  controller: _pos_3Controller,
                )),
                DataCell(TextField(
                  controller: _pos_3ControllerRemark,
                ))
              ]),
// Add rows or data entry
              DataRow(cells: [
                const DataCell(Text('4')),
                const DataCell(Text(' ')),
                DataCell(TextField(
                  controller: _pos_4Controller,
                )),
                DataCell(TextField(
                  controller: _pos_4ControllerRemark,
                ))
              ]),

              // Add rows or data entry
              /*
              DataRow(cells: [
                DataCell(Text('Parameter 1')),
                DataCell(TextField()),
                DataCell(TextField()),
                DataCell(TextField())
              ]),
              */
            ]),
            const SizedBox(
              height: 20,
            ),
            // Add buttons for additonal functionality

            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      savedValues.pos_1 = _pos_1Controller.text.trim();
                      savedValues.pos_2 = _pos_2Controller.text.trim();
                      savedValues.pos_3 = _pos_3Controller.text.trim();
                      savedValues.pos_4 = _pos_4Controller.text.trim();

                      savedValues.pos_1Remark =
                          _pos_1ControllerRemark.text.trim();
                      savedValues.pos_2Remark =
                          _pos_2ControllerRemark.text.trim();
                      savedValues.pos_3Remark =
                          _pos_3ControllerRemark.text.trim();
                      savedValues.pos_4Remark =
                          _pos_4ControllerRemark.text.trim();
                    },
                    child: const Text('Saved as Draft')),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Subprocess5DataDisplay()));
                    },
                    child: Text('View saved data')),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data Saved as Draft')));
                      // Create a list of categories for each component
                      List<Process5Category> categories = [
                        Process5Category(
                            name: 'Position 1',
                            current: int.parse(_pos_1Controller.text.trim()),
                            remark: _pos_1ControllerRemark.text.trim()),
                        Process5Category(
                            name: 'Position 2',
                            current: int.parse(_pos_2Controller.text.trim()),
                            remark: _pos_2ControllerRemark.text.trim()),
                        Process5Category(
                            name: 'Position 3',
                            current: int.parse(_pos_3Controller.text.trim()),
                            remark: _pos_3ControllerRemark.text.trim()),
                        Process5Category(
                            name: 'Position 4',
                            current: int.parse(_pos_4Controller.text.trim()),
                            remark: _pos_4ControllerRemark.text.trim())
                      ];

                      // Create a new entry with the categries and currents
                      final newEntry = Process5Entry(
                          lastUpdate: DateTime.now(), categories: categories);
                      // Add the new entry to the data list
                      setState(() {
                        process5data.process5DataList.add(newEntry);
                      });

                      // Save the data
                      await process5data.savedSubprocess5Data();

                      // Create a new notification
                      final newNotification = NotificationModel(
                          title: ' New Entry Saved',
                          description:
                              ' An entry has been saved and submitted for the TLL Posisitons',
                          timestamp: DateTime.now(),
                          type: NotificationType.LogsCollected);
                      // Add the new notification to the list
                      setState(() {
                        _sampleNotifications.add(newNotification);
                        saveNotificationsToFile(_sampleNotifications);
                      });
                    },
                    child: Text('Save and Submit all'))
              ],
            )
          ]),
        ),
      ),
    );
  }
}
