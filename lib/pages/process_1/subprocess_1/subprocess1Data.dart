import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
  List<Process1Category> categories = [];
  DateTime lastUpdate;

  Process1Entry({
    required this.categories,
    required this.lastUpdate,
  });

  factory Process1Entry.fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonCategories = json['categories'];
    List<Process1Category> categories = jsonCategories
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
      final directory = 'pages/process_1/subprocess_1';
      final file = File('${directory}/Subprocess1_data.json');
      
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        process1DataList = jsonData.map((item) => Process1Entry.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading Subprocess 1 data: $e');
    }
  }

  Future<void> saveSubprocess1Data() async {
    try {
      final directory = 'pages/process_1/subprocess_1';
      
      final file = File('${directory}/Subprocess1_data.json');

      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      String jsonString = json.encode(process1DataList.map((detail) => detail.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving Subprocess 1 data: $e');
    }
  }
}


