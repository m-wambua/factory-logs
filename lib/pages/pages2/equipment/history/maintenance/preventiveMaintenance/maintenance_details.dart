import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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

  static Future<List<MaintenanceDetails>> loadMaintenanceDetails(
      String equipmentName) async {
    try {
      const baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/history/maintenance/preventiveMaintenance/preventivemaintenancestorage';

      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');

      final equipmentDirPath = path.join(baseDir, sanitizedEquipmentName);
      final filePath = path.join(equipmentDirPath,
          '${sanitizedEquipmentName}_maintenancedetails.json');
      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        final maintenanceList =
            jsonList.map((json) => MaintenanceDetails.fromJson(json)).toList();
        print("loaded ${maintenanceList.length} from file");
        return maintenanceList;
      } else {
        print("no existing maintenance list found at $filePath");
        return [];
      }
    } catch (e) {
      print("Error loading maintenance details");
      rethrow;
    }
  }

  static Future<void> saveMaintenanceDetails(
      String equipmentName, List<MaintenanceDetails> maintenanceList) async {
    try {
      const baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/history/maintenance/preventiveMaintenance/preventivemaintenancestorage';

      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');

      final equipmentDirPath = path.join(baseDir, sanitizedEquipmentName);
      final equipmentDir = Directory(equipmentDirPath);
      if (!await equipmentDir.exists()) {
        print("creating directory $equipmentDirPath");
        await equipmentDir.create(recursive: true);
        if (await equipmentDir.exists()) {
          print("directory created");
        } else {
          print("directory creation failed");
          return;
        }
      }

      final filePath = path.join(equipmentDirPath,
          '${sanitizedEquipmentName}_maintenancedetails.json');
      final file = File(filePath);
      final jsonList = maintenanceList.map((e) => e.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      print("Successfully wrote ${maintenanceList.length} to file $filePath");
    } catch (e) {
      print("Error saving maintenance details");
      rethrow;
    }
  }
}
