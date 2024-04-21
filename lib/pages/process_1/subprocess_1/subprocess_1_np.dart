import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_1_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_2_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_3_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_4_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_5_details_page1.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_details/subprocess_6_details_page1.dart';
import 'package:flutter/material.dart';


class SubProcess1Page1_Np extends StatefulWidget {
  const SubProcess1Page1_Np({super.key});

  @override
  State<SubProcess1Page1_Np> createState() => _SubProcess1Page1State();
}

class _SubProcess1Page1State extends State<SubProcess1Page1_Np> {
  
  @override
  

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subprocess 1'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('Drive Motor Current')),
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('UNCOILER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details1()));
                  },
                )),
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 1A'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details2()));
                  },
                )),
               
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 1B'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details3()));
                  },
                )),
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 2A'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details4()));
                  },
                )),
               
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('BRIDDLE 2B'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details5()));
                  },
                )),
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('RECOLIER'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1Details6()));
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
