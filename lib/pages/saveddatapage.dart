import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:collector/pages/subprocesscreator.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    List<Map<String, dynamic>> tempList = [];

    for (String key in keys) {
      if (key.startsWith('${widget.subprocessName}_saved_')) {
        String? tableJsonString = prefs.getString(key);
        if (tableJsonString != null) {
          try {
            // Decode the JSON into a Map
            Map<String, dynamic> tableJson = json.decode(tableJsonString);

            // Verify that the tableJson contains all necessary keys
            if (tableJson.containsKey('columns') &&
                tableJson.containsKey('numRows') &&
                tableJson.containsKey('tableData')) {
              tempList.add(tableJson);
            }
          } catch (e) {
            print('Error decoding JSON: $e');
          }
        }
      }
    }

    setState(() {
      _savedDataList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Data'),
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
