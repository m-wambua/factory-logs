import 'package:collector/pages/process_1/subprocess_1/subprocess1Data.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
//import 'package:your_package_name_here/process1_data.dart'; // Import your Process1eData class

/*
class SubProcessDataDisplay extends StatefulWidget {
  const SubProcessDataDisplay({Key? key}) : super(key: key);

  @override
  _SubProcessDataDisplayState createState() => _SubProcessDataDisplayState();
}

class _SubProcessDataDisplayState extends State<SubProcessDataDisplay> {
  final Process1Data process1Data = Process1Data();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await process1Data.loadMaintenanceDetails();
    setState(() {
      // Data loaded, trigger a rebuild to display the data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subprocess Data Display'),
      ),
      body: process1Data.process1DataList.isEmpty
          ? const Center(child: Text('No data available'))
          : ListView.builder(
              itemCount: process1Data.process1DataList.length,
              itemBuilder: (context, index) {
                final entry = process1Data.process1DataList[index];
                return Card(
                  margin: const EdgeInsets.all(10.0),
                  child: ListTile(
                    title: Text('Entry ${index + 1}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var category in entry.categories)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${category.name} Remark: ${category.remark}'),
                              Text('${category.name} Current: ${category.current}'),
                            ],
                          ),
                        Text('Last Update: ${entry.lastUpdate}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
*/

import 'package:flutter/material.dart';

class SubProcessDataDisplay extends StatefulWidget {
  const SubProcessDataDisplay({Key? key}) : super(key: key);

  @override
  _SubProcessDataDisplayState createState() => _SubProcessDataDisplayState();
}

class _SubProcessDataDisplayState extends State<SubProcessDataDisplay> {
  final Process1Data process1Data = Process1Data();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await process1Data.loadSubprocess1Data();
    setState(() {
      // Data loaded, trigger a rebuild to display the data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subprocess Data Display'),
      ),
      body: process1Data.process1DataList.isEmpty
          ? const Center(child: Text('No data available'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Date')),
                  for (var category
                      in process1Data.process1DataList.first.categories)
                    DataColumn(label: Text('${category.name} Current')),
                  // Optionally include remark columns here
                  // for (var category in process1Data.process1DataList.first.categories)
                  //   DataColumn(label: Text('${category.name} Remark')),
                ],
                rows: process1Data.process1DataList.map((entry) {
                  return DataRow(cells: [
                    DataCell(Text(entry.lastUpdate.toString())),
                    for (var category in entry.categories)
                      DataCell(Text('${category.current.toString()}')),
                    // Optionally include remark cells here
                    // for (var category in entry.categories)
                    //   DataCell(Text(category.remark)),
                  ]);
                }).toList(),
              ),
            ),
    );
  }

}
