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
                DataCell(
                  TextButton(child: Text('UNCOILER'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('BRIDDLE ROLL 1'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('BRIDDLE ROLL 2'),onPressed: () {
                    
                  },)
                  ),
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
                DataCell(
                  TextButton(child: Text('BRIDDLE 3'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('BRIDDLE 4 ROLL 1'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('BRIDDLE 4 ROLL2'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('RECOILER') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('TOP PICK-UP ROLL'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('TOP APPLICATOR ROLL') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('BOTTOM PICK-UP ROLL'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('BOTTOM APPLICATOR ROLL') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('OVEN SECTION A BLOWERS'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('OVEN SECTION B BLOWERS') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('OVEN SECTION C BLOWERS'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('RATED')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('FUME EXHAUST FAN') ,onPressed: () {
                    
                  },)
                  ),
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
