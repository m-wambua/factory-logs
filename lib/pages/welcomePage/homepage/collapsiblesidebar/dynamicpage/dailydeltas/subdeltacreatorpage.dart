import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SubDeltaData {
  final String subdeltaName;
  final List<String> columnLabels;
  final List<String> columnUnits;
  final List<List<String>> rowsData;

  SubDeltaData(
      {required this.subdeltaName,
      required this.columnLabels,
      required this.columnUnits,
      required this.rowsData});
  // Method to create subdeltadata from the current state

  static SubDeltaData fromState(
    String subdeltaName,
    List<String> columnLabels,
    List<String> columnUnits,
    List<List<TextEditingController>> controller,
  ) {
    List<List<String>> rowsData = controller.map((row) {
      return row.map((controller) => controller.text).toList();
    }).toList();

    return SubDeltaData(
      subdeltaName: subdeltaName,
      columnLabels: columnLabels,
      columnUnits: columnUnits,
      rowsData: rowsData,
    );
  }

  //method to validate the data before saving
  bool isValid() {
    return !rowsData.any((row) => row[0].isEmpty);
  }

  // Convert subDeltaData to JSON
  Map<String, dynamic> toJson() {
    return {
      'subdeltaName': subdeltaName,
      'columnLabels': columnLabels,
      'columnUnits': columnUnits,
      'rowsData': rowsData,
    };
  }

  //Create SubDeltaData from JSON
  factory SubDeltaData.fromJson(Map<String, dynamic> json) {
    return SubDeltaData(
        subdeltaName: json['subdeltaName'],
        columnLabels: List<String>.from(json['columnLabels']),
        columnUnits: List<String>.from(json['columnUnits']),
        rowsData: List<List<String>>.from(
            json['rowsData'].map((row) => List<String>.from(row))));
  }

//Method to save the data as a JSON file
  Future<bool> save(String subdeltaName) async {
    if (!isValid()) {
      return false;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$subdeltaName.json');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      await file.writeAsString(jsonEncode(toJson()));

      print('Saved Subdelta to ${file.path}');
      return true;
    } catch (e) {
      print(' Error saving subDelta: $e');
      return false;
    }
  }

  static Future<SubDeltaData?> load(String subdeltaName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$subdeltaName.json');

      if (await file.exists()) {
        String contents = await file.readAsString();
        Map<String, dynamic> json = jsonDecode(contents);
        return SubDeltaData.fromJson(json);
      }
    } catch (e) {
      print('Error loading SubDelta: $e');
    }
    return null;
  }

  //Method to save the data (you can implement the actual saving logic here)
}

class SubDeltaCreatorPage extends StatefulWidget {
  final String subdeltaName;

  const SubDeltaCreatorPage({Key? key, required this.subdeltaName})
      : super(key: key);

  @override
  _SubDeltaCreatorPageState createState() => _SubDeltaCreatorPageState();
}

class _SubDeltaCreatorPageState extends State<SubDeltaCreatorPage> {
  List<List<TextEditingController>> _controllers = [];
  List<String> _columnLabels = [
    'Equipment',
    'Previous',
    'Current',
    'Difference'
  ];
  List<String> _columnUnits = ['', '', '', ''];
  int _rowCount = 3; // Default to 3 rows
  @override
  void initState() {
    super.initState();
    _loadSavedData();
    for (int i = 0; i < _rowCount; i++) {
      _addRow();
    }
  }

  Future<void> _loadSavedData() async {
    SubDeltaData? loadData = await SubDeltaData.load(widget.subdeltaName);
    if (loadData != null) {
      setState(() {
        _columnLabels = loadData.columnLabels;
        _columnUnits = loadData.columnUnits;
        _controllers = loadData.rowsData.map((row) {
          return row.map((cell) => TextEditingController(text: cell)).toList();
        }).toList();
        _rowCount = loadData.rowsData.length;
      });
    } else {
      return null;
    }
  }

  void _saveSubDeltaData() async {
    SubDeltaData data = SubDeltaData.fromState(
      widget.subdeltaName,
      _columnLabels,
      _columnUnits,
      _controllers,
    );

    bool saveResult = await data.save(widget.subdeltaName);
    if (saveResult) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data')),
      );
    }
  }

  void _addRow() {
    setState(() {
      _controllers.add(List.generate(4, (_) => TextEditingController()));
    });
  }

  void _removeRow() {
    if (_rowCount > 1) {
      setState(() {
        _controllers.removeLast();
        _rowCount--;
      });
    }
  }

  void _updateDifference(int rowIndex) {
    final previous = double.tryParse(_controllers[rowIndex][1].text) ?? 0;
    final current = double.tryParse(_controllers[rowIndex][2].text) ?? 0;
    final difference = previous - current;
    _controllers[rowIndex][3].text = difference.toStringAsFixed(2);
  }

  Future<void> _showColumnEditDialog(int columnIndex) async {
    String newLabel = _columnLabels[columnIndex];
    String newUnit = _columnUnits[columnIndex];
    bool addUnit = _columnUnits[columnIndex].isNotEmpty;

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Column'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Column Name'),
                    onChanged: (value) => newLabel = value,
                    controller: TextEditingController(text: newLabel),
                  ),
                  SwitchListTile(
                    title: Text('Add Unit'),
                    value: addUnit,
                    onChanged: (value) => setState(() {
                      addUnit = value;
                    }),
                  ),
                  if (addUnit)
                    TextField(
                      decoration: InputDecoration(labelText: 'Unit'),
                      onChanged: (value) => newUnit = value,
                      controller: TextEditingController(text: newUnit),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    this.setState(() {
                      _columnLabels[columnIndex] = newLabel;
                      _columnUnits[columnIndex] = addUnit ? newUnit : '';
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subdeltaName),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // TODO: Implement save functionality
              _saveSubDeltaData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildColumnLabelsRow(),
          Expanded(
            child: ListView.builder(
              itemCount: _rowCount,
              itemBuilder: (context, index) => _buildDataRow(index),
            ),
          ),
          _buildAddRemoveButtons()
        ],
      ),
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
              child: GestureDetector(
                onLongPress: () =>
                    index > 0 ? _showColumnEditDialog(index) : null,
                child: Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text(
                    '${_columnLabels[index]}${_columnUnits[index].isNotEmpty ? ' (${_columnUnits[index]})' : ''}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
            4,
            (colIndex) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: TextFormField(
                  controller: _controllers[rowIndex][colIndex],
                  keyboardType:
                      colIndex == 0 ? TextInputType.text : TextInputType.number,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddRemoveButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(onPressed: _addRow, child: Text('Add Row')),
        ElevatedButton(
          onPressed: _removeRow,
          child: Text('Remove Row'),
        )
      ],
    );
  }
}
/*
class SubDeltaCreatorPage extends StatefulWidget {
  final String subdeltaName;

  const SubDeltaCreatorPage({Key? key, required this.subdeltaName})
      : super(key: key);

  @override
  _SubDeltaCreatorPageState createState() => _SubDeltaCreatorPageState();
}

class _SubDeltaCreatorPageState extends State<SubDeltaCreatorPage> {
  List<List<TextEditingController>> _controllers = [];
  List<String> _columnLabels = [
    'Equipment',
    'Previous',
    'Current',
    'Difference'
  ];
  List<String> _columnUnits = ['', '', '', ''];
  int _rowCount = 3; // Default to 3 rows

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _rowCount; i++) {
      _addRow();
    }
  }

  void _addRow() {
    setState(() {
      _controllers.add(List.generate(4, (_) => TextEditingController()));
      _rowCount++;
    });
  }

  void _removeRow() {
    if (_rowCount > 1) {
      setState(() {
        _controllers.removeLast();
        _rowCount--;
      });
    }
  }

  void _updateDifference(int rowIndex) {
    final previous = double.tryParse(_controllers[rowIndex][1].text) ?? 0;
    final current = double.tryParse(_controllers[rowIndex][2].text) ?? 0;
    final difference = previous - current;
    _controllers[rowIndex][3].text = difference.toStringAsFixed(2);
  }

  Future<void> _showColumnEditDialog(int columnIndex) async {
    String newLabel = _columnLabels[columnIndex];
    String newUnit = _columnUnits[columnIndex];
    bool addUnit = _columnUnits[columnIndex].isNotEmpty;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Column'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Column Name'),
                onChanged: (value) => newLabel = value,
                controller: TextEditingController(text: newLabel),
              ),
              SwitchListTile(
                title: Text('Add Unit'),
                value: addUnit,
                onChanged: (value) => setState(() => addUnit = value),
              ),
              if (addUnit)
                TextField(
                  decoration: InputDecoration(labelText: 'Unit'),
                  onChanged: (value) => newUnit = value,
                  controller: TextEditingController(text: newUnit),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  _columnLabels[columnIndex] = newLabel;
                  _columnUnits[columnIndex] = addUnit ? newUnit : '';
                });
                Navigator.of(context).pop();
              },
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
        title: Text(widget.subdeltaName),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // TODO: Implement save functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildColumnLabelsRow(),
          Expanded(
            child: ListView.builder(
              itemCount: _rowCount,
              itemBuilder: (context, index) => _buildDataRow(index),
            ),
          ),
          _buildRowManagementButtons(),
        ],
      ),
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
              child: GestureDetector(
                onLongPress: () =>
                    index > 0 ? _showColumnEditDialog(index) : null,
                child: Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text(
                    '${_columnLabels[index]}${_columnUnits[index].isNotEmpty ? ' (${_columnUnits[index]})' : ''}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
            4,
            (colIndex) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: TextFormField(
                  controller: _controllers[rowIndex][colIndex],
                  keyboardType:
                      colIndex == 0 ? TextInputType.text : TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: colIndex == 1
                        ? '300'
                        : colIndex == 2
                            ? '500'
                            : colIndex == 3
                                ? '200'
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowManagementButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _addRow,
            child: Text('Add Row'),
          ),
          ElevatedButton(
            onPressed: _removeRow,
            child: Text('Remove Row'),
          ),
        ],
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';

class SubDeltaCreatorPage extends StatefulWidget {
  final String subdeltaName;

  const SubDeltaCreatorPage({Key? key, required this.subdeltaName}) : super(key: key);

  @override
  _SubDeltaCreatorPageState createState() => _SubDeltaCreatorPageState();
}

class _SubDeltaCreatorPageState extends State<SubDeltaCreatorPage> {
  List<List<TextEditingController>> _controllers = [];
  List<String> _columnLabels = ['Equipment', 'Previous', 'Current', 'Difference'];
  List<String> _columnUnits = ['', '', '', ''];
  int _rowCount = 1;

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  void _addRow() {
    setState(() {
      _controllers.add(List.generate(4, (_) => TextEditingController()));
      _rowCount++;
    });
  }

  void _removeRow() {
    if (_rowCount > 1) {
      setState(() {
        _controllers.removeLast();
        _rowCount--;
      });
    }
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
        title: Text(widget.subdeltaName),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // TODO: Implement save functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildColumnLabelsRow(),
          Expanded(
            child: ListView.builder(
              itemCount: _rowCount,
              itemBuilder: (context, index) => _buildDataRow(index),
            ),
          ),
          _buildAddRemoveButtons(),
        ],
      ),
    );
  }

  Widget _buildColumnLabelsRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: List.generate(
          4,
          (index) => Expanded(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _columnLabels[index],
                  onChanged: (value) => setState(() => _columnLabels[index] = value),
                  decoration: InputDecoration(labelText: 'Label'),
                ),
                TextFormField(
                  initialValue: _columnUnits[index],
                  onChanged: (value) => setState(() => _columnUnits[index] = value),
                  decoration: InputDecoration(labelText: 'Unit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(int rowIndex) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: List.generate(
          4,
          (index) => Expanded(
            child: TextFormField(
              controller: _controllers[rowIndex][index],
              keyboardType: index == 0 ? TextInputType.text : TextInputType.number,
              decoration: InputDecoration(
                labelText: _columnLabels[index],
                suffix: Text(_columnUnits[index]),
              ),
              onChanged: (value) {
                if (index == 1 || index == 2) _updateDifference(rowIndex);
              },
              readOnly: index == 3, // Make the Difference field read-only
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddRemoveButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _addRow,
          child: Text('Add Row'),
        ),
        ElevatedButton(
          onPressed: _removeRow,
          child: Text('Remove Row'),
        ),
      ],
    );
  }
}
*/