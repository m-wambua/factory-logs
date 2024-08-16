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

  // Function to extract and group data by timestamps
  List<List<String>> extractAndGroupDataByTimestamps() {
    Map<String, List<List<String>>> groupedData = {};

    for (var savedData in _savedDataList) {
      // Extract the timestamp
      String timestamp = savedData['timestamp'] ?? 'Unknown';

      // Extract columns and tableData
      List<dynamic> columnsJson = savedData['columns'] ?? [];
      List<dynamic> tableDataJson = savedData['tableData'] ?? [];

      // Convert columnsJson to List<ColumnInfo>
      List<ColumnInfo> columns = columnsJson.map((columnJson) {
        return ColumnInfo(
          name: columnJson['name'],
          type: ColumnDataType.values[columnJson['type']],
          isFixed: columnJson['isFixed'],
          unit: columnJson['unit'] ?? '',
        );
      }).toList();

      // Find non-fixed integer column indices
      List<int> nonFixedIntegerColumnIndices = columns
          .asMap()
          .entries
          .where((entry) =>
              !entry.value.isFixed &&
              entry.value.type == ColumnDataType.integer)
          .map((entry) => entry.key)
          .toList();

      // Iterate through each row in the tableData
      for (var row in tableDataJson) {
        // Ensure that the row is a List<dynamic> and then map it to a List<String>
        List<String> rowValues = nonFixedIntegerColumnIndices.map((colIndex) {
          return colIndex < (row as List<dynamic>).length
              ? row[colIndex].toString()
              : '';
        }).toList();

        // Add the row values to the grouped data under the appropriate timestamp
        if (!groupedData.containsKey(timestamp)) {
          groupedData[timestamp] = [];
        }
        groupedData[timestamp]!.add(rowValues);
      }
    }

    // Convert the grouped data into a 2D matrix
    List<List<String>> resultMatrix = [];
    groupedData.forEach((timestamp, rows) {
      // Combine rows into a single row per timestamp
      List<String> combinedRow = [timestamp];
      for (var row in rows) {
        combinedRow.addAll(row);
      }
      resultMatrix.add(combinedRow);
    });

    return resultMatrix;
  }

  // Build the table widget
  Widget _buildDataTable() {
    List<List<String>> groupedData = extractAndGroupDataByTimestamps();
    if (groupedData.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    // Extract custom headers from _savedDataList
    List<String> dummyHeaders = [];
    if (_savedDataList.isNotEmpty) {
      var firstSavedData = _savedDataList.first;
      var columnsJson = firstSavedData['columns'] ?? [];

      // Ensure columnsJson is a List<dynamic>
      if (columnsJson is List<dynamic>) {
        dummyHeaders = columnsJson.map((columnJson) {
          // Ensure columnJson is a Map<String, dynamic>
          if (columnJson is Map<String, dynamic>) {
            return (columnJson['name'] ?? '')
                .toString(); // Ensure conversion to String
          }
          return ''; // Return empty string if columnJson is not a Map
        }).toList();
      }

      // Add your custom header name for timestamp
      dummyHeaders.insert(0, 'Timestamp');
    }

    // Ensure that the headers match the number of columns in the data
    if (groupedData.isNotEmpty && groupedData[0].length < dummyHeaders.length) {
      // Adjust the dummyHeaders length to match the data columns
      dummyHeaders = dummyHeaders.sublist(0, groupedData[0].length);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: dummyHeaders.map((header) {
            return DataColumn(
              label: Text(header),
            );
          }).toList(),
          rows: groupedData.map((row) {
            return DataRow(
              cells: row.map((cell) {
                return DataCell(
                  Text(cell),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Data'),
      ),
      body: _buildDataTable(),
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
