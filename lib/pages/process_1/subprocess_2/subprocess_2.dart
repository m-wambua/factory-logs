import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess2Data.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_data_display.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_10_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_11_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_12_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_13_details_page.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_1_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_2_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_3_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_4_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_5_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_6_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_7_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_8_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_9_details_page2.dart';
import 'package:flutter/material.dart';

class SavedValues {
  // Current
  String uncoiler_blower_motor = '';
  String briddle_1a_blower = '';
  String briddler_1b_blower = '';
  String briddle_2a_blower = '';
  String briddle_2b_blower = '';
  String recoiler_motor_blower = '';
  String flattener_blower = '';
  String recoiler_lub_motor = '';
  String hydraulic_power_pack = '';
  String hydraulic_recirculation = '';
  String welder_motor = '';
  String scrap_baller_motor = '';
  String unc_lub_motor = '';
  //String uncoiler_blower_motor = '';
  //String uncoiler_blower_motor = '';

// Remarks

  String uncoiler_blower_motorRemark = '';
  String briddle_1a_blowerRemark = '';
  String briddler_1b_blowerRemark = '';
  String briddle_2a_blowerRemark = '';
  String briddle_2b_blowerRemark = '';
  String recoiler_motor_blowerRemark = '';
  String flattener_blowerRemark = '';
  String recoiler_lub_motorRemark = '';
  String hydraulic_power_packRemark = '';
  String hydraulic_recirculationRemark = '';
  String welder_motorRemark = '';
  String scrap_baller_motorRemark = '';
  String unc_lub_motorRemark = '';
}

SavedValues savedValues = SavedValues();

class SubProcess2Page1 extends StatefulWidget {
  final Function(NotificationModel) onNotificationAdded;
  const SubProcess2Page1({super.key, required this.onNotificationAdded});

  @override
  State<SubProcess2Page1> createState() => _SubProcess2Page1State();
}

class _SubProcess2Page1State extends State<SubProcess2Page1> {
  final TextEditingController _uncoilerblowerController =
      TextEditingController();
  final TextEditingController _briddle1ablowerController =
      TextEditingController();
  final TextEditingController _briddler1bblowerController =
      TextEditingController();
  final TextEditingController _briddler2ablowerController =
      TextEditingController();
  final TextEditingController _briddle2bblowerController =
      TextEditingController();
  final TextEditingController _recoilerblowerController =
      TextEditingController();
  final TextEditingController _flattenerblowerController =
      TextEditingController();
  final TextEditingController _recoilerlubmotorController =
      TextEditingController();
  final TextEditingController _hydraulic_power_packController =
      TextEditingController();
  final TextEditingController _hydraulic_recirculationController =
      TextEditingController();
  final TextEditingController _weldermotorController = TextEditingController();
  final TextEditingController _scrap_ballerController = TextEditingController();
  final TextEditingController _unc_lub_motorController =
      TextEditingController();

  // Remarks

  final TextEditingController _uncoilerblowerControllerRemark =
      TextEditingController();
  final TextEditingController _briddle1ablowerControllerRemark =
      TextEditingController();
  final TextEditingController _briddler1bblowerControllerRemark =
      TextEditingController();
  final TextEditingController _briddler2ablowerControllerRemark =
      TextEditingController();
  final TextEditingController _briddle2bblowerControllerRemark =
      TextEditingController();
  final TextEditingController _recoilerblowerControllerRemark =
      TextEditingController();
  final TextEditingController _flattenerblowerControllerRemark =
      TextEditingController();
  final TextEditingController _recoilerlubmotorControllerRemark =
      TextEditingController();
  final TextEditingController _hydraulic_power_packControllerRemark =
      TextEditingController();
  final TextEditingController _hydraulic_recirculationControllerRemark =
      TextEditingController();
  final TextEditingController _weldermotorControllerRemark =
      TextEditingController();
  final TextEditingController _scrap_ballerControllerRemark =
      TextEditingController();
  final TextEditingController _unc_lub_motorControllerRemark =
      TextEditingController();

  final Process2Data process2data = Process2Data();
  final List<NotificationModel> _sampleNotifications = [];

  @override
  void initState() {
    super.initState();
    //Initialize text field with saved values
    _uncoilerblowerController.text = savedValues.unc_lub_motor.toString();
    _briddle1ablowerController.text = savedValues.briddle_1a_blower.toString();
    _briddler1bblowerController.text =
        savedValues.briddler_1b_blower.toString();
    _briddler2ablowerController.text = savedValues.briddle_2a_blower.toString();
    _briddle2bblowerController.text = savedValues.briddle_2b_blower.toString();
    _recoilerblowerController.text =
        savedValues.recoiler_motor_blower.toString();
    _flattenerblowerController.text = savedValues.flattener_blower.toString();
    _recoilerlubmotorController.text =
        savedValues.recoiler_lub_motor.toString();
    _hydraulic_power_packController.text =
        savedValues.hydraulic_power_pack.toString();
    _hydraulic_recirculationController.text =
        savedValues.hydraulic_recirculation.toString();
    _weldermotorController.text = savedValues.welder_motor.toString();
    _scrap_ballerController.text = savedValues.scrap_baller_motor.toString();
    _unc_lub_motorController.text = savedValues.unc_lub_motor.toString();

    // Remarks

    _uncoilerblowerControllerRemark.text = savedValues.unc_lub_motorRemark;
    _briddle1ablowerControllerRemark.text = savedValues.briddle_1a_blowerRemark;
    _briddler1bblowerControllerRemark.text =
        savedValues.briddler_1b_blowerRemark;
    _briddler2ablowerControllerRemark.text =
        savedValues.briddle_2a_blowerRemark;
    _briddle2bblowerControllerRemark.text = savedValues.briddle_2b_blowerRemark;
    _recoilerblowerControllerRemark.text =
        savedValues.recoiler_motor_blowerRemark;
    _flattenerblowerControllerRemark.text = savedValues.flattener_blowerRemark;
    _recoilerlubmotorControllerRemark.text =
        savedValues.recoiler_lub_motorRemark;
    _hydraulic_power_packControllerRemark.text =
        savedValues.hydraulic_power_packRemark;
    _hydraulic_recirculationControllerRemark.text =
        savedValues.hydraulic_recirculationRemark;
    _weldermotorControllerRemark.text = savedValues.welder_motorRemark;
    _scrap_ballerControllerRemark.text = savedValues.scrap_baller_motorRemark;
    _unc_lub_motorControllerRemark.text = savedValues.unc_lub_motorRemark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCC MOTORS'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            const Text('FEEDER MOTORS CURRENT'),
            const SizedBox(
              height: 10,
            ),
            DataTable(columns: const [
              DataColumn(label: Text('FEEDER MOTORS CURRENT')),
              DataColumn(label: Text('RATED')),
              DataColumn(label: Text('DRAWN')),
              DataColumn(label: Text('Remarks'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('UNCOILER BLOWER MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details1_2()));
                  },
                )),
                const DataCell(Text('6.0')),
                DataCell(TextField(
                  controller: _uncoilerblowerController,
                )),
                DataCell(TextField(
                  controller: _uncoilerblowerControllerRemark,
                ))
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 1 #A BLOWER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details2_2()));
                  },
                )), //BRIDDLE 1 #A BLOWER
                const DataCell(Text('2.8')),
                DataCell(TextField(
                  controller: _briddle1ablowerController,
                )),
                DataCell(TextField(
                  controller: _briddle1ablowerControllerRemark,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDLE 1#B BLOWER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details3_2()));
                  },
                )), //BRIDLE 1#B BLOWER
                const DataCell(Text('6.0')),
                DataCell(TextField(
                  controller: _briddler1bblowerController,
                )),
                DataCell(TextField(
                  controller: _briddler1bblowerControllerRemark,
                ))
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 2#A BLOWER MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details4_2()));
                  },
                )), //BRIDDLE 2#A BLOWER MOTOR
                const DataCell(Text('6.1')),
                DataCell(TextField(
                  controller: _briddler2ablowerController,
                )),
                DataCell(TextField(
                  controller: _briddler2ablowerControllerRemark,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 2#B BLOWER MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details5_2()));
                  },
                )), //BRIDDLE 2#B BLOWER MOTOR
                const DataCell(Text('2.8')),
                DataCell(TextField(
                  controller: _briddle2bblowerController,
                )),
                DataCell(TextField(
                  controller: _briddle2bblowerControllerRemark,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('RECOILER MOTOR BLOWER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details13_2()));
                  },
                )), //RECOILER MOTOR BLOWER
                const DataCell(Text('6.0')),
                DataCell(TextField(
                  controller: _recoilerblowerController,
                )),
                DataCell(TextField(
                  controller: _recoilerblowerControllerRemark,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('FLATTENER MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details6_2()));
                  },
                )), //FLATTENER MOTOR
                const DataCell(Text('20.5')),
                DataCell(TextField(
                  controller: _flattenerblowerController,
                )),
                DataCell(TextField(
                  controller: _flattenerblowerControllerRemark,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('REC LUB MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details7_2()));
                  },
                )), //REC LUB MOTOR
                const DataCell(Text('3.4')),
                DataCell(TextField(
                  controller: _recoilerlubmotorController,
                )),
                DataCell(TextField(
                  controller: _recoilerlubmotorControllerRemark,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('HYD P PACK WRK & STBY'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details8_2()));
                  },
                )), //HYD P PACK WRK & STBY
                const DataCell(Text('40.0')),
                DataCell(TextField(
                  controller: _hydraulic_power_packController,
                )),
                DataCell(TextField(
                  controller: _hydraulic_power_packControllerRemark,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('HYDR. RECIRCULATIONS'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details9_2()));
                  },
                )), //HYDR. RECIRCULATIONS
                const DataCell(Text('3.4')),
                DataCell(TextField(
                  controller: _hydraulic_recirculationController,
                )),
                DataCell(TextField(
                  controller: _hydraulic_recirculationControllerRemark,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('WELDER MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details10_2()));
                  },
                )), //WELDER MOTOR
                const DataCell(Text('5.37/3.45')),
                DataCell(TextField(
                  controller: _weldermotorController,
                )),
                DataCell(TextField(
                  controller: _weldermotorControllerRemark,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('SCRAP BALLER MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details11_2()));
                  },
                )), //SCRAP BALLER MOTOR
                const DataCell(Text('39.5')),
                DataCell(TextField(
                  controller: _scrap_ballerController,
                )),
                DataCell(TextField(
                  controller: _scrap_ballerControllerRemark,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('UNC. LUB MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page2Details12_2()));
                  },
                )), //UNC. LUB MOTOR
                const DataCell(Text('3.4')),
                DataCell(TextField(
                  controller: _unc_lub_motorController,
                )),
                DataCell(TextField(
                  controller: _unc_lub_motorControllerRemark,
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
                    onPressed: () {
                      savedValues.unc_lub_motor =
                          _uncoilerblowerController.text.trim();
                      savedValues.briddle_1a_blower =
                          _briddle1ablowerController.text.trim();
                      savedValues.briddler_1b_blower =
                          _briddler1bblowerController.text.trim();
                      savedValues.briddle_2a_blower =
                          _briddler2ablowerController.text.trim();
                      savedValues.briddle_2b_blower =
                          _briddle2bblowerController.text.trim();
                      savedValues.recoiler_motor_blower =
                          _recoilerblowerController.text.trim();
                      savedValues.flattener_blower =
                          _flattenerblowerController.text.trim();
                      savedValues.recoiler_lub_motor =
                          _flattenerblowerController.text.trim();

                      savedValues.hydraulic_power_pack =
                          _hydraulic_power_packController.text.trim();
                      savedValues.hydraulic_recirculation =
                          _hydraulic_recirculationController.text.trim();
                      savedValues.welder_motor =
                          _weldermotorController.text.trim();
                      savedValues.scrap_baller_motor =
                          _scrap_ballerController.text.trim();
                      savedValues.unc_lub_motor =
                          _unc_lub_motorController.text.trim();
                    },
                    child: const Text('Save as Draft')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SubProcess2DataDisplay()));
                    },
                    child: const Text('View Saved Data')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () async {
                      // Update placeholders with entered values
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data Saved as Draft')));
                      // Create a list of categories foe each component
                      List<Process2Category> categories = [
                        Process2Category(
                            name: 'UNCOILER BLOWER MOTOR',
                            current: int.parse(
                                _uncoilerblowerController.text.trim()),
                            remark:
                                _uncoilerblowerControllerRemark.text.trim()),
                        Process2Category(
                            name: 'BRIDDLE 1#A BLOWER',
                            current: int.parse(
                                _briddle1ablowerController.text.trim()),
                            remark:
                                _briddle1ablowerControllerRemark.text.trim()),
                        Process2Category(
                            name: 'BRIDDLE 1#B BLOWER',
                            current: int.parse(
                                _briddle1ablowerController.text.trim()),
                            remark:
                                _briddle1ablowerControllerRemark.text.trim()),
                        Process2Category(
                            name: 'BRIDDLE 2#A BLOWER',
                            current: int.parse(
                                _briddler2ablowerController.text.trim()),
                            remark:
                                _briddler2ablowerControllerRemark.text.trim()),
                        Process2Category(
                            name: 'BRIDDLE 2#B BLOWER',
                            current: int.parse(
                                _briddle2bblowerController.text.trim()),
                            remark:
                                _briddle2bblowerControllerRemark.text.trim()),
                        Process2Category(
                            name: 'RECOILER MOTOR BLOWER',
                            current: int.parse(
                                _recoilerblowerController.text.trim()),
                            remark:
                                _recoilerblowerControllerRemark.text.trim()),
                        Process2Category(
                            name: 'FLATTENER MOTOR',
                            current: int.parse(
                                _flattenerblowerController.text.trim()),
                            remark:
                                _flattenerblowerControllerRemark.text.trim()),
                        Process2Category(
                            name: 'RECOILER LUB MOTOR',
                            current: int.parse(
                                _recoilerlubmotorController.text.trim()),
                            remark:
                                _recoilerlubmotorControllerRemark.text.trim()),
                        Process2Category(
                            name: 'HYDRAULIC PACK WRK & STBY',
                            current: int.parse(
                                _hydraulic_power_packController.text.trim()),
                            remark: _hydraulic_power_packControllerRemark.text
                                .trim()),
                        Process2Category(
                            name: 'HYDRAULIC RECIRCULATIONS',
                            current: int.parse(
                                _hydraulic_recirculationController.text.trim()),
                            remark: _hydraulic_recirculationControllerRemark
                                .text
                                .trim()),
                        Process2Category(
                            name: 'WELDER MOTOR',
                            current:
                                int.parse(_weldermotorController.text.trim()),
                            remark: _weldermotorControllerRemark.text.trim()),
                        Process2Category(
                            name: 'SCRAP BALLER MOTOR',
                            current:
                                int.parse(_scrap_ballerController.text.trim()),
                            remark: _scrap_ballerControllerRemark.text.trim()),
                        Process2Category(
                            name: 'UNCOILER LUB MOTOR',
                            current:
                                int.parse(_unc_lub_motorController.text.trim()),
                            remark: _unc_lub_motorControllerRemark.text.trim())
                      ];
                      // Create a new entry with the categories and current timestamp
                      final newEntry = Process2Entry(
                          categories: categories, lastUpdate: DateTime.now());

                      setState(() {
                        process2data.process2DataList.add(newEntry);
                      });

                      //Save the data
                      await process2data.saveSubprocess2Data();
                      // Create a new notification
                      final newNotification = NotificationModel(
                          title: 'New Entry Saved',
                          description: ' An entry has been saved and Submitted',
                          timestamp: DateTime.timestamp(),
                          type: NotificationType.LogsCollected);

                      // Add the new notification to the list
                      setState(() {
                        _sampleNotifications.add(newNotification);
                        saveNotificationsToFile(_sampleNotifications);
                      });
                    },
                    child: const Text('Save and Submit All'))
              ],
            )
          ]),
        ),
      ),
    );
  }
}
