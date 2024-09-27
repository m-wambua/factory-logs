import 'dart:convert';
import 'dart:io';

import 'package:collector/pages/dailydeltas/dailydeltatrendspage.dart';
import 'package:collector/pages/dailydeltas/subdeltacreatorpage.dart';
import 'package:collector/pages/equipmentmenu.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Assuming you already have SubDeltaData and NotificationModel classes defined

class DeltaTableLoaderPage extends StatefulWidget {
  final String subDeltaName;
  final Function(NotificationModel) onNotificationAdded;

  const DeltaTableLoaderPage({
    Key? key,
    required this.subDeltaName,
    required this.onNotificationAdded,
  }) : super(key: key);

  @override
  _DeltaTableLoaderState createState() => _DeltaTableLoaderState();
}

class _DeltaTableLoaderState extends State<DeltaTableLoaderPage> {
  List<List<TextEditingController>> _controllers = [];
  List<String> _columnUnits = ['', '', '', ''];
  List<String> _columnLabels = [
    'Equipment',
    'Previous',
    'Current',
    'Difference'
  ];
  int _rowCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    SubDeltaData? loadData = await SubDeltaData.load(widget.subDeltaName);
    if (loadData != null) {
      setState(() {
        _columnLabels = loadData.columnLabels;
        _columnUnits = loadData.columnUnits;
        _controllers = loadData.rowsData.map((row) {
          return row.map((cell) => TextEditingController(text: cell)).toList();
        }).toList();
        _rowCount = loadData.rowsData.length;
      });
    }
  }

  Future<void> _saveTableAsDraft() async {
    final savedDataDir = await getApplicationCacheDirectory();
    final savedDataPath = File('${savedDataDir.path}/delta_table_draft.json');
    //Create the directory if it doesn't exist
    await savedDataPath.create(recursive: true);

    //Build the table JSON with current user filled data
  } // Build a table where the first column contains etched TextButtons and the rest are editable fields

  Widget _buildDataTable() {
    if (_controllers.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    return Table(
      border: TableBorder.all(),
      children: List.generate(_rowCount, (rowIndex) {
        return TableRow(
          children: List.generate(_columnLabels.length, (colIndex) {
            return TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: colIndex == 0
                    ? _buildEtchedTextButton(rowIndex)
                    : TextFormField(
                        controller: _controllers[rowIndex][colIndex],
                        keyboardType: colIndex == 0
                            ? TextInputType.text
                            : TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: colIndex == 1
                              ? '300'
                              : colIndex == 2
                                  ? '500'
                                  : '',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (colIndex == 1 || colIndex == 2) {
                            setState(() {
                              _updateDifference(rowIndex);
                            });
                          }
                        },
                        readOnly: colIndex == 3,
                      ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildDataRow(int rowIndex) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: List.generate(
            _columnLabels.length,
            (colIndex) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: colIndex == 0
                    ? _buildEtchedTextButton(
                        rowIndex) // First column as TextButton
                    : TextFormField(
                        controller: _controllers[rowIndex][colIndex],
                        keyboardType: colIndex == 0
                            ? TextInputType.text
                            : TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: colIndex == 1
                              ? '300'
                              : colIndex == 2
                                  ? '500'
                                  : '',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (colIndex == 1 || colIndex == 2) {
                            setState(() {
                              _updateDifference(rowIndex);
                            });
                          }
                        },
                        readOnly: colIndex ==
                            3, // The 'Difference' column is read-only
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to create an etched TextButton in the first column
  Widget _buildEtchedTextButton(int rowIndex) {
    return TextButton(
      onPressed: () {
        // Define the behavior when clicking on the first column's TextButton
        _showEquipmentMenu(rowIndex);
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[200], // Etched background color
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        _controllers[rowIndex][0].text, // Display the equipment name
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  // Method to show equipment menu (can be customized to your requirements)
  void _showEquipmentMenu(int rowIndex) {
    // For now, just show a dialog, but this can be a different action.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Equipment Options'),
          content: Text('You clicked on ${_controllers[rowIndex][0].text}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EquipmentMenu(
                            equipmentName: _controllers[rowIndex][0].text,
                          )),
                );
              },
              child: Text(
                  'Navigate to ${_controllers[rowIndex][0].text}\' submenu '),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _updateDifference(int rowIndex) {
    final previous = double.tryParse(_controllers[rowIndex][1].text) ?? 0;
    final current = double.tryParse(_controllers[rowIndex][2].text) ?? 0;
    final difference = previous - current;
    _controllers[rowIndex][3].text = difference.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Delta Table Loader'),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                // Implement save functionality
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildColumnLabelsRow(),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDataTable(),
                  SizedBox(
                    height: 20,
                  ),
                  _buildButtonRow(context),
                ],
              ),
            )),
          ],
        ));
  }

  Widget _buildButtonRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(onPressed: () {}, child: Text('Save as Draft')),
        TextButton(onPressed: () {}, child: Text('Save and Exit')),
        TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DailyDeltaTrends(subDeltaName: widget.subDeltaName)));
            },
            child: Text('View History'))
      ],
    );
  }

  Widget _buildColumnLabelsRow() {
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: List.generate(
              4,
              (index) => Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        '${_columnLabels[index]}${_columnUnits[index].isNotEmpty ? '(${_columnUnits[index]})' : ''}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
        ),
      ),
    );
  }
}
