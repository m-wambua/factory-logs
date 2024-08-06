import 'package:collector/pages/newtrendspage.dart';
import 'package:collector/pages/saveddatapage.dart';
import 'package:collector/pages/subprocesscreator.dart';
import 'package:collector/pages/trends/trendspage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TableLoaderPage extends StatefulWidget {
  final String subprocessName;

  const TableLoaderPage({Key? key, required this.subprocessName})
      : super(key: key);

  @override
  _TableLoaderPageState createState() => _TableLoaderPageState();
}

class _TableLoaderPageState extends State<TableLoaderPage> {
  List<ColumnInfo> _columns = [];
  int _numRows = 0;
  List<List<String>> _tableData = [];

  @override
  void initState() {
    super.initState();
    _loadTableFromPreferences();
  }

  Future<void> _loadTableFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tableJsonString = prefs.getString('${widget.subprocessName}_table');

    if (tableJsonString != null) {
      Map<String, dynamic> tableJson = json.decode(tableJsonString);

      setState(() {
        _columns = (tableJson['columns'] as List<dynamic>).map((columnJson) {
          return ColumnInfo(
            name: columnJson['name'],
            type: ColumnDataType.values[columnJson['type']],
            isFixed: columnJson['isFixed'],
            unit: columnJson['unit'] ?? '',
          );
        }).toList();

        _numRows = tableJson['numRows'] ?? 0;

        _tableData = List<List<String>>.from(
          tableJson['tableData'].map((row) => List<String>.from(row)),
        );
      });
    }
  }

  Future<void> _saveTableAsDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the current timestamp
    String timestamp = DateTime.now().toIso8601String();

    // Build the table JSON with current user-filled data
    Map<String, dynamic> tableJson = {
      'columns': _columns.map((column) {
        return {
          'name': column.name,
          'type': column.type.index,
          'isFixed': column.isFixed,
          'unit': column.unit,
        };
      }).toList(),
      'numRows': _numRows,
      'tableData': _tableData.map((row) {
        return row.map((cell) => cell.toString()).toList();
      }).toList(),
      'timestamp': timestamp,
    };

    // Save the table data as JSON string
    prefs.setString(
        '${widget.subprocessName}_saved_$timestamp', json.encode(tableJson));

    // Display a message indicating that the draft has been saved
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Draft saved successfully!')),
    );
  }

  Future<void> _saveAndNavigateToTrends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the current timestamp
    String timestamp = DateTime.now().toIso8601String();

    // Build the table JSON with current user-filled data
    Map<String, dynamic> tableJson = {
      'columns': _columns.map((column) {
        return {
          'name': column.name,
          'type': column.type.index,
          'isFixed': column.isFixed,
          'unit': column.unit,
        };
      }).toList(),
      'numRows': _numRows,
      'tableData': _tableData.map((row) {
        return row.map((cell) => cell.toString()).toList();
      }).toList(),
      'timestamp': timestamp,
    };

    // Save the table data as JSON string
    prefs.setString(
        '${widget.subprocessName}_saved_$timestamp', json.encode(tableJson));

    // Display a message indicating that the draft has been saved
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Draft saved successfully!')),
    );
    _viewSubmittedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subprocessName),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
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

    return DataTable(
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
                    onPressed: () {},
                    child: Text(_tableData[index][colIndex]),
                  ));
                } else {
                  return DataCell(
                    column.isFixed
                        ? Text(_tableData[index][colIndex])
                        : TextFormField(
                            initialValue: _tableData[index][colIndex],
                            keyboardType: column.type == ColumnDataType.integer
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
    );
  }
}
