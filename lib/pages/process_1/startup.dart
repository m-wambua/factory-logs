import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class StartUpEntry {
  List<String> startupStep;
  String lastPersonUpdate;
  DateTime lastUpdate;

  StartUpEntry({
    required this.startupStep,
    required this.lastPersonUpdate,
    required this.lastUpdate,
  });

  Map<String, dynamic> toJson() {
    return {
      'startUpStep': startupStep,
      'lastPersonUpdate': lastPersonUpdate,
      'lastUpdate': lastUpdate.toIso8601String()
    };
  }

  factory StartUpEntry.fromJson(Map<String, dynamic> json) {
    return StartUpEntry(
        startupStep: List<String>.from(json['startUpStep']),
        lastPersonUpdate: json['lastPersonUpdate'],
        lastUpdate: DateTime.parse(json['lastUpdate']));
  }
}

class StartUpEntryData {
  List<StartUpEntry> startupData = [];
  Future<void> savingStartUpEntry(StartUpEntry newEntry) async {
    try {
      const directory = 'pages/models/process_1/start_up';
      final file = File('$directory/startup.json');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      // Read existing data if the file already exists
      List<StartUpEntry> existingStartUp = [];
      if (await file.exists()) {
        String existingJsonString = await file.readAsString();
        if (existingJsonString.isNotEmpty) {
          List<dynamic> existingJsonData = json.decode(existingJsonString);
          existingStartUp = existingJsonData
              .map((item) => StartUpEntry.fromJson(item))
              .toList();
        }
      }
      // Add the new entry to the list
      startupData.add(newEntry);
      //Append new data to existing entries
      existingStartUp.addAll(startupData);
      // Convert all entries to Json and write to the file with formatting
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');

      String jsonString = encoder
          .convert(startupData.map((detail) => detail.toJson()).toList());

      await file.writeAsString(jsonString, mode: FileMode.write, flush: true);
      // Clear the current list to avoid duplicating data in the next save
      startupData.clear();
    } catch (e) {
      print(' error Saving Start Up Procedure details: $e');
    }
  }

  Future<void> loadStartUpEntry() async {
    try {
        final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/startup.json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        startupData =
            jsonData.map((item) => StartUpEntry.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error Loading Start up Entry details: $e');
    }
  }
}
