import 'package:collector/pages/dailydeltas/subdeltacreatorpage.dart';
import 'package:flutter/material.dart';

class DailyDeltaTrends extends StatefulWidget {
  final String subDeltaName;
  const DailyDeltaTrends({Key? key, required this.subDeltaName})
      : super(key: key);
  @override
  _DeltaTrendsState createState() => _DeltaTrendsState();
}

class _DeltaTrendsState extends State<DailyDeltaTrends> {
  List<String> _newColumnLabels = ['Timestamp'];
  List<List<String>> _newTableData = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    setState(() => _isLoading = true);
    SubDeltaData? loadData = await SubDeltaData.load(widget.subDeltaName);
    if (loadData != null) {
      setState(() {
// Extract unique values from the first column to create new column labels
        Set<String> uniqueEquipment =
            Set<String>.from(loadData.rowsData.map((row) => row[0]));
        _newColumnLabels.addAll(uniqueEquipment);
// Create new table data
        Map<String, Map<String, String>> transformedData = {};
        for (var row in loadData.rowsData) {
          String equipment = row[0];
          String timestamp =
              row[1]; // Assuming timestamp is in the second column
          String value = row[2]; // Assuming the value is in the third column
          if (!transformedData.containsKey(timestamp)) {
            transformedData[timestamp] = {};
          }
          transformedData[timestamp]![equipment] = value;
        }
// Convert transformed data to list format for the table
        transformedData.forEach((timestamp, data) {
          List<String> rowData = [timestamp];
          for (var equipment in _newColumnLabels.skip(1)) {
            rowData.add(data[equipment] ?? '');
          }
          _newTableData.add(rowData);
        });
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subDeltaName}\'s Trends'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: _newColumnLabels
                      .map((label) => DataColumn(label: Text(label)))
                      .toList(),
                  rows: _newTableData.map((rowData) {
                    return DataRow(
                      cells: rowData
                          .map((cellData) => DataCell(Text(cellData)))
                          .toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
