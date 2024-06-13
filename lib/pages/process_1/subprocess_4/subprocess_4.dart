import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess4Data.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess4_data_display.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_details/subprocess_1_details_page4.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_details/subprocess_2_details_page4.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_details/subprocess_3_details_page4.dart';
import 'package:flutter/material.dart';

class SavedValues {
  String tpr = '';
  String str = '';
  String lrp = '';

  String tprRemark = '';
  String strRemark = '';
  String lrpRemark = '';
}

SavedValues savedValues = SavedValues();

class SubProcess4Page1 extends StatefulWidget {
  final Function(NotificationModel) onNotificationAdded;
  const SubProcess4Page1({super.key, required this.onNotificationAdded});

  @override
  State<SubProcess4Page1> createState() => _SubProcess4Page1State();
}

class _SubProcess4Page1State extends State<SubProcess4Page1> {
  final TextEditingController _trpController = TextEditingController();
  final TextEditingController _strController = TextEditingController();
  final TextEditingController _lrpController = TextEditingController();

  final TextEditingController _trpRemarkController = TextEditingController();
  final TextEditingController _strRemarkController = TextEditingController();
  final TextEditingController _lrpRemarkController = TextEditingController();

  final Process4Data process4data = Process4Data();
  List<NotificationModel> _sampleNotifications = [];
  @override
  void initState() {
    super.initState();
    // Intialize text field with saved values
    _trpController.text = savedValues.tpr.toString();
    _strController.text = savedValues.str.toString();
    _lrpController.text = savedValues.lrp.toString();

    _trpRemarkController.text = savedValues.tprRemark;
    _strRemarkController.text = savedValues.strRemark;
    _lrpRemarkController.text = savedValues.lrpRemark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TLL POSITIONS [MM]'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('MOTOR')),
              DataColumn(label: Text('RATED')),
              DataColumn(label: Text('DRAWN')),
              DataColumn(label: Text('Remarks'))
            ], rows: [
              // Add rows or data entry

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('TPR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page4Details1_4()));
                  },
                )),
                const DataCell(Text('  ')),
                DataCell(TextField(
                  controller: _trpController,
                )),
                DataCell(TextField(
                  controller: _trpRemarkController,
                ))
              ]),
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('S.T.R'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page4Details2_4()));
                  },
                )),
                const DataCell(Text('  ')),
                DataCell(TextField(
                  controller: _strController,
                )),
                DataCell(TextField(
                  controller: _strRemarkController,
                ))
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('LRP'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page4Details3_4()));
                  },
                )),
                const DataCell(Text('  ')),
                DataCell(TextField(
                  controller: _lrpController,
                )),
                DataCell(TextField(
                  controller: _lrpRemarkController,
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
// Add rows or data entry
              DataRow(cells: [
                DataCell(Text('Parameter 1')),
                DataCell(TextField()),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      savedValues.tpr = _trpController.text.trim();
                      savedValues.lrp = _lrpController.text.trim();
                      savedValues.str = _strController.text.trim();
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
                              builder: (context) =>
                                  const Subprocess4DataDisplay()));
                    },
                    child: Text('View saved Data')),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () async {
                      //Update placeholders with entered values
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(' Data Saved as Draft')));

                      // Create a List of categories for each component
                      List<Process4Category> categories = [
                        Process4Category(
                            name: 'T.R.P',
                            current: int.parse(_trpController.text.trim()),
                            remark: _trpRemarkController.text.trim()),
                        Process4Category(
                            name: 'L.R.P',
                            current: int.parse(_lrpController.text.trim()),
                            remark: _lrpRemarkController.text.trim()),
                        Process4Category(
                            name: 'S.T.R',
                            current:
                                int.parse(_strRemarkController.text.trim()),
                            remark: _strRemarkController.text.trim())
                      ];
                      // Create a new entry with the categories and current timestamp
                      final newEntry = Process4Entry(
                          lastUpdate: DateTime.now(), categories: categories);
                      // Add the new Entry to the datalist
                      setState(() {
                        process4data.process4DataList.add(newEntry);
                      });
                      // Save the data
                      await process4data.saveSUbprocess4Data();
                      final newNotification = NotificationModel(
                          title: 'New Entry Saved',
                          description: 'An entry has been saved and Submited',
                          timestamp: DateTime.now(),
                          type: NotificationType.LogsCollected);
                      // Add the new notification to the list
                      setState(() {
                        _sampleNotifications.add(newNotification);
                        saveNotificationsToFile(_sampleNotifications);
                      });
                    },
                    child: Text('Save and Submit All'))
              ],
            )
          ]),
        ),
      ),
    );
  }
}
