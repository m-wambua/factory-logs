import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubProcess1Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DRIVES '),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: [
              DataColumn(label: Text('DRIVER/MOTOR CURRENT')),
              DataColumn(label: Text('RATED')),
              DataColumn(label: Text('DRAWN %')),
              DataColumn(label: Text('Remarks'))
              


            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(Text('UNCOILER')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(Text('bRIDDLE ROLL 1')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(Text('BRIDDLE ROLL 2')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(Text('BRIDDLE 2')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(Text('BRIDDLE 3')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(Text('BRIDDLE 4 ROLL 1')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(Text('BRIDDLE 4 ROLL2')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(Text('RECOILER')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(Text('TOP PICK-UP ROLL')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(Text('TOP APPLICATOR ROLL')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(Text('BOTTOM PICK-UP ROLL')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(Text('BOTTOM APPLICATOR ROLL')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(Text('OVEN SECTION A BLOWERS')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(Text('OVEN SECTION B BLOWERS')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(Text('OVEN SECTION C BLOWERS')),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(Text('FUME EXHAUST FAN')),
                DataCell(Text('RATED')),
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
