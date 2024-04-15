import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubProcess7Page1_NP extends StatefulWidget {
  @override
  State<SubProcess7Page1_NP> createState() => _SubProcess7Page1State();
}

class _SubProcess7Page1State extends State<SubProcess7Page1_NP> {


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currents'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: [
              DataColumn(label: Text('Parameter')),
             
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('UNCOILER'),
                  onPressed: () {},
                )),
                
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 1A'),
                  onPressed: () {},
                )),
                
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 1B'),
                  onPressed: () {},
                )),
                
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 2A'),
                  onPressed: () {},
                )),
                
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 2B'),
                  onPressed: () {},
                )),
                
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('RECOILER'),
                  onPressed: () {},
                )),
                
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
