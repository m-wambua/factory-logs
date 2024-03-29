import 'package:collector/pages/process_1/subprocess_1/subprocess_1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_1_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_10_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_11_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_12_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_1_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_2_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_3_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_4_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_5_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_6_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_7_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_8_details_page2.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_details/subprocess_9_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_1_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_2_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_6_details_page2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SavedValues {
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
}

SavedValues savedValues = SavedValues();

class SubProcess2Page1 extends StatefulWidget {
  @override
  State<SubProcess2Page1> createState() => _SubProcess2Page1State();
}

class _SubProcess2Page1State extends State<SubProcess2Page1> {
  TextEditingController _uncoilerblowerController = TextEditingController();
  TextEditingController _briddle1ablowerController = TextEditingController();
  TextEditingController _briddler1bblowerController = TextEditingController();
  TextEditingController _briddler2ablowerController = TextEditingController();
  TextEditingController _briddle2bblowerController = TextEditingController();
  TextEditingController _recoilerblowerController = TextEditingController();
  TextEditingController _flattenerblowerController = TextEditingController();
  TextEditingController _recoilerlubmotorController = TextEditingController();
  TextEditingController _hydraulic_power_packController =
      TextEditingController();
  TextEditingController _hydraulic_recirculationController =
      TextEditingController();
  TextEditingController _weldermotorController = TextEditingController();
  TextEditingController _scrap_ballerController = TextEditingController();
  TextEditingController _unc_lub_motorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //Initialize text field with saved values
    _uncoilerblowerController.text = savedValues.unc_lub_motor;
    _briddle1ablowerController.text = savedValues.briddle_1a_blower;
    _briddler1bblowerController.text = savedValues.briddler_1b_blower;
    _briddler2ablowerController.text = savedValues.briddle_2a_blower;
    _briddle2bblowerController.text = savedValues.briddle_2b_blower;
    _recoilerblowerController.text = savedValues.recoiler_motor_blower;
    _flattenerblowerController.text = savedValues.flattener_blower;
    _recoilerlubmotorController.text = savedValues.recoiler_lub_motor;
    _hydraulic_power_packController.text = savedValues.hydraulic_power_pack;
    _hydraulic_recirculationController.text =
        savedValues.hydraulic_recirculation;
    _weldermotorController.text = savedValues.welder_motor;
    _scrap_ballerController.text = savedValues.scrap_baller_motor;
    _unc_lub_motorController.text = savedValues.unc_lub_motor;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MCC MOTORS'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            Text('FEEDER MOTORS CURRENT'),
            SizedBox(
              height: 10,
            ),
            DataTable(columns: [
              DataColumn(label: Text('FEEDER MOTORS CURRENT')),
              DataColumn(label: Text('RATED')),
              DataColumn(label: Text('DRAWN')),
              DataColumn(label: Text('Remarks'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('UNCOILER BLOWER MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details2()));
                  },
                )),
                DataCell(Text('6.0')),
                DataCell(TextField(
                  controller: _uncoilerblowerController,
                )),
                DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 1 #A BLOWER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details1_2()));
                 
                  }
                  ,

                )), //BRIDDLE 1 #A BLOWER
                DataCell(Text('2.8')),
                DataCell(TextField(
                  controller: _briddle1ablowerController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDLE 1#B BLOWER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details2_2()));
                 
                  },
                )), //BRIDLE 1#B BLOWER
                DataCell(Text('6.0')),
                DataCell(TextField(
                  controller: _briddler1bblowerController,
                )),
                DataCell(TextField())
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 2#A BLOWER MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details3_2()));
                 
                  },
                )), //BRIDDLE 2#A BLOWER MOTOR
                DataCell(Text('6.1')),
                DataCell(TextField(
                  controller: _briddler2ablowerController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 2#B BLOWER MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details4_2()));
                 
                  },
                )), //BRIDDLE 2#B BLOWER MOTOR
                DataCell(Text('2.8')),
                DataCell(TextField(
                  controller: _briddle2bblowerController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('RECOILER MOTOR BLOWER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details5_2()));
                 
                  },
                )), //RECOILER MOTOR BLOWER
                DataCell(Text('6.0')),
                DataCell(TextField(
                  controller: _recoilerblowerController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('FLATTENER MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details6_2()));
                 
                  },
                )), //FLATTENER MOTOR
                DataCell(Text('20.5')),
                DataCell(TextField(
                  controller: _flattenerblowerController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('REC LUB MOTOR'),
                  onPressed: () {

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details7_2()));
                 
                  },
                )), //REC LUB MOTOR
                DataCell(Text('3.4')),
                DataCell(TextField(
                  controller: _recoilerlubmotorController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('HYD P PACK WRK & STBY'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details8_2()));
                 
                  },
                )), //HYD P PACK WRK & STBY
                DataCell(Text('40.0')),
                DataCell(TextField(
                  controller: _hydraulic_power_packController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('HYDR. RECIRCULATIONS'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details9_2()));
                 
                  },
                )), //HYDR. RECIRCULATIONS
                DataCell(Text('3.4')),
                DataCell(TextField(
                  controller: _hydraulic_recirculationController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('WELDER MOTOR'),
                  onPressed: () {

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details10_2()));
                 
                  },
                )), //WELDER MOTOR
                DataCell(Text('5.37/3.45')),
                DataCell(TextField(
                  controller: _weldermotorController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('SCRAP BALLER MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details11_2()));
                 
                  },
                )), //SCRAP BALLER MOTOR
                DataCell(Text('39.5')),
                DataCell(TextField(
                  controller: _scrap_ballerController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('UNC. LUB MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page2Details12_2()));
                  },
                )), //UNC. LUB MOTOR
                DataCell(Text('3.4')),
                DataCell(TextField(
                  controller: _unc_lub_motorController,
                )),
                DataCell(TextField())
              ]),
            ]),
            SizedBox(
              height: 20,
            ),
            // Add buttons for additonal functionality
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
                  savedValues.welder_motor = _weldermotorController.text.trim();
                  savedValues.scrap_baller_motor =
                      _scrap_ballerController.text.trim();
                  savedValues.unc_lub_motor =
                      _unc_lub_motorController.text.trim();
                },
                child: Text('Save as Draft'))
          ]),
        ),
      ),
    );
  }
}
