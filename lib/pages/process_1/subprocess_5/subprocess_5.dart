import 'package:flutter/material.dart';

class SavedValues {
  String pos_1 = '';
  String pos_2 = '';
  String pos_3 = '';
  String pos_4 = '';
}

SavedValues savedValues = SavedValues();

class SubProcess5Page1 extends StatefulWidget {
  const SubProcess5Page1({super.key});

  @override
  State<SubProcess5Page1> createState() => _SubProcess5Page1State();
}

class _SubProcess5Page1State extends State<SubProcess5Page1> {
  final TextEditingController _pos_1Controller = TextEditingController();
  final TextEditingController _pos_2Controller = TextEditingController();
  final TextEditingController _pos_3Controller = TextEditingController();
  final TextEditingController _pos_4Controller = TextEditingController();
  //TextEditingController _pos_5Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pos_1Controller.text = savedValues.pos_1;
    _pos_2Controller.text = savedValues.pos_2;
    _pos_3Controller.text = savedValues.pos_3;
    _pos_4Controller.text = savedValues.pos_4;
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
                const DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                const DataCell(Text('2')),
                const DataCell(Text(' ')),
                DataCell(TextField(
                  controller: _pos_2Controller,
                )),
                const DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                const DataCell(Text('3')),
                const DataCell(Text(' ')),
                DataCell(TextField(
                  controller: _pos_3Controller,
                )),
                const DataCell(TextField())
              ]),
// Add rows or data entry
              DataRow(cells: [
                const DataCell(Text('4')),
                const DataCell(Text(' ')),
                DataCell(TextField(
                  controller: _pos_4Controller,
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
              */
            ]),
            const SizedBox(
              height: 20,
            ),
            // Add buttons for additonal functionality
            ElevatedButton(
                onPressed: () {
                  savedValues.pos_1 = _pos_1Controller.text.trim();
                  savedValues.pos_2 = _pos_2Controller.text.trim();
                  savedValues.pos_3 = _pos_3Controller.text.trim();
                  savedValues.pos_4 = _pos_4Controller.text.trim();
                },
                child: const Text('Saved as Draft'))
          ]),
        ),
      ),
    );
  }
}
