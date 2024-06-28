import 'package:collector/pages/process_1/subprocess_5/subprocess_data_display.dart';
import 'package:flutter/material.dart';

class SubProcess5Page1_NP extends StatelessWidget {
  const SubProcess5Page1_NP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
        TextButton(child:const Text('TLL CROWNING') ,onPressed: (){

          
        },)
        ,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('READINGS')),
              
              


            ], rows: const [
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
            const SizedBox(
              height: 20,
            ),
            // Add buttons for additonal functionality

             ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Subprocess5DataDisplay()));
                    },
                    child: Text('View saved data')),
          ]),
        ),
      ),
    );
  }
}
