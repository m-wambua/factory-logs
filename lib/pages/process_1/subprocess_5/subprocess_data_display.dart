import 'package:collector/pages/process_1/subprocess_5/subprocess5Data.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

class Subprocess5DataDisplay extends StatefulWidget {
  const Subprocess5DataDisplay({Key? key}) : super(key: key);
  _Subprocess5DataDisplayState createState() => _Subprocess5DataDisplayState();
}

class _Subprocess5DataDisplayState extends State<Subprocess5DataDisplay> {
  final Process5Data process5data = Process5Data();
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await process5data.loadSubprocess5Data();
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
        body: process5data.process5DataList.isEmpty
            ? const Center(
                child: Text(' No data available'),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Date')),
                    for (var category
                        in process5data.process5DataList.first.categories)
                      DataColumn(label: Text('${category.name} Current'))
                    //Optionally include remark columns here
                    //for (var category in process5Data.process5DataList.first.remark)
                    // DataColumn(label: Text('${category,name} Remark))
                  ],
                  rows: process5data.process5DataList.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry.lastUpdate.toString())),
                      for (var category in entry.categories)
                        DataCell(Text('${category.current.toString()}'))
                      //optionally include remark cells here
                      //for (var category in entry.categories)
                      // DataCell(text(category.remark))
                    ]);
                  }).toList(),
                ),
              ));
  }
}
