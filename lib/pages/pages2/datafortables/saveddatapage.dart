import 'dart:io';
import 'package:collector/pages/pages2/datafortables/lastEntrySaver.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:collector/pages/pages2/subprocesscreator.dart';
import 'package:path_provider/path_provider.dart';

class SavedDataPage extends StatefulWidget {
  final String subprocessName;

  const SavedDataPage({Key? key, required this.subprocessName})
      : super(key: key);

  @override
  _SavedDataPageState createState() => _SavedDataPageState();
}

class _SavedDataPageState extends State<SavedDataPage> {
  List<Map<String, dynamic>> _savedDataList = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataDirFile =
        Directory('${savedDataDir.path}/${widget.subprocessName}_saved');

    if (!await savedDataDirFile.exists()) {
      // Handle case where directory doesn't exist
      return; // Or create the directory if needed
    }

    final files = savedDataDirFile.listSync();

    List<Map<String, dynamic>> tempList = [];

    for (var file in files) {
      if (file is File) {
        try {
          final jsonString = await file.readAsString();
          final tableJson = json.decode(jsonString) as Map<String, dynamic>;

          // Verify that the tableJson contains all necessary keys
          if (tableJson.containsKey('columns') &&
              tableJson.containsKey('numRows') &&
              tableJson.containsKey('tableData') &&
              tableJson.containsKey('timestamp')) {
            tempList.add(tableJson);
          }
        } catch (e) {
          print('Error decoding JSON: $e');
        }
      }
    }

    setState(() {
      _savedDataList = tempList;
    });
  }

  // Method to get the last entered data and timestamp
  Map<String, dynamic>? getLastEnteredData() {
    if (_savedDataList.isNotEmpty) {
      return _savedDataList.last;
    }
    return null;
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
            Text('Saved ${widget.subprocessName} Data'),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _savedDataList.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> savedData = _savedDataList[index];

          String timestamp = savedData['timestamp'] ?? 'Unknown';
          List<dynamic> columnsJson = savedData['columns'] ?? [];
          List<dynamic> tableDataJson = savedData['tableData'] ?? [];

          List<ColumnInfo> columns = columnsJson.map((columnJson) {
            return ColumnInfo(
              name: columnJson['name'],
              type: ColumnDataType.values[columnJson['type']],
              isFixed: columnJson['isFixed'],
              unit: columnJson['unit'] ?? '',
            );
          }).toList();

          List<List<String>> tableData = tableDataJson.map((row) {
            return (row as List<dynamic>)
                .map((cell) => cell.toString())
                .toList();
          }).toList();

          // Ensure columns are not empty
          if (columns.isEmpty) {
            return Card(
              child: ListTile(
                title: Text('Saved on: $timestamp'),
                subtitle: Text('No columns available for this entry.'),
              ),
            );
          }

          return Card(
            color: index == _savedDataList.length - 1
                ? Colors.blueAccent // highlight the last entered data's card
                : null,
            child: ListTile(
              title: Text('Saved on: $timestamp'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DataTable(
                    columns: columns.map((column) {
                      return DataColumn(
                        label: Text(
                          '${column.name}${column.unit.isNotEmpty ? ' (${column.unit})' : ''}',
                        ),
                      );
                    }).toList(),
                    rows: List<DataRow>.generate(
                      tableData.length,
                      (rowIndex) {
                        return DataRow(
                          cells: List<DataCell>.generate(
                            columns.length,
                            (colIndex) {
                              return DataCell(
                                Text(tableData[rowIndex][colIndex]),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
