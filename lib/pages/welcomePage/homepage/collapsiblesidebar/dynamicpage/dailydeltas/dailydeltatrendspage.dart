import 'dart:convert';
import 'dart:io';

import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/dailydeltas/subdeltacreatorpage.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

class DailyDeltaTrends extends StatefulWidget {
  final String subDeltaName;
  const DailyDeltaTrends({Key? key, required this.subDeltaName})
      : super(key: key);
  @override
  _DeltaTrendsState createState() => _DeltaTrendsState();
}

class _DeltaTrendsState extends State<DailyDeltaTrends> {
  List<String> _newColumnLabels = ['Timestamp'];
  List<List<String>> _newTableData = [];
  List<Map<String, dynamic>> _savedTables = [];
  Map<String, List<dynamic>> _groupedColumn2Data = {};
  Map<String, List<dynamic>> _groupedColumn4Data = {};
  bool _isLoading = true;
  bool _isColumn2Data = true;
  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    setState(() => _isLoading = true);
    SubDeltaData? loadData = await SubDeltaData.load(widget.subDeltaName);
    if (loadData != null) {
      setState(() {
// Extract unique values from the first column to create new column labels
        Set<String> uniqueEquipment =
            Set<String>.from(loadData.rowsData.map((row) => row[0]));
        _newColumnLabels.addAll(uniqueEquipment);
// Create new table data
        Map<String, Map<String, String>> transformedData = {};
        for (var row in loadData.rowsData) {
          String equipment = row[0];
          String timestamp =
              row[1]; // Assuming timestamp is in the second column
          String value = row[2]; // Assuming the value is in the third column
          if (!transformedData.containsKey(timestamp)) {
            transformedData[timestamp] = {};
          }
          transformedData[timestamp]![equipment] = value;
        }
// Convert transformed data to list format for the table
        transformedData.forEach((timestamp, data) {
          List<String> rowData = [timestamp];
          for (var equipment in _newColumnLabels.skip(1)) {
            rowData.add(data[equipment] ?? '');
          }
          _newTableData.add(rowData);
        });
        _isLoading = false;
      });
    }
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataFile =
        File('${savedDataDir.path}/${widget.subDeltaName}_snapshots.json');

    if (await savedDataFile.exists()) {
      final jsonString = await savedDataFile.readAsString();
      final List<dynamic> snapshots = json.decode(jsonString) as List<dynamic>;
      setState(() {
        _savedTables = snapshots.cast<Map<String, dynamic>>();
        _processColumn2Data();
        _processColumn4Data();
      });
    }
  }

  void _processColumn2Data() {
    for (var table in _savedTables) {
      String timestamp = table['timestamp'];
      dynamic tableData = table['tableData'];

      if (tableData is List) {
        List<dynamic> column2Values = [];
        for (var row in tableData) {
          if (row is List && row.length > 1) {
            column2Values.add(row[1]);
          } else if (row is Map && row.containsKey('1')) {
            column2Values.add(row['1']);
          }
        }
        _groupedColumn2Data[timestamp] = column2Values;
      }
    }
  }

  void _processColumn4Data() {
    for (var table in _savedTables) {
      String timestamp = table['timestamp'];
      dynamic tableData = table['tableData'];

      if (tableData is List) {
        List<dynamic> column4Values = [];
        for (var row in tableData) {
          if (row is List && row.length > 1) {
            column4Values.add(row[3]);
          } else if (row is Map && row.containsKey('3')) {
            column4Values.add(row['3']);
          }
        }
        _groupedColumn4Data[timestamp] = column4Values;
      }
    }
  }

  Widget _buildGroupedColumn4Table() {
    if (_groupedColumn4Data.isEmpty) {
      return Card(
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No data available'),
        ),
      );
    }

    // Determine the maximum number of values for any timestamp
    int maxValues = _groupedColumn4Data.values
        .map((list) => list.length)
        .reduce((max, length) => length > max ? length : max);

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grouped Column 4 Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  for (int i = 0; i <= maxValues; i++)
                    i: i == 0 ? FixedColumnWidth(150) : FixedColumnWidth(100),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                          child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(_newColumnLabels[0],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      for (int i = 1; i <= maxValues; i++)
                        TableCell(
                            child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Value $i',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    ],
                  ),
                  ..._groupedColumn4Data.entries.map((entry) {
                    return TableRow(
                      children: [
                        TableCell(
                            child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(entry.key),
                        )),
                        for (int i = 0; i < maxValues; i++)
                          TableCell(
                              child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(i < entry.value.length
                                ? entry.value[i].toString()
                                : ''),
                          )),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedColumn2Table() {
    if (_groupedColumn2Data.isEmpty) {
      return Card(
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No data available'),
        ),
      );
    }

    // Determine the maximum number of values for any timestamp
    int maxValues = _groupedColumn2Data.values
        .map((list) => list.length)
        .reduce((max, length) => length > max ? length : max);

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grouped Column 2 Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  for (int i = 0; i <= maxValues; i++)
                    i: i == 0 ? FixedColumnWidth(150) : FixedColumnWidth(100),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                          child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(_newColumnLabels[0],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      for (int i = 1; i <= maxValues; i++)
                        TableCell(
                            child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Value $i',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    ],
                  ),
                  ..._groupedColumn2Data.entries.map((entry) {
                    return TableRow(
                      children: [
                        TableCell(
                            child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(entry.key),
                        )),
                        for (int i = 0; i < maxValues; i++)
                          TableCell(
                              child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(i < entry.value.length
                                ? entry.value[i].toString()
                                : ''),
                          )),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<List<String>> _extractRowsColumn2() {
    if (_groupedColumn2Data.isEmpty) {
      return [];
    }

    List<List<String>> rows = [];
    _groupedColumn2Data.entries.forEach((entry) {
      List<String> rowData = [entry.key];
      for (int i = 0; i < _groupedColumn2Data.values.first.length; i++) {
        rowData.add(i < entry.value.length ? entry.value[i].toString() : '');
      }
      rows.add(rowData);
    });
    return rows;
  }

  List<List<String>> _extractRowsColumn4() {
    if (_groupedColumn4Data.isEmpty) {
      return [];
    }

    List<List<String>> rows = [];
    _groupedColumn4Data.entries.forEach((entry) {
      List<String> rowData = [entry.key];
      for (int i = 0; i < _groupedColumn4Data.values.first.length; i++) {
        rowData.add(i < entry.value.length ? entry.value[i].toString() : '');
      }
      rows.add(rowData);
    });
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.subDeltaName}\'s Trends'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isColumn2Data = true;
                                  });
                                },
                                child: Text('Rolling Entry')),
                            SizedBox(
                              width: 16,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isColumn2Data = false;
                                  });
                                },
                                child: Text('Delta Diffence'))
                          ],
                        ),
                        DataTable(
                          columns: _newColumnLabels
                              .map((label) => DataColumn(label: Text(label)))
                              .toList(),
                          rows: _isColumn2Data
                              ? _extractRowsColumn2().map((rowData) {
                                  return DataRow(
                                    cells: rowData
                                        .map((cellData) =>
                                            DataCell(Text(cellData)))
                                        .toList(),
                                  );
                                }).toList()
                              : _extractRowsColumn4().map((rowData) {
                                  return DataRow(
                                      cells: rowData
                                          .map((cellData) =>
                                              DataCell(Text(cellData)))
                                          .toList());
                                }).toList(),
                        ),
                        _buildGroupedColumn2Table(),
                        _buildGroupedColumn4Table()
                      ],
                    ),
            ],
          ),
        ));
  }
}
