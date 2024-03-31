import 'package:collector/pages/process_1/subprocess_3/subprocess_details/subprocess_1_details_page3.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess_details/subprocess_2_details_page3.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess_details/subprocess_3_details_page3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubProcess3Page1_NP extends StatelessWidget {
  @override
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
                            builder: (context) =>
                                SubProcess1Page2Details2_3()));
                  },
                )),
               
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
            // Add buttons for additonal functionality
          ]),
        ),
      ),
    );
  }
}
