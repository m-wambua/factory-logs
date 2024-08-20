import 'dart:io';

import 'package:collector/pages/subprocesscreator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class TrendsPage2 extends StatefulWidget {
  final String subprocessName;

  const TrendsPage2({Key? key, required this.subprocessName}) : super(key: key);

  @override
  _TrendsPage2State createState() => _TrendsPage2State();
}

class _TrendsPage2State extends State<TrendsPage2> {
  List<Map<String, dynamic>> _savedDataList = [];
  List<ColumnInfo> _columns = [];
  List<List<String>> _tableData = [];
  int _numRows = 0;

  @override
  void initState() {
    super.initState();
    _loadTableFromFile();
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
              tableJson.containsKey('tableData')) {
            tempList.add(tableJson);
          }
        } catch (e) {
          print('Error decoding JSON: $e');
        }
      }
    }

    setState(() {
      _savedDataList = tempList;
      print(_savedDataList);
    });
  }

  Future<void> _loadTableFromFile() async {
    final tableFileName = '${widget.subprocessName}_table.json';
    final documentsDir = await getApplicationDocumentsDirectory();
    final tableFile = File(documentsDir.path + '/$tableFileName');

    if (await tableFile.exists()) {
      try {
        final jsonString = await tableFile.readAsString();
        final tableJson = json.decode(jsonString) as Map<String, dynamic>;

        _columns = (tableJson['columns'] as List<dynamic>)
            .map((columnJson) => ColumnInfo.fromJson(columnJson))
            .toList();
        _numRows = tableJson['numRows'] as int;
        _tableData = (tableJson['tableData'] as List<dynamic>)
            .map((row) => (row as List<dynamic>).cast<String>())
            .toList();
      } catch (error) {
        print('Error loading table from file: $error');
        // Handle error, e.g., show a snackbar or default initialization
      }
    } else {
      // Handle case where no JSON file is found
      Center(child: Text('No Table was Found')); // Default initialization
    }

    setState(() {});
  }

  Widget _buildDummyTable() {
    List<List<String>> groupedData = extractAndGroupDataByTimestamps();
    if (_columns.isEmpty) {
      return Center(child: Text('No data available for dummy table.'));
    }

    // Extract headers from the first column of the original table
    // Identify columns that are both fixed and integer type
    List<int> fixedIntegerColumnIndices = _columns
        .asMap()
        .entries
        .where((entry) =>
            entry.value.isFixed && entry.value.type == ColumnDataType.integer)
        .map((entry) => entry.key)
        .toList();
    print('Fixed Integer Column Indices: $fixedIntegerColumnIndices');

    List<String> dummyHeaders = _tableData.map((row) => row[0]).toList();

    // Add your custom header name
    dummyHeaders.insert(0, 'Time Stamp');

    print(dummyHeaders);

    // Extract values from these columns for each row
    List<String> dummyValues = [];
    for (var row in _tableData) {
      List<String> rowValues = fixedIntegerColumnIndices.map((colIndex) {
        // Handle cases where colIndex might be out of bounds
        return colIndex < row.length ? row[colIndex] : '';
      }).toList();
      dummyValues.add(
          rowValues.join(', ')); // Join values for the row as a single string
    }
    print('Dummy Values: $dummyValues');

    List<int> nonFixedIntegerColumnIndices = _columns
        .asMap()
        .entries
        .where((entry) =>
            !entry.value.isFixed && entry.value.type == ColumnDataType.integer)
        .map((entry) => entry.key)
        .toList();
    print('Non Fixed Integer COlumn: $nonFixedIntegerColumnIndices');

    List<String> loadedDummyValues = [];
    for (var row in _tableData) {
      List<String> rowValues = nonFixedIntegerColumnIndices.map((colIndex) {
        // Handle cases where colIndex might be out of bounds
        return colIndex < row.length ? row[colIndex] : '';
      }).toList();
      loadedDummyValues.add(
          rowValues.join(', ')); // join Valuse for the row as a single string
    }

    print('Loaded Values$loadedDummyValues');

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
                return DataCell(Text(cell));
              }).toList());
            }).toList()),
      ),
    );
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

// Usage example:
  void printGroupedData() {
    List<List<String>> groupedData = extractAndGroupDataByTimestamps();
    for (var row in groupedData) {
      print(row);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Data'),
      ),
      body: _buildDummyTable(),
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
