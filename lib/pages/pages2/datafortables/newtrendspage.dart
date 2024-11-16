import 'dart:io';

import 'package:collector/pages/pages2/subprocesscreator.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

// Update the ChartData class
class ChartData {
  final String timestamp;
  final List<double> values;
  final String name;

  ChartData({
    required this.timestamp,
    required this.values,
    required this.name,
  });
}

class TrendsPage2 extends StatefulWidget {
  final String subprocessName;

  const TrendsPage2({Key? key, required this.subprocessName}) : super(key: key);

  @override
  _TrendsPage2State createState() => _TrendsPage2State();
}

class _TrendsPage2State extends State<TrendsPage2> {
  List<Map<String, dynamic>> _savedDataList = [];
  List<ColumnInfo> _columns = [];
  List<List<String>> _tableData = [];
  int _numRows = 0;

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
              Text('Saved ${widget.subprocessName} Data'),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildDummyTable(),
              const Divider(),
              buildCombinedLineGraph()
            ],
          ),
        ));
  }

// Replace the existing _buildLineGraphData and _buildLineGraphs methods with these:

  List<ChartData> _buildLineGraphData() {
    List<List<String>> groupedData = extractAndGroupDataByTimestamps();
    List<ChartData> lineGraphData = [];

    print('Grouped Data: $groupedData'); // Debug print

    // Get non-fixed integer columns
    List<int> nonFixedIntegerColumnIndices = _columns
        .asMap()
        .entries
        .where((entry) =>
            !entry.value.isFixed && entry.value.type == ColumnDataType.integer)
        .map((entry) => entry.key)
        .toList();

    print(
        'Non-fixed Integer Column Indices: $nonFixedIntegerColumnIndices'); // Debug print

    // Get column names for these indices
    List<String> seriesNames = nonFixedIntegerColumnIndices
        .map((index) => _columns[index].name)
        .toList();

    print('Series Names: $seriesNames'); // Debug print

    if (groupedData.isEmpty) {
      print('No grouped data available');
      return [];
    }

    // Process each row of data
    for (var row in groupedData) {
      if (row.isEmpty) {
        print('Empty row found, skipping');
        continue;
      }

      try {
        String timestamp = row[0];
        print('Processing timestamp: $timestamp'); // Debug print

        // Convert all values after timestamp to doubles
        List<double> values = row.sublist(1).map((value) {
          final parsedValue = double.tryParse(value.trim()) ?? 0.0;
          print('Parsed value: $value -> $parsedValue'); // Debug print
          return parsedValue;
        }).toList();

        if (values.isNotEmpty) {
          ChartData chartData = ChartData(
            timestamp: timestamp,
            values: values,
            name: 'Data Series', // We'll improve this naming later
          );
          lineGraphData.add(chartData);
        }
      } catch (e) {
        print('Error processing row: $e'); // Debug print
        continue;
      }
    }

    print(
        'Final Line Graph Data: ${lineGraphData.length} entries'); // Debug print
    return lineGraphData;
  }

  Widget buildCombinedLineGraph() {
    final List<ChartData> chartDataList = _buildLineGraphData();

    // Get dummy headers (excluding the timestamp column which is at index 0)
    List<String> dummyHeaders = _tableData.map((row) => row[0]).toList();
    // Remove the 'Time Stamp' header

    print('Dummy Headers: $dummyHeaders'); // Debug print

    if (chartDataList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No data available for the graph. Please check if data is loaded correctly.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // Define colors for different lines
    final List<Color> lineColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    // Find overall min and max values
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var data in chartDataList) {
      for (var value in data.values) {
        if (value < minY) minY = value;
        if (value > maxY) maxY = value;
      }
    }

    // Ensure we have a non-zero range
    if (minY == maxY ||
        minY == double.infinity ||
        maxY == double.negativeInfinity) {
      minY = 0;
      maxY = 1;
    }

    final double padding = (maxY - minY) * 0.1;
    final double effectiveMinY = minY - padding;
    final double effectiveMaxY = maxY + padding;

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        // Get the header name for this series
                        String headerName = dummyHeaders[spot.barIndex];
                        return LineTooltipItem(
                          '$headerName: ${spot.y.toStringAsFixed(1)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: List.generate(
                  chartDataList[0].values.length,
                  (seriesIndex) => LineChartBarData(
                    spots: chartDataList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final values = entry.value.values;
                      return FlSpot(
                        index.toDouble(),
                        seriesIndex < values.length ? values[seriesIndex] : 0,
                      );
                    }).toList(),
                    isCurved: false,
                    color: lineColors[seriesIndex % lineColors.length],
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColors[seriesIndex % lineColors.length]
                          .withOpacity(0.1),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt();
                        if (index >= 0 && index < chartDataList.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Text(
                                chartDataList[index].timestamp,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                minY: effectiveMinY,
                maxY: effectiveMaxY,
              ),
            ),
          ),
          // Updated legend with dummy headers
          Wrap(
            spacing: 8.0,
            children: List.generate(
              dummyHeaders.length,
              (index) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: lineColors[index % lineColors.length],
                  ),
                  const SizedBox(width: 4),
                  Text(dummyHeaders[index]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
import 'package:collector/pages/subprocesscreator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TrendsPage2 extends StatefulWidget {
  final String subprocessName;

  const TrendsPage2({Key? key, required this.subprocessName}) : super(key: key);

  @override
  _TrendsPage2State createState() => _TrendsPage2State();
}

class _TrendsPage2State extends State<TrendsPage2> {
  List<Map<String, dynamic>> _savedDataList = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    List<Map<String, dynamic>> tempList = [];

    for (String key in keys) {
      if (key.startsWith('${widget.subprocessName}_saved_')) {
        String? tableJsonString = prefs.getString(key);
        if (tableJsonString != null) {
          try {
            // Decode the JSON into a Map
            Map<String, dynamic> tableJson = json.decode(tableJsonString);

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
    }

    setState(() {
      _savedDataList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Data'),
      ),
      body: ListView.builder(
        itemCount: _savedDataList.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> savedData = _savedDataList[index];

          String timestamp = savedData['timestamp'] ?? 'Unknown';
          List<dynamic> columnsJson = savedData['columns'] ?? [];
          List<dynamic> tableDataJson = savedData['tableData'] ?? [];

          List<ColumnInfo> columns = columnsJson.map((columnJson) {
            return ColumnInfo(
              name: columnJson['name'],
              type: ColumnDataType.values[columnJson['type']],
              isFixed: columnJson['isFixed'],
              unit: columnJson['unit'] ?? '',
            );
          }).toList();

          List<List<String>> tableData = tableDataJson.map((row) {
            return (row as List<dynamic>)
                .map((cell) => cell.toString())
                .toList();
          }).toList();

          // Ensure columns are not empty
          if (columns.isEmpty) {
            return Card(
              child: ListTile(
                title: Text('Saved on: $timestamp'),
                subtitle: Text('No columns available for this entry.'),
              ),
            );
          }

          return Card(
            child: ListTile(
              title: Text('Saved on: $timestamp'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DataTable(
                    columns: columns.map((column) {
                      return DataColumn(
                        label: Text(
                          '${column.name}${column.unit.isNotEmpty ? ' (${column.unit})' : ''}',
                        ),
                      );
                    }).toList(),
                    rows: List<DataRow>.generate(
                      tableData.length,
                      (rowIndex) {
                        return DataRow(
                          cells: List<DataCell>.generate(
                            columns.length,
                            (colIndex) {
                              return DataCell(
                                Text(tableData[rowIndex][colIndex]),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
*/
