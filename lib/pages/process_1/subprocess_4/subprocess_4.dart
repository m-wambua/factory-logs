import 'package:collector/pages/process_1/subprocess_4/subprocess_details/subprocess_1_details_page4.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_details/subprocess_2_details_page4.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_details/subprocess_3_details_page4.dart';
import 'package:flutter/material.dart';

class SavedValues {
  String tpr = '';
  String str = '';
  String lrp = '';
}

SavedValues savedValues = SavedValues();

class SubProcess4Page1 extends StatefulWidget {
  const SubProcess4Page1({super.key});

  @override
  State<SubProcess4Page1> createState() => _SubProcess4Page1State();
}

class _SubProcess4Page1State extends State<SubProcess4Page1> {
  final TextEditingController _trpController = TextEditingController();
  final TextEditingController _strController = TextEditingController();
  final TextEditingController _lrpController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Intialize text field with saved values
    _trpController.text = savedValues.tpr;
    _strController.text = savedValues.str;
    _lrpController.text = savedValues.lrp;
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
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                const DataCell(TextField())
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
                const DataCell(TextField())
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
                const DataCell(TextField())
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

            ElevatedButton(
                onPressed: () {
                  savedValues.tpr = _trpController.text.trim();
                  savedValues.lrp = _lrpController.text.trim();
                  savedValues.str = _strController.text.trim();
                },
                child: const Text('Saved as Draft')),
          ]),
        ),
      ),
    );
  }
}
