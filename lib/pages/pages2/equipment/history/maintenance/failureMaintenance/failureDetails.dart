import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FailureDetails {
  String equipment;
  List<FailureTaskDetails> tasks;

  FailureDetails({
    required this.equipment,
    required this.tasks,
  });

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory FailureDetails.fromJson(Map<String, dynamic> json) {
    return FailureDetails(
      equipment: json['equipment'],
      tasks: (json['tasks'] as List)
          .map((taskJson) => FailureTaskDetails.fromJson(taskJson))
          .toList(),
    );
  }
}

class FailureTaskDetails {
  String task;
  DateTime lastUpdate;
  String situationBefore;
  List<String> stepsTaken;
  List<String> toolsUsed;
  bool situationResolved;
  String situationAfter;
  String personResponsible;

  FailureTaskDetails({
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

  factory FailureTaskDetails.fromJson(Map<String, dynamic> json) {
    return FailureTaskDetails(
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

class FailureData {
  List<FailureDetails> FailureDetailsList = [];

  Future<void> loadFailureDetails(String equipmentName) async {
    try {
      const baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/history/maintenance/failureMaintenance/failureeventstorage';

      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');
      final equipmentDirPath = path.join(baseDir, sanitizedEquipmentName);
      final filePath =
          path.join(equipmentDirPath, '${sanitizedEquipmentName}_failure.json');

      final file = File(filePath);
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        FailureDetailsList =
            jsonData.map((item) => FailureDetails.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error loading Failure details: $e');
    }
  }

  Future<void> saveFailureDetails(String equipmentName) async {
    try {
      const baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/history/maintenance/failureMaintenance/failureeventstorage';

      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');
      final equipmentDirPath = path.join(baseDir, sanitizedEquipmentName);
      final equipmentDir = Directory(equipmentDirPath);
      if (!await equipmentDir.exists()) {
        await equipmentDir.create(recursive: true);
      }
      if (await equipmentDir.exists()) {
        print("Created Equipment folder: $equipmentDirPath");
      } else {
        print("Equipment folder already exists: $equipmentDirPath");
        return;
      }

      final filePath =
          path.join(equipmentDirPath, '${sanitizedEquipmentName}_failure.json');
      final file = File(filePath);
      String jsonString = json
          .encode(FailureDetailsList.map((detail) => detail.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving Failure details: $e');
    }
  }
}
