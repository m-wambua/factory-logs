import 'package:flutter/material.dart';

class SubProcess3Page4 extends StatelessWidget {
  const SubProcess3Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subprocess 3'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('Parameter')),
              DataColumn(label: Text('Value 1')),
              DataColumn(label: Text('Value 2')),
              DataColumn(label: Text('Remarks'))
              


            ], rows: [
              // Add rows or data entry
             DataRow(cells: [
                DataCell(
                  TextButton(child: const Text('Parameter 1'),onPressed: () {
                    
                  },)
                  ),
                const DataCell(TextField()),
                const DataCell(TextField()),
                const DataCell(TextField())
              ]),
              //Add more rows as needed

              // Add rows or data entry
             DataRow(cells: [
                DataCell(
                  TextButton(child: const Text('Parameter 1'),onPressed: () {
                    
                  },)
                  ),
                const DataCell(TextField()),
                const DataCell(TextField()),
                const DataCell(TextField())
              ]),
              // Add rows or data entry
            DataRow(cells: [
                DataCell(
                  TextButton(child: const Text('Parameter 1'),onPressed: () {
                    
                  },)
                  ),
                const DataCell(TextField()),
                const DataCell(TextField()),
                const DataCell(TextField())
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: const Text('Parameter 1'),onPressed: () {
                    
                  },)
                  ),
                const DataCell(TextField()),
                const DataCell(TextField()),
                const DataCell(TextField())
              ]),
              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: const Text('Parameter 1'),onPressed: () {
                    
                  },)
                  ),
                const DataCell(TextField()),
                const DataCell(TextField()),
                const DataCell(TextField())
              ]),
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
