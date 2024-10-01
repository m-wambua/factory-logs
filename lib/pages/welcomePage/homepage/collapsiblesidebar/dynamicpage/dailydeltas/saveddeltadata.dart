import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SavedTablesPage extends StatefulWidget {
  final String subDeltaName;

  const SavedTablesPage({Key? key, required this.subDeltaName}) : super(key: key);

  @override
  _SavedTablesPageState createState() => _SavedTablesPageState();
}

class _SavedTablesPageState extends State<SavedTablesPage> {
  List<Map<String, dynamic>> _savedTables = [];

  @override
  void initState() {
    super.initState();
    _loadSavedTables();
  }

  Future<void> _loadSavedTables() async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataFile = File('${savedDataDir.path}/${widget.subDeltaName}_snapshots.json');

    if (await savedDataFile.exists()) {
      final jsonString = await savedDataFile.readAsString();
      final List<dynamic> snapshots = json.decode(jsonString) as List<dynamic>;
      setState(() {
        _savedTables = snapshots.cast<Map<String, dynamic>>();
      });
    }
  }

  Widget _buildTableCard(Map<String, dynamic> tableData) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved on: ${tableData['timestamp']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: tableData['columnLabels'].map<Widget>((label) {
                    return TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }).toList(),
                ),
                ...tableData['tableData'].map<TableRow>((row) {
                  return TableRow(
                    children: row.map<Widget>((cell) {
                      return TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Text(cell.toString()),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ],
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
        title: Text('Saved Tables for ${widget.subDeltaName}'),
      ),
      body: _savedTables.isEmpty
          ? Center(child: Text('No saved tables found.'))
          : ListView.builder(
              itemCount: _savedTables.length,
              itemBuilder: (context, index) {
                return _buildTableCard(_savedTables[index]);
              },
            ),
    );
  }
}