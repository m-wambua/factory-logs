import 'dart:convert';
import 'dart:io';

class Process4Category {
  String name;
  int current;
  String remark;
  Process4Category({
    required this.name,
    required this.current,
    required this.remark,
  });

  factory Process4Category.fromJson(Map<String, dynamic> json) {
    return Process4Category(
        name: json['name'], current: json['current'], remark: json['remark']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'current': current, 'remark': remark};
  }
}

class Process4Entry {
  List<Process4Category> categories;
  DateTime lastUpdate;
  Process4Entry({
    required this.lastUpdate,
    required this.categories,
  });

  factory Process4Entry.fromJson(Map<String, dynamic> json) {
    List<Process4Category> categories = (json['categories'] as List)
        .map((categoryJson) => Process4Category.fromJson(categoryJson))
        .toList();
    return Process4Entry(
        lastUpdate: DateTime.parse(json['lastUpdate']), categories: categories);
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((category) => category.toJson()).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}

class Process4Data {
  List<Process4Entry> process4DataList = [];
  Future<void> loadSubprovess4Data() async {
    try {
      final directory = 'pages/process_1/subprocess_4';
      final file = File('$directory/Subprocess4_data,json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        process4DataList =
            jsonData.map((item) => Process4Entry.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading Subprocess 4 data $e');
    }
  }

  Future<void> saveSUbprocess4Data() async {
    try {
      final directory = 'pages/process_1/subproces_4';
      final file = File('$directory/Subprocess4_data.json');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      // Read existing data of the file already exists
      List<Process4Entry> existingEntries = [];
      String existingJsonString = await file.readAsString();
      if (existingJsonString.isNotEmpty) {
        List<dynamic> existingJsonData = json.decode(existingJsonString);
        existingEntries = existingJsonData
            .map((item) => Process4Entry.fromJson(item))
            .toList();
      }
      // append new data to existing entries
      existingEntries.addAll(process4DataList);
      //COnvert all entries to Json and write to the file with formatting
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      String jsonString = encoder
          .convert(existingEntries.map((detail) => detail.toJson()).toList());
      await file.writeAsString(jsonString, mode: FileMode.write, flush: true);
      // clear the current list to avoid duplicating data in the next save
      process4DataList.clear();
    } catch (e) {
      print('Error saving Subprocess 4 data$e');
    }
  }
}
