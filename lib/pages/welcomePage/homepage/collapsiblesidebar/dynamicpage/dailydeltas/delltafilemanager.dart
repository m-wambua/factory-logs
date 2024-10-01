import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DeltaFileManager {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/pages/processes/deltas';
  }

  static Future<File> get _jsonFile async {
    final path = await _localPath;
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('$path/deltas.json');
  }

  // Save process and subdeltas to the JSON file
  static Future<void> saveProcessAndSubdeltas(
      String processName, List<String> subdeltas) async {
    try {
      final file = await _jsonFile;
      // Load existing deltas
      Map<String, List<String>> existingDeltas = await loadDeltas();
      // Update or add the new process and subdeltas
      existingDeltas[processName] = subdeltas;
      // Save the updated deltas
      String json = jsonEncode(existingDeltas);
      await file.writeAsString(json);
    } catch (e) {
      print('Error saving deltas: $e');
    }
  }

  // Load deltas (process and subdeltas) from the JSON file
  static Future<Map<String, List<String>>> loadDeltas() async {
    try {
      final file = await _jsonFile;
      if (await file.exists()) {
        String json = await file.readAsString();
        Map<String, dynamic> data = jsonDecode(json);
        return data.map((key, value) => MapEntry(
            key, (value as List<dynamic>).map((e) => e.toString()).toList()));
      }
    } catch (e) {
      print('Error loading deltas: $e');
    }
    return {};
  }

  // Load a specific process's subdeltas
  static Future<List<String>?> loadSubdeltasForProcess(
      String processName) async {
    Map<String, List<String>> deltas = await loadDeltas();
    return deltas[processName];
  }

  // In DeltaFileManager class
  static Future<void> saveDeltas(Map<String, List<String>> data) async {
    final file = await _jsonFile;
    String json = jsonEncode(data);
    await file.writeAsString(json);
  }
}
