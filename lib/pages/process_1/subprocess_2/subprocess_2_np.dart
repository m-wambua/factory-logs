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

class SubProcess2Page1_Np extends StatefulWidget {
  @override
  State<SubProcess2Page1_Np> createState() => _SubProcess2Page1State();
}

class _SubProcess2Page1State extends State<SubProcess2Page1_Np> {
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
              ]),
            ]),
            SizedBox(
              height: 20,
            ),
            // Add buttons for additonal functionality
         
          ]),
        ),
      ),
    );
  }
}
