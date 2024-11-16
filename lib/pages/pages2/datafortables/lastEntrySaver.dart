import 'package:collector/pages/pages2/subprocesscreator.dart';

class SavedDataCard {
  final String subprocessName;
  final String timestamp;
  final List<ColumnInfo> columns;
  final List<List<String>> tableData;

  SavedDataCard({
    required this.subprocessName,
    required this.timestamp,
    required this.columns,
    required this.tableData,
  });

  factory SavedDataCard.fromMap(String subprocessName, Map<String, dynamic> map) {
    List<dynamic> columnsJson = map['columns'] ?? [];
    List<dynamic> tableDataJson = map['tableData'] ?? [];

    List<ColumnInfo> columns = columnsJson.map((columnJson) {
      return ColumnInfo(
        name: columnJson['name'],
        type: ColumnDataType.values[columnJson['type']],
        isFixed: columnJson['isFixed'],
        unit: columnJson['unit'] ?? '',
      );
    }).toList();

    List<List<String>> tableData = tableDataJson.map((row) {
      return (row as List<dynamic>).map((cell) => cell.toString()).toList();
    }).toList();

    return SavedDataCard(
      subprocessName: subprocessName,
      timestamp: map['timestamp'] ?? 'Unknown',
      columns: columns,
      tableData: tableData,
    );
  }
}