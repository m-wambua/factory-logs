import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_1_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_2_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_3_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_4_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_5_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_6_details_page1.dart';
import 'package:flutter/material.dart';

class SavedValues {
  String ltmotor1 = '';
  String ctmotor1 = '';
  String hoistmotor1 = '';

  String ltmotor2 = '';
  String ctmotor2 = '';
  String hoistmotor2 = '';
}

SavedValues savedValues = SavedValues();

class SubProcess3Page2 extends StatefulWidget {
  const SubProcess3Page2({super.key});

  @override
  State<SubProcess3Page2> createState() => _SubProcess3Page2State();
}

class _SubProcess3Page2State extends State<SubProcess3Page2> {
  final TextEditingController _ltmotor1Controller1 = TextEditingController();
  final TextEditingController _ctmotorController1 = TextEditingController();
  final TextEditingController _hoistmotorController1 = TextEditingController();

  final TextEditingController _ltmotor1Controller2 = TextEditingController();
  final TextEditingController _ctmotorController2 = TextEditingController();
  final TextEditingController _hoistmotorController2 = TextEditingController();
  @override
  void initState() {
    super.initState();

    _ltmotor1Controller1.text = savedValues.ltmotor1;
    _ctmotorController1.text = savedValues.ctmotor1;
    _hoistmotorController1.text = savedValues.hoistmotor1;

    _ltmotor1Controller2.text = savedValues.ltmotor1;
    _ctmotorController2.text = savedValues.ctmotor2;
    _hoistmotorController2.text = savedValues.hoistmotor2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cranes CCL'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            const Text('SR. NO 2096 4/11'),
            DataTable(columns: const [
              DataColumn(label: Text('Parameter')),
              DataColumn(label: Text(' Rated Current')),
              DataColumn(label: Text('Value ')),
              DataColumn(label: Text('Remarks'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('Long Travel Motors'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details1()));
                  },
                )),
                const DataCell(Text('4.3')),
                DataCell(TextField(
                  controller: _ltmotor1Controller1,
                )),
                const DataCell(TextField())
              ]),
              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('Cross Travel Motors'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details2()));
                  },
                )),
                const DataCell(Text('2.1')),
                DataCell(TextField(controller: _ctmotorController1)),
                const DataCell(TextField())
              ]),
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('Hoist Motor'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details3()));
                  },
                )),
                const DataCell(Text('38/18')),
                DataCell(TextField(
                  controller: _hoistmotorController1,
                )),
                const DataCell(TextField())
              ]),
// Add rows or data entry
            ]),
            const SizedBox(
              height: 20,
            ),
            // Add buttons for additonal functionality
            const Text('SR.NO. 20946 5/11'),
            DataTable(columns: const [
              DataColumn(label: Text('Parameter')),
              DataColumn(label: Text('Rated Current')),
              DataColumn(label: Text('Value ')),
              DataColumn(label: Text('Remarks'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('Long Travel Motors'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details4()));
                  },
                )),
                const DataCell(Text('4.3')),
                DataCell(TextField(
                  controller: _ltmotor1Controller2,
                )),
                const DataCell(TextField())
              ]),
              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('Cross Travel Motors'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details5()));
                  },
                )),
                const DataCell(Text('2.1')),
                DataCell(TextField(
                  controller: _ctmotorController2,
                )),
                const DataCell(TextField())
              ]),
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('Hoist Motors'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details6()));

                  },
                )),
                const DataCell(Text('38/18')),
                DataCell(TextField(
                  controller: _hoistmotorController2,
                )),
                const DataCell(TextField())
              ]),
// Add rows or data entry
            ]),
            const SizedBox(height: 20,),
            ElevatedButton(
                onPressed: () {
                  savedValues.ltmotor1 = _ltmotor1Controller1.text.trim();
                  savedValues.ctmotor1 = _ctmotorController1.text.trim();
                  savedValues.hoistmotor1 = _hoistmotorController1.text.trim();

                  savedValues.ltmotor2 = _ltmotor1Controller2.text.trim();
                  savedValues.ctmotor2 = _ctmotorController2.text.trim();
                  savedValues.hoistmotor2 = _hoistmotorController2.text.trim();
                },
                child: const Text('Save as Draft'))
          ]),
        ),
      ),
    );
  }
}
