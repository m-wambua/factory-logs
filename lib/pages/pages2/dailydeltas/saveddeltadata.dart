import 'dart:convert';
import 'dart:io';
import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SavedTablesPage extends StatefulWidget {
  final String subDeltaName;

  const SavedTablesPage({super.key, required this.subDeltaName});

  @override
  _SavedTablesPageState createState() => _SavedTablesPageState();
}

class _SavedTablesPageState extends State<SavedTablesPage> {
  List<Map<String, dynamic>> _savedTables = [];
  final Map<String, List<dynamic>> _groupedColumn2Data = {};
  final Map<String, List<dynamic>> _groupedColumn4Data = {};

  @override
  void initState() {
    super.initState();
    _loadSavedTables();
  }

  Future<void> _loadSavedTables() async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataFile =
        File('${savedDataDir.path}/${widget.subDeltaName}_snapshots.json');
    print('$savedDataFile');
    if (await savedDataFile.exists()) {
      final jsonString = await savedDataFile.readAsString();
      final List<dynamic> snapshots = json.decode(jsonString) as List<dynamic>;
      setState(() {
        _savedTables = snapshots.cast<Map<String, dynamic>>();
        _processColumn2Data();
        _processColumn4Data();
        print(_savedTables);
      });
    }
  }

  Widget _buildTableCard(Map<String, dynamic> tableData) {
    // Safely extract units with proper type checking using 'columnUnits' key
    List<String> units = [];
    if (tableData.containsKey('columnUnits')) {
      if (tableData['columnUnits'] is List) {
        units = (tableData['columnUnits'] as List)
            .map((u) => u?.toString() ?? '')
            .toList();
      }
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved on: ${tableData['timestamp']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: List<Widget>.generate(
                    tableData['columnLabels'].length,
                    (index) {
                      final label = tableData['columnLabels'][index] ?? '';
                      final unit = index < units.length ? units[index] : '';

                      return TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            unit.isNotEmpty ? '$label ($unit)' : label,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ...tableData['tableData'].map<TableRow>((row) {
                  return TableRow(
                    children: row.map<Widget>((cell) {
                      return TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
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
      return const Card(
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
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grouped Column 2 Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  for (int i = 0; i <= maxValues; i++)
                    i: i == 0 ? const FixedColumnWidth(150) : const FixedColumnWidth(100),
                },
                children: [
                  TableRow(
                    children: [
                      const TableCell(
                          child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Timestamp',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      for (int i = 1; i <= maxValues; i++)
                        TableCell(
                            child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('Value $i',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    ],
                  ),
                  ..._groupedColumn2Data.entries.map((entry) {
                    return TableRow(
                      children: [
                        TableCell(
                            child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(entry.key),
                        )),
                        for (int i = 0; i < maxValues; i++)
                          TableCell(
                              child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(i < entry.value.length
                                ? entry.value[i].toString()
                                : ''),
                          )),
                      ],
                    );
                  }),
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
      return const Card(
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
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grouped Column 2 Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  for (int i = 0; i <= maxValues; i++)
                    i: i == 0 ? const FixedColumnWidth(150) : const FixedColumnWidth(100),
                },
                children: [
                  TableRow(
                    children: [
                      const TableCell(
                          child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Timestamp',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      )),
                      for (int i = 1; i <= maxValues; i++)
                        TableCell(
                            child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('Value $i',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    ],
                  ),
                  ..._groupedColumn4Data.entries.map((entry) {
                    return TableRow(
                      children: [
                        TableCell(
                            child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(entry.key),
                        )),
                        for (int i = 0; i < maxValues; i++)
                          TableCell(
                              child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(i < entry.value.length
                                ? entry.value[i].toString()
                                : ''),
                          )),
                      ],
                    );
                  }),
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Image.asset(AppAssets.deltalogo),
            ),
            Text('Saved  Tables for ${widget.subDeltaName}'),
          ],
        ),
      ),
      body: _savedTables.isEmpty
          ? const Center(child: Text('No saved tables found.'))
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
