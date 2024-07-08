import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess3Data.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess3_data_display.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess_details/subprocess_1_details_page3.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess_details/subprocess_2_details_page3.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess_details/subprocess_3_details_page3.dart';
import 'package:flutter/material.dart';

class SavedValues {
  String ltmotor = '';
  String ctmotor = '';
  String hoistmotor = '';

  String ltmotorRemark = '';
  String ctmotorRemark = '';
  String hoistmotorRemark = '';
}

SavedValues savedValues = SavedValues();

class SubProcess3Page1 extends StatefulWidget {
  final Function(NotificationModel) onNotificationAdded;
  const SubProcess3Page1({super.key, required this.onNotificationAdded});

  @override
  State<SubProcess3Page1> createState() => _SubProcess3Page1State();
}

class _SubProcess3Page1State extends State<SubProcess3Page1> {
  final TextEditingController _ltmotorController = TextEditingController();

  final TextEditingController _ctmotorController = TextEditingController();

  final TextEditingController _hoistmotorController = TextEditingController();

  final TextEditingController _ltmotorRemarkController =
      TextEditingController();
  final TextEditingController _ctmotorRemarkController =
      TextEditingController();
  final TextEditingController _hoistmotorRemarkController =
      TextEditingController();

  final Process3Data process3data = Process3Data();
  final List<NotificationModel> _sampleNotifications = [];
  @override
  void initState() {
    super.initState();
    _ltmotorController.text = savedValues.ltmotor.toString();
    _ctmotorController.text = savedValues.ctmotor.toString();
    _hoistmotorController.text = savedValues.hoistmotor.toString();

    _ltmotorRemarkController.text = savedValues.ltmotorRemark;
    _ctmotorRemarkController.text = savedValues.ctmotorRemark;
    _hoistmotorRemarkController.text = savedValues.hoistmotorRemark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRANES'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('DRIVE/MOTOR')),
              DataColumn(label: Text('RATED')),
              DataColumn(label: Text('DRAWN')),
              DataColumn(label: Text('Remarks'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('L.T MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details1_3()));
                  },
                )),
                const DataCell(Text('4.3')),
                DataCell(TextField(
                  controller: _ltmotorController,
                )),
                DataCell(TextField(
                  controller: _ltmotorRemarkController,
                ))
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('C.T MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (contenxt) =>
                                const SubProcess1Page2Details2_3()));
                  },
                )),
                const DataCell(Text('2.1')),
                DataCell(TextField(
                  controller: _ctmotorController,
                )),
                DataCell(TextField(
                  controller: _ctmotorRemarkController,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('HOIST MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details3_3()));
                  },
                )),
                const DataCell(Text('38/18')),
                DataCell(TextField(
                  controller: _hoistmotorController,
                )),
                DataCell(TextField(
                  controller: _hoistmotorRemarkController,
                ))
              ]),
              /*
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      savedValues.ltmotor = _ltmotorController.text.trim();
                      savedValues.ctmotor = _ctmotorController.text.trim();
                      savedValues.hoistmotor =
                          _hoistmotorController.text.trim();
                    },
                    child: const Text('Save as Draft')),
                const SizedBox(
                  width: 10,
                ),
                // Add buttons for additonal functionality
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const Subprocess3DataDisplay()),
                      );
                    },
                    child: const Text(' View saved Data')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () async {
                      // Update placeholders with entered values
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(' Data  Saved as Draft')),
                      );
                      // Create a list of categories for each component
                      List<Process3Category> categories = [
                        Process3Category(
                            name: 'L.T Motor',
                            current: int.parse(_ltmotorController.text.trim()),
                            remark: _ltmotorRemarkController.text.trim()),
                        Process3Category(
                            name: 'C.T Motor',
                            current: int.parse(_ctmotorController.text.trim()),
                            remark: _ctmotorRemarkController.text.trim()),
                        Process3Category(
                            name: 'Hoist Motor',
                            current:
                                int.parse(_hoistmotorController.text.trim()),
                            remark: _hoistmotorRemarkController.text.trim()),
                      ];
                      // Create a new entry with the categories and current timestamp

                      final newEntry = Process3Entry(
                          categories: categories, lastUpdate: DateTime.now());

                      // Add the new Entry to the datalist
                      setState(() {
                        process3data.process3DataList.add(newEntry);
                      });

                      // Save the data
                      await process3data.saveSubprocess3Data();

                      final newNotification = NotificationModel(
                          title: 'New Entry Saved ',
                          description: 'An entry has been saved and Submitted',
                          timestamp: DateTime.now(),
                          type: NotificationType.LogsCollected);

                      // Add the new notification to the list
                      setState(() {
                        _sampleNotifications.add(newNotification);
                        saveNotificationsToFile(_sampleNotifications);
                      });
                    },
                    child: const Text(' Save and Submit All'))
              ],
            )
          ]),
        ),
      ),
    );
  }
}
