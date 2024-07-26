import 'dart:convert';
import 'dart:io';
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
  List<ChecklistItem> checklist;

  MaintenanceTaskDetails({
    required this.task,
    required this.lastUpdate,
    required this.situationBefore,
    required this.stepsTaken,
    required this.toolsUsed,
    required this.situationResolved,
    required this.situationAfter,
    required this.personResponsible,
    required this.checklist,
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
      'checklist': checklist.map((item) => item.toJson()).toList(),
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
      checklist: (json['checklist'] as List)
          .map((item) => ChecklistItem.fromJson(item))
          .toList(),
    );
  }
}

class ChecklistItem {
  String item;
  bool isChecked;
  String comment;

  ChecklistItem({
    required this.item,
    required this.isChecked,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'isChecked': isChecked,
      'comment': comment,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      item: json['item'],
      isChecked: json['isChecked'],
      comment: json['comment'],
    );
  }
}

class MaintenanceData {
  List<MaintenanceDetails> maintenanceDetailsList = [];

  Future<void> loadMaintenanceDetails(String subprocess) async {
    /*
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$subprocess/maintenance_details.json');

      if (await file.exists()) {
        print('File exists: ${file.path}');
        String jsonString = await file.readAsString();
        print('File content: $jsonString');
        
        List<dynamic> jsonData = json.decode(jsonString);
        maintenanceDetailsList = jsonData
            .map((item) => MaintenanceDetails.fromJson(item))
            .toList();
        print('Loaded maintenance details: $maintenanceDetailsList');
      } else {
        print('File does not exist: ${file.path}');
      }
    } catch (e) {
      print('Error loading maintenance details: $e');
    }*/

    try {
      final directory = await getApplicationCacheDirectory();
      final file =
          File('${directory.path}/$subprocess/maintenance_details.json');
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        maintenanceDetailsList =
            jsonData.map((item) => MaintenanceDetails.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error Loading Failure details $e');
    }
  }

  Future<void> saveMaintenanceDetails(String subprocess) async {
    /*try {
      final directory = await getApplicationDocumentsDirectory();
      final file =
          File('${directory.path}/$subprocess/maintenance_details.json');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }

      // Read existing data from file, if any
      List<MaintenanceDetails> existingDetails = [];
      if (await file.exists()) {
        String jsonString = await file.readAsString();
        List<dynamic> jsonData = json.decode(jsonString);
        existingDetails =
            jsonData.map((item) => MaintenanceDetails.fromJson(item)).toList();
      }

      // Merge existing details with current maintenanceDetailsList
      Set<String> existingEquipments =
          existingDetails.map((detail) => detail.equipment).toSet();
      for (var newDetail in maintenanceDetailsList) {
        if (!existingEquipments.contains(newDetail.equipment)) {
          existingDetails.add(newDetail); // Add new detail
        } else {
          // Update existing detail
          int index = existingDetails
              .indexWhere((detail) => detail.equipment == newDetail.equipment);
          if (index != -1) {
            existingDetails[index] = newDetail;
          }
        }
      }

      // Convert all entries to JSON and write to the file with formatting
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      String jsonString = encoder
          .convert(existingDetails.map((detail) => detail.toJson()).toList());
      await file.writeAsString(jsonString, mode: FileMode.write, flush: true);
    } catch (e) {
      print('Error saving maintenance details: $e');
    }*/

    try {
      final directory = await getApplicationCacheDirectory();
      final file =
          File('${directory.path}/$subprocess/maintenance_details.json');
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      String jsonString = json.encode(
          maintenanceDetailsList.map((detail) => detail.toJson()).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving Maintenance details (maintenance data) $e');
    }
  }
}
