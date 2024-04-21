import 'package:collector/pages/process_2/subprocess_1/subprocess_details/subprocess_10_details_page2_1.dart';
import 'package:collector/pages/process_2/subprocess_1/subprocess_details/subprocess_11_details_page2_1.dart';
import 'package:collector/pages/process_2/subprocess_1/subprocess_details/subprocess_12_details_page2_1.dart';
import 'package:collector/pages/process_2/subprocess_1/subprocess_details/subprocess_14_details_page2_1.dart';
import 'package:collector/pages/process_2/subprocess_1/subprocess_details/subprocess_15_details_page2_1.dart';
import 'package:collector/pages/process_2/subprocess_1/subprocess_details/subprocess_16_details_page2_1.dart';
import 'package:collector/pages/process_2/subprocess_1/subprocess_details/subprocess_7_details_page2_1.dart';
import 'package:collector/pages/process_2/subprocess_1/subprocess_details/subprocess_8_details_page2_1.dart';
import 'package:collector/pages/process_2/subprocess_1/subprocess_details/subprocess_13_details_page2_1.dart';
import 'package:collector/pages/process_2/subprocess_1/subprocess_details/subprocess_9_details_page2_1.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_1_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_2_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_3_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_4_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_5_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_6_details_page2.dart';
import 'package:flutter/material.dart';

class SavedValues {
  String uncoiler = '';
  String briddle1roll1 = '';
  String briddle1roll2 = '';
  String briddle2 = '';
  String briddle3 = '';
  String briddle4roll1 = '';
  String briddle4roll2 = '';
  String recoiler = '';
  String toppickuproll = '';
  String topapplicatorroll = '';
  String bottompickuproll = '';
  String bottomapplicatorroll = '';
  String ovensectionablowers = '';
  String ovensectionbblower = '';
  String ovensectioncblower = '';
  String fumeexhaustfan = '';
}

SavedValues savedValues = SavedValues();

class SubProcess1Page2 extends StatefulWidget {
  const SubProcess1Page2({super.key});

  @override
  State<SubProcess1Page2> createState() => _SubProcess1Page2State();
}

class _SubProcess1Page2State extends State<SubProcess1Page2> {
  final TextEditingController _uncoilerController = TextEditingController();
  final TextEditingController _briddle1roll1Controller = TextEditingController();
  final TextEditingController _briddle1roll2Controller = TextEditingController();
  final TextEditingController _briddle2Controller = TextEditingController();
  final TextEditingController _briddle3Controller = TextEditingController();
  final TextEditingController _briddle4roll1Controller = TextEditingController();
  final TextEditingController _briddler4roll2Controller = TextEditingController();
  final TextEditingController _recoilerController = TextEditingController();
  final TextEditingController _toppickuprollController = TextEditingController();
  final TextEditingController _topapplicatorrollController = TextEditingController();
  final TextEditingController _bottompickuprollController = TextEditingController();
  final TextEditingController _bottomapplicatorrollController =
      TextEditingController();
  final TextEditingController _ovensectionablowerController = TextEditingController();
  final TextEditingController _ovensectionbblowerController = TextEditingController();
  final TextEditingController _ovensectioncblowerController = TextEditingController();
  final TextEditingController _fumeexhaustblowerController = TextEditingController();
  @override
  void initSate() {
    super.initState();
    _uncoilerController.text = savedValues.uncoiler;
    _briddle1roll1Controller.text = savedValues.briddle1roll1;
    _briddle1roll2Controller.text = savedValues.briddle1roll2;
    _briddle2Controller.text = savedValues.briddle2;
    _briddle3Controller.text = savedValues.briddle3;
    _briddle4roll1Controller.text = savedValues.briddle4roll1;
    _briddler4roll2Controller.text = savedValues.briddle4roll2;
    _recoilerController.text = savedValues.recoiler;
    _toppickuprollController.text = savedValues.toppickuproll;
    _topapplicatorrollController.text = savedValues.topapplicatorroll;
    _bottompickuprollController.text = savedValues.bottompickuproll;
    _bottomapplicatorrollController.text = savedValues.bottomapplicatorroll;
    _ovensectionablowerController.text = savedValues.ovensectionablowers;
    _ovensectionbblowerController.text = savedValues.ovensectionbblower;
    _ovensectioncblowerController.text = savedValues.ovensectioncblower;
    _fumeexhaustblowerController.text = savedValues.fumeexhaustfan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DRIVES '),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('DRIVER/MOTOR CURRENT')),
              DataColumn(label: Text('RATED')),
              DataColumn(label: Text('DRAWN %')),
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
                            builder: (context) => const SubProcess1Page2Details1()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _uncoilerController,
                )),
                const DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE ROLL 1'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details2()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _briddle1roll1Controller,
                )),
                const DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE ROLL 2'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details3()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _briddle1roll2Controller,
                )),
                const DataCell(TextField())
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 2'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details4()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _briddle2Controller,
                )),
                const DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 3'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details5()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _briddle3Controller,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 4 ROLL 1'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details6()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _briddle4roll1Controller,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 4 ROLL2'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details7()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _briddler4roll2Controller,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('RECOILER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details8()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _recoilerController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('TOP PICK-UP ROLL'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details9()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _toppickuprollController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('TOP APPLICATOR ROLL'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details10()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _topapplicatorrollController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BOTTOM PICK-UP ROLL'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details11()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _bottompickuprollController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BOTTOM APPLICATOR ROLL'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details12()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _bottomapplicatorrollController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('OVEN SECTION A BLOWERS'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details13()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _ovensectionablowerController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('OVEN SECTION B BLOWERS'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details14()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _ovensectionbblowerController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('OVEN SECTION C BLOWERS'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details15()));
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _ovensectioncblowerController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('FUME EXHAUST FAN'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details16()));
                            
                  },
                )),
                const DataCell(Text('RATED')),
                DataCell(TextField(
                  controller: _fumeexhaustblowerController,
                )),
                const DataCell(TextField())
              ]),
            ]),
            const SizedBox(
              height: 20,
            ),
            // Add buttons for additonal functionality
            ElevatedButton(
                onPressed: () {
                  savedValues.uncoiler = _uncoilerController.text.trim();
                  savedValues.briddle1roll1 =
                      _briddle1roll1Controller.text.trim();
                  savedValues.briddle1roll2 =
                      _briddle1roll2Controller.text.trim();
                  savedValues.briddle2 = _briddle2Controller.text.trim();
                  savedValues.briddle3 = _briddle3Controller.text.trim();
                  savedValues.briddle4roll1 =
                      _briddle4roll1Controller.text.trim();
                  savedValues.briddle4roll2 =
                      _briddler4roll2Controller.text.trim();
                  savedValues.recoiler = _recoilerController.text.trim();
                  savedValues.toppickuproll =
                      _topapplicatorrollController.text.trim();
                  savedValues.topapplicatorroll =
                      _topapplicatorrollController.text.trim();
                  savedValues.bottomapplicatorroll =
                      _bottomapplicatorrollController.text.trim();
                  savedValues.bottompickuproll =
                      _bottompickuprollController.text.trim();
                  savedValues.ovensectionablowers =
                      _ovensectionablowerController.text.trim();
                  savedValues.ovensectionbblower =
                      _ovensectionbblowerController.text.trim();
                  savedValues.ovensectioncblower =
                      _ovensectioncblowerController.text.trim();
                  savedValues.fumeexhaustfan =
                      _fumeexhaustblowerController.text.trim();
                },
                child: const Text('Saved as Draft'))
          ]),
        ),
      ),
    );
  }
}
