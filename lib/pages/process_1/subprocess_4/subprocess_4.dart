import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubProcess4Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TLL POSITIONS [MM]'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: [
              DataColumn(label: Text('MOTOR')),
              DataColumn(label: Text('RATED')),
              DataColumn(label: Text('DRAWN')),
              DataColumn(label: Text('Remarks'))
              


            ], rows: [
              // Add rows or data entry

              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('TPR'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('  ')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),
              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('S.T.R'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('  ')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('LRP') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('  ')),
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
