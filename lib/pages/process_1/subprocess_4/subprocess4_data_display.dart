import 'package:collector/pages/process_1/subprocess_4/subprocess4Data.dart';
import 'package:flutter/material.dart';

class Subprocess4DataDisplay extends StatefulWidget {
  const Subprocess4DataDisplay({super.key});
  @override
  _Subprocess4DataDisplayState createState() => _Subprocess4DataDisplayState();
}

class _Subprocess4DataDisplayState extends State<Subprocess4DataDisplay> {
  final Process4Data process4data = Process4Data();
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await process4data.loadSubprocess4Data();
    setState(() {
      // Data loaded , trigger a rebuild to display the data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(' Subprocess Data Display'),
        ),
        body: process4data.process4DataList.isEmpty
            ? const Center(
                child: Text(' No data available'),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Date')),
                    for (var category
                        in process4data.process4DataList.first.categories)
                      DataColumn(label: Text('${category.name} Current')),
                    //Optionally include remark columns here
                    // for (var category in process4Data.process4DataList.first.categories)
                    // DataColumn(label: Text('${category.name} Remark'))
                  ],
                  rows: process4data.process4DataList.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry.lastUpdate.toString())),
                      for (var category in entry.categories)
                        DataCell(Text(category.current.toString())),
                      //Optionally include remark cells here
                      //for (var category in entry.categories)
                      // DataCell(Text(category.remark))
                    ]);
                  }).toList(),
                ),
              ));
  }
}
