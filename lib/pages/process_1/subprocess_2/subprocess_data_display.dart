import 'package:collector/pages/process_1/subprocess_2/subprocess2Data.dart';
import 'package:flutter/material.dart';

class SubProcess2DataDisplay extends StatefulWidget {
  const SubProcess2DataDisplay({Key? key}) : super(key: key);

  @override
  _SubProcess2DataDisplayState createState() => _SubProcess2DataDisplayState();
}

class _SubProcess2DataDisplayState extends State<SubProcess2DataDisplay>  {
  final Process2Data proces2data = Process2Data();
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await proces2data.loadSubprocess2Data();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Subprocess Data Display'),
        ),
        body: proces2data.process2DataList.isEmpty
            ? const Center(child: Text('No data available'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Date')),
                    for (var category
                        in proces2data.process2DataList.first.categories)
                      DataColumn(label: Text('${category.name} Current')),
                    // Optionally include  remark columns here
                    // for (var categiry in process2Data.process2DataList.first.categories)
                    //DataColumn(label: Text('${category.name} Remark')
                  ],
                  rows: proces2data.process2DataList.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry.lastUpdate.toString())),
                      for (var category in entry.categories)
                        DataCell(Text('${category.current.toString()}'))
                    ]);
                  }).toList(),
                ),
              ));
  }
}
