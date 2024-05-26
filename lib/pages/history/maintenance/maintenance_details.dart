import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MaintenanceDetails {
  String equipment;
  List<MaintenanceTaskDetails> tasks;

  MaintenanceDetails({
    required this.equipment,
    required this.tasks,
  });

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory MaintenanceDetails.fromJson(Map<String, dynamic> json) {
    return MaintenanceDetails(
      equipment: json['equipment'],
      tasks: (json['tasks'] as List)
          .map((taskJson) => MaintenanceTaskDetails.fromJson(taskJson))
          .toList(),
    );
  }
}

class MaintenanceTaskDetails {
  String task;
  DateTime lastUpdate;
  String situationBefore;
  List<String> stepsTaken;
  List<String> toolsUsed;
  bool situationResolved;
  String situationAfter;
  String personResponsible;

  MaintenanceTaskDetails({
    required this.task,
    required this.lastUpdate,
    required this.situationBefore,
    required this.stepsTaken,
    required this.toolsUsed,
    required this.situationResolved,
    required this.situationAfter,
    required this.personResponsible,
  });

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'lastUpdate': lastUpdate.toIso8601String(),
      'situationBefore': situationBefore,
      'stepsTaken': stepsTaken,
      'toolsUsed': toolsUsed,
      'situationResolved': situationResolved,
      'situationAfter': situationAfter,
      'personResponsible': personResponsible,
    };
  }

  factory MaintenanceTaskDetails.fromJson(Map<String, dynamic> json) {
    return MaintenanceTaskDetails(
      task: json['task'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      situationBefore: json['situationBefore'],
      stepsTaken: List<String>.from(json['stepsTaken']),
      toolsUsed: List<String>.from(json['toolsUsed']),
      situationResolved: json['situationResolved'],
      situationAfter: json['situationAfter'],
      personResponsible: json['personResponsible'],
    );
  }
}

class MaintenanceData {
  List<MaintenanceDetails> maintenanceDetailsList = [];

  Future<void> loadMaintenanceDetails() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/maintenance_details.json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        maintenanceDetailsList = jsonData.map((item) => MaintenanceDetails.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading maintenance details: $e');
    }
  }

  Future<void> saveMaintenanceDetails() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/maintenance_details.json');
      String jsonString = json.encode(maintenanceDetailsList.map((detail) => detail.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving maintenance details: $e');
    }
  }
}
