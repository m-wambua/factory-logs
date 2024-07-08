import 'dart:convert';
import 'dart:io';

class Process5Category {
  String name;
  int current;
  String remark;
  Process5Category({
    required this.name,
    required this.current,
    required this.remark,
  });

  factory Process5Category.fromJson(Map<String, dynamic> json) {
    return Process5Category(
        name: json['name'], current: json['current'], remark: json['remark']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'current': current, 'remark': remark};
  }
}

class Process5Entry {
  List<Process5Category> categories;
  DateTime lastUpdate;
  Process5Entry({
    required this.lastUpdate,
    required this.categories,
  });

  factory Process5Entry.fromJson(Map<String, dynamic> json) {
    List<Process5Category> categories = (json['categories'] as List)
        .map((categoryJson) => Process5Category.fromJson(categoryJson))
        .toList();
    return Process5Entry(
        lastUpdate: DateTime.parse(json['lastUpdate']), categories: categories);
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((category) => category.toJson()).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}

class Process5Data {
  List<Process5Entry> process5DataList = [];
  Future<void> loadSubprocess5Data() async {
    try {
      const directory = 'paages/process_1/subprocess_5';
      final file = File('$directory/Subprocess5_data.json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        process5DataList =
            jsonData.map((item) => Process5Entry.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading Subprocess 5 data $e');
    }
  }

  Future<void> savedSubprocess5Data() async {
    try {
      const directory = 'pages/process_1/subprocess_5';
      final file = File('$directory/Subprocess5_data.json');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      // Read existing data of the file already exist
      List<Process5Entry> existingEntries = [];
      String existingJsonString = await file.readAsString();
      if (existingJsonString.isNotEmpty) {
        List<dynamic> existingJsonData = json.decode(existingJsonString);
        existingEntries = existingJsonData
            .map((item) => Process5Entry.fromJson(item))
            .toList();
      }
      // Append new data to existing entries
      existingEntries.addAll(process5DataList);
      //Convert all entries to Json and write to the file with the formatting
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      String jsonString = encoder
          .convert(existingEntries.map((detail) => detail.toJson()).toList());

      await file.writeAsString(jsonString, mode: FileMode.write, flush: true);

      // Clear the current list to avoid duplicating data in the nect save
      process5DataList.clear();
    } catch (e) {
      print('Error saving Subprocess 5 data $e');
    }
  }
}
