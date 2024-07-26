import 'dart:convert';
import 'dart:io';

class Process3Category {
  String name;
  int current;
  String remark;
  Process3Category({
    required this.name,
    required this.current,
    required this.remark,
  });

  factory Process3Category.fromJson(Map<String, dynamic> json) {
    return Process3Category(
        name: json['name'], 
        current: json['current'], 
        remark: json['remark']);
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'current': current,
      'remark': remark
      };
  }
}

class Process3Entry {
  List<Process3Category> categories;
  DateTime lastUpdate;
  Process3Entry({
    required this.categories, 
    required this.lastUpdate});

  factory Process3Entry.fromJson(Map<String, dynamic> json) {
    List<Process3Category> categories = (json['categories'] as List)
        .map((categoryJson) => Process3Category.fromJson(categoryJson))
        .toList();
    return Process3Entry(
        categories: categories,
        lastUpdate: DateTime.parse(json['lastUpdate']));
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((category) => category.toJson()).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}

class Process3Data {
  List<Process3Entry> process3DataList = [];
  Future<void> loadSubproecc3Data() async {
    try {
      const directory = 'pages/process_1/subprocess_3';
      final file = File('$directory/Subprocess3_data.json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        process3DataList =
            jsonData.map((item) => Process3Entry.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading Subprocess 3 data$e');
    }
  }

  Future<void> saveSubprocess3Data() async {
    try {
      const directory = 'pages/process_1/subprocess_3';
      final file = File('$directory/Subprocess3_data.json');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      // Read existing data of the file already exists
      List<Process3Entry> existingEntries = [];
      if (await file.exists()) {
        String existingJsonString = await file.readAsString();
        if (existingJsonString.isNotEmpty) {
          List<dynamic> existingJsonData = json.decode(existingJsonString);
          existingEntries = existingJsonData
              .map((item) => Process3Entry.fromJson(item))
              .toList();
        }
      }
      // Append new data to existing entries
      existingEntries.addAll(process3DataList);
      // Convert all entries to JSON and write to the file with formatting
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      String jsonString = encoder
          .convert(existingEntries.map((detail) => detail.toJson()).toList());
      await file.writeAsString(jsonString, mode: FileMode.write, flush: true);

      // Clear the current list to avoid duplicating data in the next save
      process3DataList.clear();
    } catch (e) {
      print('Error saving Subprocess 3 data$e');
    }
  }
}
