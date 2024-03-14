import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_1_details_page1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  bool get wantKeepAlive => true;

  @override
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
                  onPressed: () {},
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
                  onPressed: () {},
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
                  onPressed: () {},
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
                  onPressed: () {},
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
                  onPressed: () {},
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

                setState(() {
                  _uncoilerController.text = _uncoilerController.text.trim();
                  _briddle1AController.text = _briddle1AController.text.trim();
                  _briddle1BController.text = _briddle1BController.text.trim();
                  _briddle2AController.text = _briddle2AController.text.trim();
                  _briddle2BController.text = _briddle2BController.text.trim();
                  _recoilerController.text = _recoilerController.text.trim();
                });
              },
              child: Text('Save as Draft'),
            ),
          ]),
        ),
      ),
    );
  }
}
