import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubProcess5Page1_NP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
        TextButton(child:Text('TLL CROWNING') ,onPressed: (){

          
        },)
        ,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: [
              DataColumn(label: Text('READINGS')),
              
              


            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(Text('1')),
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(Text('2')),
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(Text('3')),
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(Text('4')),
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
