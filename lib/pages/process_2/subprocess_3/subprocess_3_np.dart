import 'package:collector/pages/process_2/subprocess_3/subprocess_details/subprocess_1_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_3/subprocess_details/subprocess_2_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_3/subprocess_details/subprocess_3_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_3/subprocess_details/subprocess_4_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_3/subprocess_details/subprocess_5_details_page2.dart';
import 'package:collector/pages/process_2/subprocess_3/subprocess_details/subprocess_6_details_page2.dart';
import 'package:flutter/material.dart';

class SubProcess3Page2_np extends StatefulWidget {
  const SubProcess3Page2_np({super.key});

  @override
  State<SubProcess3Page2_np> createState() => _SubProcess3Page2State();
}

class _SubProcess3Page2State extends State<SubProcess3Page2_np> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cranes CCL'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

            //Table for data entry specific to subprocess 1
            const Text('SR. NO 2096 4/11'),
            DataTable(columns: const [
              DataColumn(label: Text('Parameter')),
              
              


            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: const Text('Long Travel Motors'),onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess3Page2Details1()));
                            
                  },)
                  ),
              ]),
              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: const Text('Cross Travel Motors'),onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>const SubProcess3Page2Details2()));
                            
                  },)
                  ),
              ]),
              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: const Text('Hoist Motor'),onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess3Page2Details3()));
                            
                  },)
                  ),
              ]),
// Add rows or data entry
             
            ]),
            const SizedBox(
              height: 20,
            ),
            // Add buttons for additonal functionality
const Text('SR.NO. 20946 5/11'),
            DataTable(columns: const [
              DataColumn(label: Text('Parameter')),
              
              


            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: const Text('Long Travel Motors'),onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess3Page2Details4()));
                            
                  },)
                  ),
              ]),
              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: const Text('Cross Travel Motors'),onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess3Page2Details5()));
                            
                  },)
                  ),
              ]),
              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: const Text('Hoist Motors'),onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubProcess3Page2Details6()));
                            
                  },)
                  ),
              ]),
// Add rows or data entry
             
            ]),
          ]),
        ),
      ),
    );
  }
}
