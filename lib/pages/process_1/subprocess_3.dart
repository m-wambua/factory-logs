import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubProcess3Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subprocess 3'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: [
              DataColumn(label: Text('Parameter')),
              DataColumn(label: Text('Value 1')),
              DataColumn(label: Text('Value 2')),
              DataColumn(label: Text('Remarks'))
              


            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(Text('Parameter 1')),
                DataCell(TextField()),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              //Add more rows as needed

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
