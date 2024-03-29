import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubProcess6Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subprocess 6'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: [
              DataColumn(label: Text('TENSIONS')),
              DataColumn(label: Text('TIMING 1')),
              DataColumn(label: Text('TIMING 2')),
              DataColumn(label: Text('TIMING 3'))
              


            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('TLL') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(TextField()),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('RECOILER') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(TextField()),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('UNCOILER') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(TextField()),
                DataCell(TextField()),
                DataCell(TextField())
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('Parameter 1') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(TextField()),
                DataCell(TextField()),
                DataCell(TextField())
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
