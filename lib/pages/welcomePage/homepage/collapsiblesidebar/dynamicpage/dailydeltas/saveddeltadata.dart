import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SavedTablesPage extends StatefulWidget {
  final String subDeltaName;

  const SavedTablesPage({Key? key, required this.subDeltaName})
      : super(key: key);

  @override
  _SavedTablesPageState createState() => _SavedTablesPageState();
}

class _SavedTablesPageState extends State<SavedTablesPage> {
  List<Map<String, dynamic>> _savedTables = [];
  Map<String, List<dynamic>> _groupedColumn2Data = {};
  Map<String, List<dynamic>> _groupedColumn4Data = {};

  @override
  void initState() {
    super.initState();
    _loadSavedTables();
  }

  Future<void> _loadSavedTables() async {
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

  Widget _buildTableCard(Map<String, dynamic> tableData) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved on: ${tableData['timestamp']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: tableData['columnLabels'].map<Widget>((label) {
                    return TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(label,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
                ...tableData['tableData'].map<TableRow>((row) {
                  return TableRow(
                    children: row.map<Widget>((cell) {
                      return TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Text(cell.toString()),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
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
                        child: Text('Timestamp',
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
                        child: Text('Timestamp',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Tables for ${widget.subDeltaName}'),
      ),
      body: _savedTables.isEmpty
          ? Center(child: Text('No saved tables found.'))
          : ListView.builder(
              itemCount: _savedTables.length,
              itemBuilder: (context, index) {
                return _buildTableCard(_savedTables[index]);
              },
            ),
    );
    /*
     


            */
  }
}
