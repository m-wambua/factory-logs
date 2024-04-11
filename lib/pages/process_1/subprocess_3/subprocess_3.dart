import 'package:collector/pages/process_1/subprocess_3/subprocess_details/subprocess_1_details_page3.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess_details/subprocess_2_details_page3.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess_details/subprocess_3_details_page3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SavedValues {
  String ltmotor = '';
  String ctmotor = '';
  String hoistmotor = '';
}

SavedValues savedValues = SavedValues();

class SubProcess3Page1 extends StatefulWidget {
  @override
  State<SubProcess3Page1> createState() => _SubProcess3Page1State();
}

class _SubProcess3Page1State extends State<SubProcess3Page1> {
  TextEditingController _ltmotorController = TextEditingController();

  TextEditingController _ctmotorController = TextEditingController();

  TextEditingController _hoistmotorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ltmotorController.text = savedValues.ltmotor;
    _ctmotorController.text = savedValues.ctmotor;
    _hoistmotorController.text = savedValues.hoistmotor;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRANES'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: [
              DataColumn(label: Text('DRIVE/MOTOR')),
              DataColumn(label: Text('RATED')),
              DataColumn(label: Text('DRAWN')),
              DataColumn(label: Text('Remarks'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('L.T MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SubProcess1Page2Details1_3()));
                  },
                )),
                DataCell(Text('4.3')),
                DataCell(TextField(
                  controller: _ltmotorController,
                )),
                DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('C.T MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (contenxt) =>
                                SubProcess1Page2Details2_3()));
                  },
                )),
                DataCell(Text('2.1')),
                DataCell(TextField(
                  controller: _ctmotorController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('HOIST MOTOR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SubProcess1Page2Details3_3()));
                  },
                )),
                DataCell(Text('38/18')),
                DataCell(TextField(
                  controller: _hoistmotorController,
                )),
                DataCell(TextField())
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
            SizedBox(
              height: 20,
            ),

            ElevatedButton(
                onPressed: () {
                  savedValues.ltmotor = _ltmotorController.text.trim();
                  savedValues.ctmotor = _ctmotorController.text.trim();
                  savedValues.hoistmotor = _hoistmotorController.text.trim();
                },
                child: Text('Save as Draft'))
            // Add buttons for additonal functionality
          ]),
        ),
      ),
    );
  }
}
