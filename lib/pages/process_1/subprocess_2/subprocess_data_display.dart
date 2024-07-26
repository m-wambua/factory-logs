import 'package:collector/pages/process_1/subprocess_2/subprocess2Data.dart';
import 'package:flutter/material.dart';

class SubProcess2DataDisplay extends StatefulWidget {
  const SubProcess2DataDisplay({super.key});

  @override
  _SubProcess2DataDisplayState createState() => _SubProcess2DataDisplayState();
}

class _SubProcess2DataDisplayState extends State<SubProcess2DataDisplay>  {
  final Process2Data process2data = Process2Data();
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await process2data.loadSubprocess2Data();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Subprocess Data Display'),
        ),
        body: process2data.process2DataList.isEmpty
            ? const Center(child: Text('No data available'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Date')),
                    for (var category
                        in process2data.process2DataList.first.categories)
                      DataColumn(label: Text('${category.name} Current')),
                    // Optionally include  remark columns here
                    // for (var categiry in process2Data.process2DataList.first.categories)
                    //DataColumn(label: Text('${category.name} Remark')
                  ],
                  rows: process2data.process2DataList.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry.lastUpdate.toString())),
                      for (var category in entry.categories)
                        DataCell(Text(category.current.toString()))
                    ]);
                  }).toList(),
                ),
              ));
  }
}
