import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_1_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_2_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_3_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_4_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_5_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_6_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_7_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_8_details_page2.dart';
import 'package:flutter/material.dart';

class SavedValues {
  String hydraulicpowerpack = '';
  String hydraulicpowerpackcooler = '';
  String coaterexhaustfan = '';
  String postovenairdryer = '';
  String waterquenchcooling = '';
  String waterquenchspray = '';
  String exitstripcooling = '';
  String uncoilerventfan = '';
}

SavedValues savedValues = SavedValues();

class SubProcess2Page2 extends StatefulWidget {
  const SubProcess2Page2({super.key});

  @override
  State<SubProcess2Page2> createState() => _SubProcess2Page2State();
}

class _SubProcess2Page2State extends State<SubProcess2Page2> {
  final TextEditingController _hydraulicpowerpackController = TextEditingController();
  final TextEditingController _hydraulicpowerpackcoolerController =
      TextEditingController();
  final TextEditingController _coaterexhaustfanController = TextEditingController();
  final TextEditingController _postovenairdryerController = TextEditingController();
  final TextEditingController _waterquenchtankcoolingController =
      TextEditingController();
  final TextEditingController _waterquenchsprayController = TextEditingController();
  final TextEditingController _exitstripcoolingController = TextEditingController();
  final TextEditingController _uncoilerventfanController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _hydraulicpowerpackController.text = savedValues.hydraulicpowerpack;
    _hydraulicpowerpackcoolerController.text =
        savedValues.hydraulicpowerpackcooler;
    _coaterexhaustfanController.text = savedValues.coaterexhaustfan;
    _postovenairdryerController.text = savedValues.postovenairdryer;
    _waterquenchtankcoolingController.text = savedValues.waterquenchcooling;
    _waterquenchsprayController.text = savedValues.waterquenchspray;
    _exitstripcoolingController.text = savedValues.exitstripcooling;
    _uncoilerventfanController.text = savedValues.uncoilerventfan;
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
            DataTable(columns: const [
              DataColumn(label: Text('Parameter')),
              DataColumn(label: Text('RATED')),
              DataColumn(label: Text('Value 1')),
              DataColumn(label: Text('Remarks'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('HYDRAULIC POWER PACK'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details1()));
                  },
                )),
                const DataCell(TextField()),
                DataCell(TextField(
                  controller: _hydraulicpowerpackController,
                )),
                const DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('HYDRAULIC POWER-PACK COOLER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details2()));
                  },
                )),
                const DataCell(TextField()),
                DataCell(TextField(
                  controller: _hydraulicpowerpackcoolerController,
                )),
                const DataCell(TextField())
              ]),

              // Add rows or data entry
              
// Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('COATER EXHAUST FAN'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details3()));
                  },
                )),
                const DataCell(TextField()),
                DataCell(TextField(
                  controller: _coaterexhaustfanController,
                )),
                const DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('POST OVEN AIR DRYER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details4()));
                  },
                )),
                const DataCell(TextField()),
                DataCell(TextField(
                  controller: _postovenairdryerController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('WATER QUENCH COOLING'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details5()));
                  },
                )),
                const DataCell(TextField()),
                DataCell(TextField(
                  controller: _waterquenchtankcoolingController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('WATER QUENCH SPRAY'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details6()));
                  },
                )),
                const DataCell(TextField()),
                DataCell(TextField(
                  controller: _waterquenchsprayController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('EXIT STRIP COOLING'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details7_2_1()));
                  },
                )),
                const DataCell(TextField()),
                DataCell(TextField(
                  controller: _exitstripcoolingController,
                )),
                const DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('UNCOILER VENT FAN'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details8_2_1()));
                  },
                )),
                const DataCell(TextField()),
                DataCell(TextField(
                  controller: _uncoilerventfanController,
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
                  savedValues.hydraulicpowerpack =
                      _hydraulicpowerpackController.text.trim();
                  savedValues.hydraulicpowerpackcooler =
                      _hydraulicpowerpackcoolerController.text.trim();
                  savedValues.coaterexhaustfan =
                      _coaterexhaustfanController.text.trim();
                  savedValues.exitstripcooling =
                      _exitstripcoolingController.text.trim();
                  savedValues.postovenairdryer =
                      _postovenairdryerController.text.trim();
                  savedValues.uncoilerventfan =
                      _uncoilerventfanController.text.trim();
                  savedValues.waterquenchcooling =
                      _waterquenchtankcoolingController.text.trim();
                  savedValues.waterquenchspray =
                      _waterquenchsprayController.text.trim();
                },
                child: const Text('Saved as Draft'))
          ]),
        ),
      ),
    );
  }
}
