import 'package:flutter/material.dart';

class SubProcess6Page1_NP extends StatelessWidget {
  const SubProcess6Page1_NP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tensions'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('TENSIONS')),
              


            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:const Text('TLL') ,onPressed: () {
                    
                  },)
                  ),
                
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:const Text('RECOILER') ,onPressed: () {
                    
                  },)
                  ),
                             ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:const Text('UNCOILER') ,onPressed: () {
                    
                  },)
                  ),
               
              ]),
// Add rows or data entry
/*
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('Parameter 1') ,onPressed: () {
                    
                  },)
                  ),
                
              ]),
*/
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
          ]),
        ),
      ),
    );
  }
}
