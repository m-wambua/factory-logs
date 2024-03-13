import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubProcess1Page1 extends StatelessWidget {
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
                DataCell(
                  TextButton(child: Text('UNCOILER'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('351')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('BRIDDLE 1A') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('191')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('BRIDDLE 1B') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('375')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('BRIDDLE 2A') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('375')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('BRIDDLE 2B'),onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('191')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('UNCOLIER') ,onPressed: () {
                    
                  },)
                  ),
                DataCell(Text('351')),
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
