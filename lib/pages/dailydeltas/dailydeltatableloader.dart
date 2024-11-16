import 'dart:convert';
import 'dart:io';

import 'package:collector/pages/pages2/dailydeltas/dailydeltatrendspage.dart';
import 'package:collector/pages/pages2/dailydeltas/saveddeltadata.dart';
import 'package:collector/pages/pages2/dailydeltas/subdeltacreatorpage.dart';
import 'package:collector/pages/pages2/equipment/equipmentmenu.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Assuming you already have SubDeltaData and NotificationModel classes defined

class DeltaTableLoaderPage extends StatefulWidget {
  final String processName;
  final String subDeltaName;
  final Function(NotificationModel) onNotificationAdded;

  const DeltaTableLoaderPage({
    Key? key,
    required this.processName,
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
  Map<String, double> _cumulativeData = {};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    await _loadCumulativeData();
    SubDeltaData? loadData = await SubDeltaData.load(widget.subDeltaName);
    if (loadData != null) {
      setState(() {
        _columnLabels = loadData.columnLabels;
        _columnUnits = loadData.columnUnits;
        _controllers = loadData.rowsData.map((row) {
          return row.map((cell) => TextEditingController(text: cell)).toList();
        }).toList();
        _rowCount = loadData.rowsData.length;

        // Preload the 'Previous' column with the most recent non-zero cumulative data
        for (int i = 0; i < _controllers.length; i++) {
          String equipment = _controllers[i][0].text;
          _controllers[i][1].text = _getMostRecentNonZeroData(equipment);
        }
      });
    }
  }

  String _getMostRecentNonZeroData(String equipment) {
    if (_cumulativeData.containsKey(equipment) &&
        _cumulativeData[equipment]! > 0) {
      return _cumulativeData[equipment]!.toString();
    }
    return '0'; // Default to 0 if no previous data or it's zero
  }

  Future<void> _loadCumulativeData() async {
    final SavedDataDir = await getApplicationDocumentsDirectory();
    final cumulativeDataFile =
        File('${SavedDataDir.path}/${widget.subDeltaName}_cumulative.json');
    if (await cumulativeDataFile.exists()) {
      final jsonString = await cumulativeDataFile.readAsString();
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      _cumulativeData = Map<String, double>.from(jsonData);
    }
  }

  Future<void> _saveCumulativeData() async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final cumulativeDataFile =
        File('${savedDataDir.path}/${widget.subDeltaName}_cumulative.json');

    for (var row in _controllers) {
      String equipment = row[0].text;
      double currentValue = double.tryParse(row[2].text) ?? 0;
      double previousValue = _cumulativeData[equipment] ?? 0;
      _cumulativeData[equipment] = currentValue;
    }
    await cumulativeDataFile.writeAsString(json.encode(_cumulativeData));
  }

  void _updateDifference(int rowIndex) {
    final previous = double.tryParse(_controllers[rowIndex][1].text) ?? 0;
    final current = double.tryParse(_controllers[rowIndex][2].text) ?? 0;
    final difference = current - previous;
    _controllers[rowIndex][3].text = difference.toStringAsFixed(2);
  }

  Future<void> _saveDeltaTableAsDraft() async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataFile =
        File('${savedDataDir.path}/${widget.subDeltaName}_drafts.json');

    // Prepare the columns and table data (previous, current, and delta)
    Map<String, dynamic> tableJson = {
      'columns': _columnLabels,
      'numRows': _rowCount,
      'tableData': _controllers
          .map((row) => row.map((controller) => controller.text).toList())
          .toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      // Read the existing drafts or create a new list if the file doesn't exist
      List<dynamic> existingDrafts = [];
      if (await savedDataFile.exists()) {
        final jsonString = await savedDataFile.readAsString();
        existingDrafts = json.decode(jsonString) as List<dynamic>;
      }

      // Append the new draft to the existing list
      existingDrafts.add(tableJson);

      // Save the updated list back to the file
      await savedDataFile.writeAsString(json.encode(existingDrafts));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delta draft saved successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving delta draft!')),
      );
    }
  }

  Widget _buildDataTable() {
    if (_controllers.isEmpty) {
      return const Center(child: Text('No data available.'));
    }

    return Table(
      border: TableBorder.all(),
      children: List.generate(_rowCount, (rowIndex) {
        return TableRow(
          children: List.generate(_columnLabels.length, (colIndex) {
            return TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (colIndex == 1 || colIndex == 2) {
                            setState(() {
                              _updateDifference(rowIndex);
                            });
                          }
                        },
                        // Make the Previous column non-editable
                        readOnly: colIndex == 1, // Change this line
                      ),
              ),
            );
          }),
        );
      }),
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
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(
                        '${_columnLabels[index]}${_columnUnits[index].isNotEmpty ? '(${_columnUnits[index]})' : ''}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        _controllers[rowIndex][0].text, // Display the equipment name
        style: const TextStyle(color: Colors.black),
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
          title: const Text('Equipment Options'),
          content: Text('You clicked on ${_controllers[rowIndex][0].text}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EquipmentMenu(
                        processName: widget.processName,
                            subprocessName: widget.subDeltaName,
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
              child: const Text('Close'),
            ),
          ],
        );
      },
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
              const Text('Delta Table Loader'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
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
                  const SizedBox(
                    height: 20,
                  ),
                  _buildButtonRow(context),
                ],
              ),
            )),
          ],
        ));
  }

  Future<void> _saveTableSnapshot() async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataFile =
        File('${savedDataDir.path}/${widget.subDeltaName}_snapshots.json');

    Map<String, dynamic> tableSnapshot = {
      'timestamp': DateTime.now().toIso8601String(),
      'columnLabels': _columnLabels,
      'columnUnits': _columnUnits,
      'rowCount': _rowCount,
      'tableData': _controllers
          .map((row) => row.map((cell) => cell.text).toList())
          .toList(),
    };

    List<dynamic> existingSnapshots = [];
    if (await savedDataFile.exists()) {
      final jsonString = await savedDataFile.readAsString();
      existingSnapshots = json.decode(jsonString) as List<dynamic>;
    }

    existingSnapshots.add(tableSnapshot);

    await savedDataFile.writeAsString(json.encode(existingSnapshots));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Table snapshot saved successfully!')),
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SavedTablesPage(subDeltaName: widget.subDeltaName)));
            },
            child: const Text('Save as Draft')),
        TextButton(
            onPressed: () {
              _saveTableSnapshot();
              _saveAndNavigatetoTrends();
              _saveDeltaTableAsDraft();
              Navigator.pop(context);
            },
            child: const Text('Save and Exit')),
        TextButton(
            onPressed: () {
              _saveAndNavigatetoTrends();
              _saveDeltaTableAsDraft();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DailyDeltaTrends(subDeltaName: widget.subDeltaName)));
            },
            child: const Text('View History'))
      ],
    );
  }

  Future<void> _saveAndNavigatetoTrends() async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataDirFile =
        Directory('${savedDataDir.path}/${widget.subDeltaName}_saved');
    await savedDataDirFile.create(recursive: true);

    String timestamp = DateTime.now().toIso8601String();

    Map<String, dynamic> tableJson = {
      'columns': _columnLabels,
      'units': _columnUnits,
      'numRows': _rowCount,
      'tableData': _controllers
          .map((row) => row.map((cell) => cell.text).toList())
          .toList(),
      'timestamp': timestamp,
    };

    final fileName = '${savedDataDirFile.path}/data_$timestamp.json';
    try {
      await File(fileName).writeAsString(json.encode(tableJson));
      await _saveCumulativeData(); // Save the updated cumulative data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully!')),
      );
      // Navigate to trends screen or perform other actions
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving data!')),
      );
    }
  }

  Future<void> _loadDummyData() async {
    List<Map<String, dynamic>> _savedTables = [];
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataFile =
        File('${savedDataDir.path}/ ${widget.subDeltaName}_snapshots.json');

    if (await savedDataFile.exists()) {
      final jsonString = await savedDataFile.readAsString();
      final List<dynamic> snapshots = json.decode(jsonString) as List<dynamic>;
      setState(() {
        _savedTables = snapshots.cast<Map<String, dynamic>>();
      });
      //process the loaded data
    }
  }
}
