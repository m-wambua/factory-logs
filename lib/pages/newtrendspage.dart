import 'package:collector/pages/subprocesscreator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TrendsPage2 extends StatefulWidget {
  final String subprocessName;

  const TrendsPage2({Key? key, required this.subprocessName}) : super(key: key);

  @override
  _TrendsPage2State createState() => _TrendsPage2State();
}

class _TrendsPage2State extends State<TrendsPage2> {
  List<String> _headers = [];
  List<List<String>> _summaryData = [];

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

    _processData(tempList);
  }

  void _processData(List<Map<String, dynamic>> dataList) {
    List<String> headers = [];
    List<List<String>> summaryData = [];

    for (var savedData in dataList) {
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

      // Extract headers from the first column of each table
      if (headers.isEmpty) {
        headers.add('Timestamp');
        headers.addAll(
            columns.where((col) => !col.isFixed).map((col) => col.name));
      }

      for (var row in tableDataJson) {
        List<String> newRow = [timestamp];
        for (int i = 0; i < columns.length; i++) {
          if (!columns[i].isFixed) {
            newRow.add((row[i] ?? 'NaN').toString());
          }
        }
        // Ensure the row has the same number of cells as headers
        while (newRow.length < headers.length) {
          newRow.add(''); // Add empty cells if needed
        }
        summaryData.add(newRow);
      }
    }

    setState(() {
      _headers = headers;
      _summaryData = summaryData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary Table'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: _headers.isNotEmpty
            ? DataTable(
                columns: _headers.map((header) {
                  return DataColumn(
                    label: Text(header),
                  );
                }).toList(),
                rows: _summaryData.map((row) {
                  return DataRow(
                    cells: row.map((cell) {
                      return DataCell(
                        Text(cell),
                      );
                    }).toList(),
                  );
                }).toList(),
              )
            : Center(
                child: Text('No data available'),
              ),
      ),
    );
  }
}

/*
import 'package:collector/pages/subprocesscreator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TrendsPage2 extends StatefulWidget {
  final String subprocessName;

  const TrendsPage2({Key? key, required this.subprocessName}) : super(key: key);

  @override
  _TrendsPage2State createState() => _TrendsPage2State();
}

class _TrendsPage2State extends State<TrendsPage2> {
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
*/
