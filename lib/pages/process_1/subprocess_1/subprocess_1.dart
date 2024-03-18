import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_1_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_2_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_3_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_4_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_5_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_6_details_page1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SavedValues {
  String uncoiler = '';
  String briddle1A = '';
  String briddle1B = '';
  String briddle2A = '';
  String briddle2B = '';
  String recoiler = '';
}

SavedValues savedValues = SavedValues();

class SubProcess1Page1 extends StatefulWidget {
  @override
  State<SubProcess1Page1> createState() => _SubProcess1Page1State();
}

class _SubProcess1Page1State extends State<SubProcess1Page1> {
  TextEditingController _uncoilerController = TextEditingController();

  TextEditingController _briddle1AController = TextEditingController();

  TextEditingController _briddle1BController = TextEditingController();

  TextEditingController _briddle2AController = TextEditingController();

  TextEditingController _briddle2BController = TextEditingController();

  TextEditingController _recoilerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //Intialize text field with saved values
    _uncoilerController.text = savedValues.uncoiler;
    _briddle1AController.text = savedValues.briddle1A;
    _briddle1BController.text = savedValues.briddle1B;
    _briddle2AController.text = savedValues.briddle2A;
    _briddle2BController.text = savedValues.briddle2B;
    _recoilerController.text = savedValues.recoiler;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subprocess 1'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: [
              DataColumn(label: Text('Drive Motor Current')),
              DataColumn(label: Text('Rated')),
              DataColumn(label: Text('Drawn')),
              DataColumn(label: Text('Remarks'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('UNCOILER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page1Details1()));
                  },
                )),
                DataCell(Text('351')),
                DataCell(TextField(
                  controller: _uncoilerController,
                )),
                DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 1A'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page1Details2()));
                  },
                )),
                DataCell(Text('191')),
                DataCell(TextField(
                  controller: _briddle1AController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 1B'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page1Details3()));
                  },
                )),
                DataCell(Text('375')),
                DataCell(TextField(
                  controller: _briddle1BController,
                )),
                DataCell(TextField())
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 2A'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page1Details4()));
                  },
                )),
                DataCell(Text('375')),
                DataCell(TextField(
                  controller: _briddle2AController,
                )),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 2B'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page1Details5()));
                  },
                )),
                DataCell(Text('191')),
                DataCell(TextField(
                  controller: _briddle2BController,
                )),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('RECOLIER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubProcess1Page1Details6()));
                  },
                )),
                DataCell(Text('351')),
                DataCell(TextField(
                  controller: _recoilerController,
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
                // Update placeholders with entered values

                //Update saved values with values from the text field
                savedValues.uncoiler = _uncoilerController.text.trim();
                savedValues.briddle1A = _briddle1AController.text.trim();
                savedValues.briddle1B = _briddle1BController.text.trim();
                savedValues.briddle2A = _briddle2AController.text.trim();
                savedValues.briddle2B = _briddle2BController.text.trim();
                savedValues.recoiler = _recoilerController.text.trim();
                // Show notification or perform any other action
              },
              child: Text('Save as Draft'),
            ),
          ]),
        ),
      ),
    );
  }
}
