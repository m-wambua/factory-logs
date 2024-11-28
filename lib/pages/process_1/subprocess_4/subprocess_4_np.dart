import 'package:collector/pages/process_1/subprocess_4/subprocess4_data_display.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_details/subprocess_1_details_page4.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_details/subprocess_2_details_page4.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_details/subprocess_3_details_page4.dart';
import 'package:flutter/material.dart';

class SubProcess4Page1_NP extends StatelessWidget {
  const SubProcess4Page1_NP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TLL POSITIONS [MM]'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('MOTOR')),
            ], rows: [
              // Add rows or data entry

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('TPR'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page4Details1_4()));
                  },
                )),
              ]),
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('S.T.R'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page4Details2_4()));
                  },
                )),
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('LRP'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubProcess1Page4Details3_4()));
                  },
                )),
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
            const SizedBox(
              height: 20,
            ),
            // Add buttons for additonal functionality
             ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Subprocess4DataDisplay()));
                    },
                    child: const Text('View saved data')),
          ]),
        ),
      )
    );
  }
}
