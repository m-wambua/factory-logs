import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/pages/processes';
  }

  static Future<File> get _jsonFile async {
    final path = await _localPath;
    final directory = Directory(path);

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return File('$path/processes.json');
  }

  // Save processes and subprocesses to JSON file
  static Future<void> saveProcesses(Map<String, List<String>> data) async {
    final file = await _jsonFile;
    String json = jsonEncode(data);
    await file.writeAsString(json);
  }

  // Load processes and subprocesses from JSON file
  static Future<Map<String, List<String>>> loadProcesses() async {
    try {
      final file = await _jsonFile;
      if (await file.exists()) {
        String json = await file.readAsString();
        Map<String, dynamic> data = jsonDecode(json);
        return data.map((key, value) => MapEntry(key, List<String>.from(value)));
      }
    } catch (e) {
      print("Error loading processes: $e");
    }
    return {};
  }
}
