import 'dart:convert';
import 'dart:io';

class Process2Category {
  String name;
  int current;
  String remark;

  Process2Category({
    required this.name,
    required this.current,
    required this.remark,
  });

  factory Process2Category.fromJson(Map<String, dynamic> json) {
    return Process2Category(
        name: json['name'], current: json['current'], remark: json['remark']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'current': current,
      'remark': remark,
    };
  }
}

class Process2Entry {
  List<Process2Category> categories;
  DateTime lastUpdate;
  Process2Entry({
    required this.categories,
    required this.lastUpdate,
  });

  factory Process2Entry.fromJson(Map<String, dynamic> json) {
    List<Process2Category> categories = (json['categories'] as List)
        .map((categoryJson) => Process2Category.fromJson(categoryJson))
        .toList();

    return Process2Entry(
        categories: categories, lastUpdate: DateTime.parse(json['lastUpdate']));
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((category) => category.toJson()).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}

class Process2Data {
  List<Process2Entry> process2DataList = [];
  Future<void> loadSubprocess2Data() async {
    try {
      final directory = 'pages/process_1/subprocess_2';
      final file = File('$directory/Subprocess2_data.json');

      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        process2DataList =
            jsonData.map((item) => Process2Entry.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading Subprocess 2 data $e');
    }
  }

  Future<void> saveSubprocess2Data() async {
    try {
      final directory = 'pages/process_2/subprocess_2';
      final file = File('$directory/Subprocess1_data.json');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      // Read existing data if the file already exists
      List<Process2Entry> existingEntries = [];
      if (await file.exists()) {
        String existingJsonString = await file.readAsString();
        if (existingJsonString.isNotEmpty) {
          List<dynamic> existingJsonData = json.decode(existingJsonString);
          existingEntries = existingJsonData
              .map((item) => Process2Entry.fromJson(item))
              .toList();
        }
      }
      // Append new data to existing entries
      existingEntries.addAll(process2DataList);
      // Convert all entries to Json and write to the file with formatiing
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      String jsonString = encoder
          .convert(existingEntries.map((detail) => detail.toJson()).toList());
      await file.writeAsString(jsonString, mode: FileMode.write, flush: true);

      //clear the current list to avoid duplication data in the next save
      process2DataList.clear();
    } catch (e) {
      print('Error saving Subprocess 2 data $e');
    }
  }
}
