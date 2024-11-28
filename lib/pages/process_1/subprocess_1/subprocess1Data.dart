import 'dart:convert';
import 'dart:io';

class Process1Category {
  String name;
  int current;
  String remark;

  Process1Category({
    required this.name,
    required this.current,
    required this.remark,
  });

  factory Process1Category.fromJson(Map<String, dynamic> json) {
    return Process1Category(
      name: json['name'],
      current: json['current'],
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'current': current,
      'remark': remark,
    };
  }
}

class Process1Entry {
  List<Process1Category> categories;
  DateTime lastUpdate;

  Process1Entry({
    required this.categories,
    required this.lastUpdate,
  });

  factory Process1Entry.fromJson(Map<String, dynamic> json) {
    List<Process1Category> categories = (json['categories'] as List)
        .map((categoryJson) => Process1Category.fromJson(categoryJson))
        .toList();

    return Process1Entry(
      categories: categories,
      lastUpdate: DateTime.parse(json['lastUpdate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((category) => category.toJson()).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}

class Process1Data {
  List<Process1Entry> process1DataList = [];

  Future<void> loadSubprocess1Data() async {
    try {
      const directory = 'pages/process_1/subprocess_1';
      final file = File('$directory/Subprocess1_data.json');

      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        process1DataList =
            jsonData.map((item) => Process1Entry.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading Subprocess 1 data: $e');
    }
  }

  Future<void> saveSubprocess1Data() async {
    try {
      const directory = 'pages/process_1/subprocess_1';
      final file = File('$directory/Subprocess1_data.json');

      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      // Read existing data if the file already exists
      List<Process1Entry> existingEntries = [];
      if (await file.exists()) {
        String existingJsonString = await file.readAsString();
        if (existingJsonString.isNotEmpty) {
          List<dynamic> existingJsonData = json.decode(existingJsonString);
          existingEntries = existingJsonData
              .map((item) => Process1Entry.fromJson(item))
              .toList();
        }
      }

      // Append new data to existing entries
      existingEntries.addAll(process1DataList);

      // Convert all entries to JSON and write to the file with formatting
      JsonEncoder encoder = const JsonEncoder.withIndent('  ');
      String jsonString = encoder
          .convert(existingEntries.map((detail) => detail.toJson()).toList());
      await file.writeAsString(jsonString, mode: FileMode.write, flush: true);

      // Clear the current list to avoid duplicating data in the next save
      process1DataList.clear();
    } catch (e) {
      print('Error saving Subprocess 1 data: $e');
    }
  }
}
