import 'package:collector/pages/process_1/subprocess_3/subprocess3Data.dart';
import 'package:flutter/material.dart';

class Subprocess3DataDisplay extends StatefulWidget {
  const Subprocess3DataDisplay({super.key});
  @override
  _Subprocess3DataDisplayState createState() => _Subprocess3DataDisplayState();
}

class _Subprocess3DataDisplayState extends State<Subprocess3DataDisplay> {
  final Process3Data process3data = Process3Data();
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await process3data.loadSubproecc3Data();
    setState(() {
      // Data loaded, trigger a rebuild to display the data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(' Subprocess Data Display'),
        ),
        body: process3data.process3DataList.isEmpty
            ? const Center(
                child: Text('No data available'),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Date')),
                    for (var category
                        in process3data.process3DataList.first.categories)
                      DataColumn(label: Text('${category.name} Current')),
                    // Optionally include remark columns here
                    // for (var category in process3Data.process3DataList.first.categories)
                    //DataColumn(label: Text(${category.name} Remark))
                  ],
                  rows: process3data.process3DataList.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry.lastUpdate.toString())),
                      for (var category in entry.categories)
                        DataCell(Text(category.current.toString())),
                      //Optionally include remar cells here
                      //for (var category in entry.categories)
                      // DataCell(Text(category.remark)),
                    ]);
                  }).toList(),
                ),
              ));
  }
}
