import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/equipmentmenu.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/datafortables/newtrendspage.dart';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/datafortables/saveddatapage.dart';
import 'package:collector/pages/welcomePage/homepage/menubaritems/subprocesscreator.dart';
import 'package:collector/pages/trends/trendspage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TableLoaderPage extends StatefulWidget {
  final String subprocessName;
  final Function(NotificationModel) onNotificationAdded;
  const TableLoaderPage(
      {Key? key,
      required this.subprocessName,
      required this.onNotificationAdded})
      : super(key: key);

  @override
  _TableLoaderPageState createState() => _TableLoaderPageState();
}

class _TableLoaderPageState extends State<TableLoaderPage> {
  List<ColumnInfo> _columns = [];

  List<List<String>> _tableData = [];
  int _numRows = 0;
  List<List<String>> _additionalRows = [];
  List<Map<String, dynamic>> _savedDataList = [];

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

  Future<void> _saveTableAsDraft() async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataDirFile =
        Directory('${savedDataDir.path}/${widget.subprocessName}_saved');

    // Create the directory if it doesn't exist
    await savedDataDirFile.create(recursive: true);

    // Get the current timestamp
    String timestamp = DateTime.now().toIso8601String();

    // Build the table JSON with current user-filled data
    Map<String, dynamic> tableJson = {
      'columns': _columns.map((column) => column.toJson()).toList(),
      'numRows': _numRows,
      'tableData': _tableData
          .map((row) => row.map((cell) => cell.toString()).toList())
          .toList(),
      'timestamp': timestamp,
    };

    final fileName = '${savedDataDirFile.path}/draft_$timestamp.json';

    try {
      await File(fileName).writeAsString(json.encode(tableJson));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Draft saved successfully!')),
      );
    } catch (error) {
      print('Error saving table as draft: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving draft!')),
      );
    }
  }

  Future<void> _saveAndNavigateToTrends() async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataDirFile =
        Directory('${savedDataDir.path}/${widget.subprocessName}_saved');

    // Create the directory if it doesn't exist
    await savedDataDirFile.create(recursive: true);

    // Get the current timestamp
    String timestamp = DateTime.now().toIso8601String();

    // Build the table JSON with current user-filled data
    Map<String, dynamic> tableJson = {
      'columns': _columns.map((column) => column.toJson()).toList(),
      'numRows': _numRows,
      'tableData': _tableData
          .map((row) => row.map((cell) => cell.toString()).toList())
          .toList(),
      'timestamp': timestamp,
    };

    final fileName = '${savedDataDirFile.path}/data_$timestamp.json';

    try {
      await File(fileName).writeAsString(json.encode(tableJson));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved successfully!')),
      );
      _viewSubmittedData(); // Navigate to trends screen
    } catch (error) {
      print('Error saving table data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data!')),
      );
    }
    final newNotification = NotificationModel(
        title: 'A New Entry has been saved',
        description:
            'A New Entry has been Logged and Saved at ${widget.subprocessName}',
        timestamp: DateTime.now(),
        type: NotificationType.LogsCollected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subprocessName),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDataTable(),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _saveTableAsDraft,
                  child: Text('Save as Draft'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _viewSavedData,
                  child: Text('View Saved Data'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _saveAndNavigateToTrends,
                  child: Text('Save and Submit'),
                ),
              ],
            ),
            SizedBox(height: 20),
            // _buildDummyTable(), // Add dummy table below the main table
          ],
        ),
      ),
    );
  }

  void _viewSavedData() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SavedDataPage(subprocessName: widget.subprocessName)),
    );
  }

  void _viewSubmittedData() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TrendsPage2(subprocessName: widget.subprocessName)));
  }

  Widget _buildDataTable() {
    if (_columns.isEmpty) {
      return Center(child: Text('No columns available.'));
    }

    return Row(
      children: [
        DataTable(
          columns: _columns.map((column) {
            return DataColumn(
              label: Text(
                '${column.name}${column.unit.isNotEmpty ? ' (${column.unit})' : ''}',
              ),
            );
          }).toList(),
          rows: List<DataRow>.generate(
            _numRows,
            (index) {
              return DataRow(
                cells: List<DataCell>.generate(
                  _columns.length,
                  (colIndex) {
                    ColumnInfo column = _columns[colIndex];
                    if (colIndex == 0) {
                      return DataCell(TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        onPressed: () {
                          _showEquipmentMenu(index);
                        },
                        child: Text(
                          _tableData[index][colIndex],
                          style: TextStyle(color: Colors.black),
                        ),
                      ));
                    } else {
                      return DataCell(
                        column.isFixed
                            ? Text(_tableData[index][colIndex])
                            : TextFormField(
                                initialValue: _tableData[index][colIndex],
                                keyboardType:
                                    column.type == ColumnDataType.integer
                                        ? TextInputType.number
                                        : TextInputType.text,
                                onChanged: (value) {
                                  setState(() {
                                    _tableData[index][colIndex] = value;
                                  });
                                },
                              ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 10,
        ),
        //_buildDummyTable()
      ],
    );
  }

  // Method to show equipment menu ( can be customized to your requirements)
  void _showEquipmentMenu(int index) {
    //For now, just show a dialog but this can a different action
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Equipment/ Apparatus Options'),
            content: Text('You Clickec on ${_tableData[index][0]}'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EquipmentMenu(
                                equipmentName: _tableData[index][0])));
                  },
                  child:
                      Text('Navigate to ${_tableData[index][0]}\'s submenu')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
            ],
          );
        });
  }

// Method to build the dummy table
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
}