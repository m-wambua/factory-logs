import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
enum ColumnDataType {
  integer,
  string,
}

class ColumnInfo {
  String name;
  ColumnDataType type;
  bool isFixed;
  String unit;
  ColumnInfo(
      {required this.name,
      this.type = ColumnDataType.string,
      this.isFixed = false,
      this.unit = ''});
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.index,
        'isFixed': isFixed,
        'unit': unit,
      };
  factory ColumnInfo.fromJson(Map<String, dynamic> json) => ColumnInfo(
        name: json['name'] as String,
        type: ColumnDataType.values[json['type'] as int],
        isFixed: json['isFixed'] as bool,
        unit: json['unit'] as String,
      );
}

class SubprocessCreatorPage extends StatefulWidget {
  final String subprocessName;
  const SubprocessCreatorPage({super.key, required this.subprocessName});

  @override
  _SubprocessCreatorPageState createState() => _SubprocessCreatorPageState();
}

class _SubprocessCreatorPageState extends State<SubprocessCreatorPage> {
  List<ColumnInfo> _columns = [
    ColumnInfo(name: 'Equipment')
  ]; // Ensure default column
  int _numRows = 5;
  List<List<String>> _tableData = [];

  @override
  void initState() {
    super.initState();
    _initializeTable();
    _loadTableTemplate();
  }

  void _initializeTable() {
    _tableData = List.generate(
        _numRows, (index) => List.generate(_columns.length, (colIndex) => ''));
  }
 Future<void> _saveTableTemplate() async {
  final tableFileName = '${widget.subprocessName}_table.json';
  final documentsDir = await getApplicationDocumentsDirectory();
  final tableFile = File('${documentsDir.path}/$tableFileName');

  // Check if the file exists, create it if not
  if (!await tableFile.exists()) {
    await tableFile.create(recursive: true);
  }

  // Convert table structure to JSON
  final tableJson = {
    'columns': _columns.map((column) => column.toJson()).toList(),
    'numRows': _numRows,
    'tableData': _tableData.map((row) => row.map((cell) => cell).toList()).toList(), // Deep copy of table data
  };

  try {
    await tableFile.writeAsString(json.encode(tableJson));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Template saved!')));
  } catch (error) {
    print('Error saving table to file: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error saving template!')),
    );
  }
}


Future<void> _loadTableTemplate() async {
  final tableFileName = '${widget.subprocessName}_table.json';
  final documentsDir = await getApplicationDocumentsDirectory();
  final tableFile = File('${documentsDir.path}/$tableFileName');

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
    _initializeTable(); // Default initialization
  }

  setState(() {});
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subprocessName),
        backgroundColor: Colors.blueAccent, // AppBar theme color
      ),
      body: Column(
        children: [
          // Dynamic button bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Wrap(
                  spacing: constraints.maxWidth / 30,
                  runSpacing: 10,
                  children: [
                    _buildIconButton(Icons.table_rows, 'Set Table Size',
                        Colors.teal, _showTableSizeDialog),
                    _buildIconButton(
                        Icons.add, 'Add Column', Colors.teal, _addColumn),
                    _buildIconButton(Icons.delete, 'Delete Column',
                        Colors.redAccent, _deleteColumn),
                    _buildIconButton(
                        Icons.lock,
                        'Mark Column as Fixed/User-Fillable',
                        Colors.orangeAccent,
                        _markFixedColumn),
                    _buildIconButton(Icons.save, 'Save Template', Colors.green,
                        _saveTableTemplate),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildDataTable(), // Method to build the table
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
      IconData icon, String tooltip, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color, size: 30),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  Widget _buildDataTable() {
    if (_columns.isEmpty) {
      return const Center(child: Text('No columns available.'));
    }

    return DataTable(
      columns: _columns.map((column) {
        return DataColumn(
          label: GestureDetector(
            onLongPress: () {
              _renameColumn(column);
            },
            child: Text(column.name),
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
                return DataCell(
                  column.isFixed
                      ? Text(_tableData[index][colIndex])
                      : TextFormField(
                          initialValue: _tableData[index][colIndex],
                          keyboardType: column.type == ColumnDataType.integer
                              ? TextInputType.number
                              : TextInputType.text,
                          onChanged: (value) {
                            if (column.type == ColumnDataType.integer) {
                              // Ensure only numbers are accepted
                              if (int.tryParse(value) != null ||
                                  value.isEmpty) {
                                _tableData[index][colIndex] = value;
                              }
                            } else {
                              _tableData[index][colIndex] = value;
                            }
                          },
                        ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showTableSizeDialog() {
    showDialog<int>(
      context: context,
      builder: (context) {
        int numRows = _numRows;
        return AlertDialog(
          title: const Text('Set Number of Rows'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter number of rows'),
            onChanged: (value) {
              numRows = int.tryParse(value) ?? _numRows;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _numRows = numRows;
                  _initializeTable();
                });
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  void _addColumn() {
    showDialog<String>(
      context: context,
      builder: (context) {
        // Initial column name and data type
        String newColumnName = 'New Column';
        ColumnDataType selectedDataType = ColumnDataType.string;
        TextEditingController unitController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: const Row(
                children: [
                  Icon(Icons.add, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    'Add Column',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter column name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                    onChanged: (value) {
                      newColumnName = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ColumnDataType>(
                    value: selectedDataType,
                    decoration: const InputDecoration(
                      labelText: 'Select Data Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.data_usage),
                    ),
                    items: ColumnDataType.values.map((ColumnDataType type) {
                      return DropdownMenuItem<ColumnDataType>(
                        value: type,
                        child: Text(
                          type == ColumnDataType.integer ? 'Integer' : 'String',
                        ),
                      );
                    }).toList(),
                    onChanged: (ColumnDataType? newValue) {
                      setState(() {
                        selectedDataType = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedDataType == ColumnDataType.integer)
                    TextField(
                      controller: unitController,
                      decoration: const InputDecoration(
                        labelText: 'Enter unit (optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newColumnName.isNotEmpty) {
                      setState(() {
                        _columns.add(ColumnInfo(
                          name: newColumnName +
                              (selectedDataType == ColumnDataType.integer
                                  ? ' (${unitController.text})'
                                  : ''),
                          type: selectedDataType,
                          isFixed: false,
                          unit: unitController.text,
                        ));

                        // Add default values for the new column in each row
                        for (var row in _tableData) {
                          row.add(''); // Add an empty value for new column
                        }
                      });
                      Navigator.of(context).pop(); // Close the dialog
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // This is where you can trigger a rebuild or refresh of the main page
      setState(
          () {}); // Ensure to call setState here to update the UI with the new column
    });
  }

  void _deleteColumn() {
    showDialog(
      context: context,
      builder: (context) {
        String columnNameToDelete = '';
        return AlertDialog(
          title: const Text('Delete Column'),
          content: DropdownButtonFormField<String>(
            value: columnNameToDelete.isNotEmpty ? columnNameToDelete : null,
            hint: const Text('Select column to delete'),
            items: _columns
                .where((column) => column.name != 'Equipment')
                .map((column) {
              return DropdownMenuItem<String>(
                value: column.name,
                child: Text(column.name),
              );
            }).toList(),
            onChanged: (value) {
              columnNameToDelete = value ?? '';
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (columnNameToDelete.isNotEmpty) {
                  setState(() {
                    int indexToRemove = _columns.indexWhere(
                        (column) => column.name == columnNameToDelete);
                    if (indexToRemove != -1) {
                      _columns.removeAt(indexToRemove);
                      for (var row in _tableData) {
                        row.removeAt(indexToRemove);
                      }
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _renameColumn(ColumnInfo column) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller =
            TextEditingController(text: column.name);
        return AlertDialog(
          title: const Text('Rename Column'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter new column name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  column.name = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _markFixedColumn() {
    showDialog<String>(
      context: context,
      builder: (context) {
        // Temporary list to hold the state of each column's fix status
        List<bool> isFixedColumn =
            _columns.map((column) => column.isFixed).toList();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Mark Column as Fixed/User-Fillable'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _columns.asMap().entries.map((entry) {
                  int index = entry.key;
                  var column = entry.value;
                  return ListTile(
                    title: Text(column.name),
                    trailing: Switch(
                      value: isFixedColumn[index],
                      onChanged: (value) {
                        setState(() {
                          // Update the temporary list
                          isFixedColumn[index] = value;
                          // Update the actual _columns list
                          _columns[index].isFixed = value;
                        });
                        // Optionally, update the dialog immediately
                        Navigator.pop(context);
                        _markFixedColumn();
                      },
                    ),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
