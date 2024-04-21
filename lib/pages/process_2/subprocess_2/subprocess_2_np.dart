import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_1_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_2_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_3_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_4_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_5_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_6_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_7_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_details/subprocess_8_details_page2.dart';
import 'package:flutter/material.dart';

class SubProcess2Page2_np extends StatelessWidget {
  const SubProcess2Page2_np({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCC DRIVES'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('Parameter')),
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('HYDRAULIC POWER PACK'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details1()));
                  },
                )),
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('HYDRAULIC POWER PACK COOLER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details2()));
                  },
                )),
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('COATER EXHAUST FAN'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details3()));
                  },
                )),
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('POST OVEN AIR DRYER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details4()));
                  },
                )),
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('WATER QUENCH TANK COOLING'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details5()));
                  },
                )),
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('WATER QUENCH SPRAY'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details6()));
                  },
                )),
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('EXIT STRIP COOLING'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details7_2_1()));
                  },
                )),
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('UNCOILER VENT FAN'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page2Details8_2_1()));

                  },
                )),
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
