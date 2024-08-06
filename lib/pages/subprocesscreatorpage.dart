import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
}

class SubprocessCreatorPage extends StatefulWidget {
  final String subprocessName;
  const SubprocessCreatorPage({Key? key, required this.subprocessName})
      : super(key: key);

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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert table structure to JSON
    Map<String, dynamic> tableJson = {
      'columns': _columns
          .map((column) => {
                'name': column.name,
                'type': column.type.index,
                'isFixed': column.isFixed,
                'unit': column.unit
              })
          .toList(),
      'numRows': _numRows,
      'tableData': _tableData,
    };

    String tableJsonString = json.encode(tableJson);

    // Save JSON to SharedPreferences
    prefs.setString('${widget.subprocessName}_table', tableJsonString);

    // Debugging: Print JSON structure
    print('Saved JSON: $tableJsonString');

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Template saved!')));
  }

  Future<void> _loadTableTemplate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load JSON from SharedPreferences
      String? tableJsonString =
          prefs.getString('${widget.subprocessName}_table');

      if (tableJsonString != null) {
        Map<String, dynamic> tableJson = json.decode(tableJsonString);
        _columns = (tableJson['columns'] as List<dynamic>).map((columnJson) {
          return ColumnInfo(
            name: columnJson['name'],
            type: ColumnDataType.values[columnJson['type']],
            isFixed: columnJson['isFixed'],
            unit: columnJson['unit'] ?? '',
          );
        }).toList();
        _numRows = tableJson['numRows'];
        _tableData = List<List<String>>.from(
            tableJson['tableData'].map((row) => List<String>.from(row)));

        // Debugging: Print loaded JSON
        print('Loaded JSON: $tableJsonString');
      } else {
        // Handle case where no JSON is found
        _initializeTable(); // Default initialization
      }

      // Debugging: Print loaded table structure
      print('Loaded Columns: $_columns');
      print('Loaded Table Data: $_tableData');
    });
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
      return Center(child: Text('No columns available.'));
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
          title: Text('Set Number of Rows'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter number of rows'),
            onChanged: (value) {
              numRows = int.tryParse(value) ?? _numRows;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _numRows = numRows;
                  _initializeTable();
                });
                Navigator.pop(context);
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  }

  // Method to add a new column
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
              title: Row(
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
                    decoration: InputDecoration(
                      labelText: 'Enter column name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                    onChanged: (value) {
                      newColumnName = value;
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<ColumnDataType>(
                    value: selectedDataType,
                    decoration: InputDecoration(
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
                  SizedBox(height: 16),
                  if (selectedDataType == ColumnDataType.integer)
                    TextField(
                      controller: unitController,
                      decoration: InputDecoration(
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
                  child: Text('Cancel'),
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
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteColumn() {
    showDialog(
      context: context,
      builder: (context) {
        String columnNameToDelete = '';
        return AlertDialog(
          title: Text('Delete Column'),
          content: DropdownButtonFormField<String>(
            value: columnNameToDelete.isNotEmpty ? columnNameToDelete : null,
            hint: Text('Select column to delete'),
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
              child: Text('Cancel'),
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
              child: Text('Delete'),
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
          title: Text('Rename Column'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new column name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  column.name = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _markFixedColumn() {
    showDialog(
      context: context,
      builder: (context) {
        String columnNameToMark = '';
        return AlertDialog(
          title: Text('Mark Column as Fixed/User-Fillable'),
          content: DropdownButtonFormField<String>(
            value: columnNameToMark.isNotEmpty ? columnNameToMark : null,
            hint: Text('Select column'),
            items: _columns.map((column) {
              return DropdownMenuItem<String>(
                value: column.name,
                child: Text(column.name),
              );
            }).toList(),
            onChanged: (value) {
              columnNameToMark = value ?? '';
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (columnNameToMark.isNotEmpty) {
                  setState(() {
                    for (var column in _columns) {
                      if (column.name == columnNameToMark) {
                        column.isFixed = !column.isFixed;
                      }
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Toggle Fixed'),
            ),
          ],
        );
      },
    );
  }
}


/*
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: SubprocessCreatorPage()));

enum ColumnDataType {
  string,
  integer,
}

class ColumnInfo {
  String name;
  ColumnDataType type;
  bool isFixed;
  String unit;

  ColumnInfo({
    required this.name,
    this.type = ColumnDataType.string,
    this.isFixed = false,
    this.unit = '',
  });
}

class SubprocessCreatorPage extends StatefulWidget {
  @override
  _SubprocessCreatorPageState createState() => _SubprocessCreatorPageState();
}

class _SubprocessCreatorPageState extends State<SubprocessCreatorPage> {
  List<ColumnInfo> _columns = [];
  List<List<String>> _tableData = [];
  int _numRows = 5;

  @override
  void initState() {
    super.initState();
    _initializeTableData();
  }

  void _initializeTableData() {
    _tableData = List.generate(
      _numRows,
      (index) => List.generate(_columns.length, (_) => ''),
    );
  }

  void _addColumn() {
    // Initialize column name and selected data type
    String newColumnName = 'New Column';
    ColumnDataType selectedDataType = ColumnDataType.string;
    TextEditingController unitController = TextEditingController();

    showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Column'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text field for column name input
                  TextField(
                    decoration: InputDecoration(hintText: 'Enter column name'),
                    onChanged: (value) {
                      newColumnName = value; // Update column name
                    },
                  ),
                  // Dropdown for selecting column data type
                  DropdownButton<ColumnDataType>(
                    value: selectedDataType,
                    onChanged: (ColumnDataType? newValue) {
                      setState(() {
                        selectedDataType = newValue!; // Update selected data type
                      });
                    },
                    items: ColumnDataType.values.map((ColumnDataType type) {
                      return DropdownMenuItem<ColumnDataType>(
                        value: type,
                        child: Text(type == ColumnDataType.integer ? 'Numeric' : 'String'),
                      );
                    }).toList(),
                  ),
                  // Conditionally show unit input for numeric type
                  if (selectedDataType == ColumnDataType.integer)
                    TextField(
                      controller: unitController,
                      decoration: InputDecoration(hintText: 'Enter unit (optional)'),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog on cancel
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _columns.add(ColumnInfo(
                        name: newColumnName,
                        type: selectedDataType,
                        unit: selectedDataType == ColumnDataType.integer ? unitController.text : '',
                      ));
                      for (var row in _tableData) {
                        row.add('');
                      }
                    });
                    Navigator.pop(context); // Close dialog on add
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDataTable() {
    if (_columns.isEmpty) {
      return Center(child: Text('No columns available.'));
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
                              if (int.tryParse(value) != null || value.isEmpty) {
                                _tableData[index][colIndex] = value;
                              }
                            } else {
                              _tableData[index][colIndex] = value;
                            }
                          },
                          decoration: column.type == ColumnDataType.integer && column.unit.isNotEmpty
                              ? InputDecoration(
                                  suffixText: column.unit,
                                )
                              : null,
                        ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _renameColumn(ColumnInfo column) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController(text: column.name);
        return AlertDialog(
          title: Text('Rename Column'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new column name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  column.name = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('Rename'),
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
        title: Text('Subprocess Creator Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildDataTable()),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addColumn,
              child: Text('Add Column'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum ColumnDataType {
  integer,
  string,
}

class SubprocessCreatorPage extends StatefulWidget {
  final String subprocessName;
  const SubprocessCreatorPage({Key? key, required this.subprocessName})
      : super(key: key);

  @override
  _SubprocessCreatorPageState createState() => _SubprocessCreatorPageState();
}

class _SubprocessCreatorPageState extends State<SubprocessCreatorPage> {
  List<String> _columns = ['Equipment']; // Ensure default column
  int _numRows = 5;
  List<List<String>> _tableData = [];
  List<bool> _isFixedColumn = [];
  List<ColumnDataType> _columnDataTypes = [ColumnDataType.string];

  @override
  void initState() {
    super.initState();
    _initializeTable();
    _loadTableTemplate();
  }

  void _initializeTable() {
    _tableData = List.generate(
        _numRows, (index) => List.generate(_columns.length, (colIndex) => ''));
    _isFixedColumn = List.generate(_columns.length, (index) => false);
  }

  Future<void> _saveTableTemplate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert table structure to JSON
    Map<String, dynamic> tableJson = {
      'numRows': _numRows,
      'columns': _columns,
      'isFixedColumn': _isFixedColumn,
      'tableData': _tableData,
      'columnsDataTypes': _columnDataTypes.map((type) => type.index).toList(),
    };

    String tableJsonString = json.encode(tableJson);

    // Save JSON to SharedPreferences
    prefs.setString('${widget.subprocessName}_table', tableJsonString);

    // Debugging: Print JSON structure
    print('Saved JSON: $tableJsonString');

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Template saved!')));
  }

  Future<void> _loadTableTemplate() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    // Load JSON from SharedPreferences
    String? tableJsonString =
        prefs.getString('${widget.subprocessName}_table');

    if (tableJsonString != null) {
      Map<String, dynamic> tableJson = json.decode(tableJsonString);

      // Debugging: Print loaded JSON
      print('Loaded JSON: $tableJsonString');

      _numRows = tableJson['numRows'] ?? _numRows;
      _columns = List<String>.from(tableJson['columns'] ?? _columns);
      _isFixedColumn = List<bool>.from(
          tableJson['isFixedColumn'].map((e) => e as bool) ?? _isFixedColumn);
      _tableData = List<List<String>>.from(
        tableJson['tableData']?.map((row) => List<String>.from(row)) ??
            _tableData,
      );

      _columnDataTypes = List<ColumnDataType>.from(
        tableJson['columnDataTypes']?.map((index) => ColumnDataType.values[index]) ?? 
            _columnDataTypes,
      ); // Load data types

    } else {
      // Handle case where no JSON is found
      _initializeTable(); // Default initialization
    }

    // Debugging: Print loaded table structure
    print('Loaded Columns: $_columns');
    print('Loaded Table Data: $_tableData');
    print('Loaded Data Types: $_columnDataTypes');
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subprocessName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _showTableSizeDialog();
              },
              child: Text('Set Table Size'),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child:
                  _buildDataTable(), // Use a separate method to build the table
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addColumn();
              },
              child: Text('Add Column'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteColumn();
              },
              child: Text('Delete Column'),
            ),
            ElevatedButton(
              onPressed: () {
                _markFixedColumn();
              },
              child: Text('Mark Column as Fixed/User-Fillable'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveTableTemplate();
              },
              child: Text('Save Template'),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildDataTable() {
  if (_columns.isEmpty) {
    return Center(child: Text('No columns available.'));
  }

  return DataTable(
    columns: _columns.map((col) {
      return DataColumn(
        label: GestureDetector(
          onLongPress: () {
            _renameColumn(col);
          },
          child: Text(col),
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
              return DataCell(
                _isFixedColumn[colIndex]
                    ? Text(_tableData[index][colIndex])
                    : TextFormField(
                        initialValue: _tableData[index][colIndex],
                        keyboardType: _columnDataTypes[colIndex] == ColumnDataType.integer
                            ? TextInputType.number
                            : TextInputType.text,
                        onChanged: (value) {
                          if (_columnDataTypes[colIndex] == ColumnDataType.integer) {
                            // Ensure only numbers are accepted
                            if (int.tryParse(value) != null || value.isEmpty) {
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
          title: Text('Set Number of Rows'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter number of rows'),
            onChanged: (value) {
              numRows = int.tryParse(value) ?? _numRows;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _numRows = numRows;
                  _initializeTable();
                });
                Navigator.pop(context);
              },
              child: Text('Set'),
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
      String newColumnName = 'New Column';
      ColumnDataType selectedDataType = ColumnDataType.string;

      return AlertDialog(
        title: Text('Add Column'),
        content: Column(
          children: [
            TextField(
              decoration: InputDecoration(hintText: 'Enter column name'),
              onChanged: (value) {
                newColumnName = value;
              },
            ),
            DropdownButton<ColumnDataType>(
              value: selectedDataType,
              onChanged: (value) {
                setState(() {
                  selectedDataType = value!;
                });
              },
              items: ColumnDataType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type == ColumnDataType.integer ? 'Numeric' : 'String'),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _columns.add(newColumnName);
                for (var row in _tableData) {
                  row.add('');
                }
                _isFixedColumn.add(false);
                _columnDataTypes.add(selectedDataType); // Add selected data type
              });
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}

  void _deleteColumn() {
    showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Column'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _columns.map((col) {
              return ListTile(
                title: Text(col),
                onTap: () {
                  setState(() {
                    int colIndex = _columns.indexOf(col);
                    _columns.removeAt(colIndex);
                    for (var row in _tableData) {
                      row.removeAt(colIndex);
                    }
                    _isFixedColumn.removeAt(colIndex);
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
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
        return AlertDialog(
          title: Text('Mark Column as Fixed/User-Fillable'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _columns.map((col) {
              return ListTile(
                title: Text(col),
                trailing: Switch(
                  value: _isFixedColumn[_columns.indexOf(col)],
                  onChanged: (value) {
                    setState(() {
                      int colIndex = _columns.indexOf(col);
                      _isFixedColumn[colIndex] = value;
                    });
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
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _renameColumn(String oldName) {
    TextEditingController controller =
        TextEditingController(text: oldName); // Set initial value
    showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename Column'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new column name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  int colIndex = _columns.indexOf(oldName);
                  if (colIndex != -1) {
                    _columns[colIndex] = controller.text;
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  
}
}
*/