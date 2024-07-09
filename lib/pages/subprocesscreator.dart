import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubprocessCreatorPage extends StatefulWidget {
  final String subprocessName;
  const SubprocessCreatorPage({Key? key, required this.subprocessName})
      : super(key: key);

  @override
  _SubprocessCreatorPageState createState() => _SubprocessCreatorPageState();
}

class _SubprocessCreatorPageState extends State<SubprocessCreatorPage> {
  List<String> _columns = ['Equipment'];
  int _numRows = 5;
  List<List<String>> _tableData = [];
  List<bool> _isFixedColumn = [];

  @override
  void initState() {
    super.initState();
    _initializeTable();
    _loadTableTemplate();
  }

  void _initializeTable() {
    _tableData = List.generate(_numRows, (index) => List.generate(_columns.length, (colIndex) => ''));
    _isFixedColumn = List.generate(_columns.length, (index) => false);
  }

  Future<void> _saveTableTemplate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('${widget.subprocessName}_numRows', _numRows);
    prefs.setStringList('${widget.subprocessName}_columns', _columns);
    prefs.setStringList('${widget.subprocessName}_isFixedColumn', _isFixedColumn.map((e) => e.toString()).toList());
    for (int i = 0; i < _numRows; i++) {
      prefs.setStringList('${widget.subprocessName}_row_$i', _tableData[i]);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Template saved!')));
  }

  Future<void> _loadTableTemplate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _numRows = prefs.getInt('${widget.subprocessName}_numRows') ?? _numRows;
      _columns = prefs.getStringList('${widget.subprocessName}_columns') ?? _columns;
      List<String>? fixedColumnList = prefs.getStringList('${widget.subprocessName}_isFixedColumn');
      if (fixedColumnList != null) {
        _isFixedColumn = fixedColumnList.map((e) => e == 'true').toList();
      } else {
        _isFixedColumn = List.generate(_columns.length, (index) => false);
      }
      _tableData = List.generate(
        _numRows,
        (index) => prefs.getStringList('${widget.subprocessName}_row_$index') ?? List.generate(_columns.length, (colIndex) => ''),
      );
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
              child: DataTable(
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
                                    onChanged: (value) {
                                      _tableData[index][colIndex] = value;
                                    },
                                  ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
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
        return AlertDialog(
          title: Text('Add Column'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Enter column name'),
            onChanged: (value) {
              newColumnName = value;
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
                  _columns.add(newColumnName);
                  for (var row in _tableData) {
                    row.add('');
                  }
                  _isFixedColumn.add(false);
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

  void _renameColumn(String oldColumn) {
    showDialog<String>(
      context: context,
      builder: (context) {
        String newColumnName = oldColumn;
        return AlertDialog(
          title: Text('Rename Column'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Enter new column name'),
            onChanged: (value) {
              newColumnName = value;
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
                  int columnIndex = _columns.indexOf(oldColumn);
                  _columns[columnIndex] = newColumnName;
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