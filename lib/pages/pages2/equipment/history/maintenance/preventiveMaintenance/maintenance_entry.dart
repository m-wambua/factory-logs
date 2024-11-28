import 'dart:io';

import 'package:collector/pages/pages2/equipment/history/maintenance/preventiveMaintenance/maintenance_details.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

class MaintenanceEntry {
  String equipment;
  String task;
  DateTime lastUpdate;
  int updateCount;
  String duration;
  String responsiblePerson;
  TaskState taskState;
  List<ChecklistItem> checklistItems;

  MaintenanceEntry({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
    required this.updateCount,
    required this.duration,
    required this.responsiblePerson,
    required this.taskState,
    this.checklistItems = const [],
  });

  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    return MaintenanceEntry(
      equipment: json['equipment'],
      task: json['task'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      updateCount: json['updateCount'],
      duration: json['duration'],
      responsiblePerson: json['responsiblePerson'],
      taskState: TaskState.values[json['taskState']],
      checklistItems: (json['checklistItems'] as List<dynamic>? ?? [])
          .map((item) => ChecklistItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment': equipment,
      'task': task,
      'lastUpdate': lastUpdate.toIso8601String(),
      'updateCount': updateCount,
      'duration': duration,
      'responsiblePerson': responsiblePerson,
      'taskState': taskState.index,
      'checklistItems': checklistItems.map((item) => item.toJson()).toList(),
    };
  }

  static Future<void> saveMaintenanceEntry(
      List<MaintenanceEntry> maintenanceEntry, String equipmentName) async {
    try {
      const baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/history/maintenance/preventiveMaintenance/preventivemaintenancestorage';

      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');

      final equipmentDirPath = path.join(baseDir, sanitizedEquipmentName);
      final equipmentDir = Directory(equipmentDirPath);

      if (!await equipmentDir.exists()) {
        print("Creating equipment folder at: $equipmentDirPath");

        await equipmentDir.create(recursive: true);
        if (await equipmentDir.exists()) {
          print("Equipment folder created successfully");
        } else {
          print("Failed to create equipment folder");
          return;
        }
      }

      final filePath = path.join(
          equipmentDirPath, '${sanitizedEquipmentName}_preventive.json');
      final file = File(filePath);

      final jsonList = maintenanceEntry.map((me) => me.toJson()).toList();

      await file.writeAsString(json.encode(jsonList));
      print('Successfully wrote maintenance entry to: $filePath');
    } catch (e) {
      print('Error saving maintenance entry: $e');
      rethrow;
    }
  }

  static Future<List<MaintenanceEntry>> loadMaintenanceEntry(
      String equipmentName) async {
    try {
      const baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/history/maintenance/preventiveMaintenance/preventivemaintenancestorage';

      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');

      final equipmentDirPath = path.join(baseDir, sanitizedEquipmentName);
      final filePath = path.join(
          equipmentDirPath, '${sanitizedEquipmentName}_preventive.json');
      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();

        final List<dynamic> jsonList = json.decode(contents);
        final maintenanceEntry =
            jsonList.map((me) => MaintenanceEntry.fromJson(me)).toList();
        print("loaded ${maintenanceEntry.length} from file");
        return maintenanceEntry;
      } else {
        print("No existing maintenance file found at: $filePath");
        return [];
      }
    } catch (e) {
      print("Error loading maintenance entry: $e");
      rethrow;
    }
  }

  static Future<void> deleteMaintenanceEntry(String equipmentName) async {
    try {
      const baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/pages2/equipment/history/maintenance/preventiveMaintenance/preventivemaintenancestorage';
      final sanitizedEquipmentName = equipmentName.replaceAll('/', '_');

      final equipmentDirPath = path.join(baseDir, sanitizedEquipmentName);
      final equipmentDir = Directory(equipmentDirPath);

      if (await equipmentDir.exists()) {
        await equipmentDir.delete(recursive: true);
        print("Successfully deleted equipment folder: $equipmentDirPath");
      } else {
        print("Equipment folder does not exist: $equipmentDirPath");
      }
    } catch (e) {
      print("Error deleting maintenance entry: $e");
      rethrow;
    }
  }
}

enum TaskState {
  unactioned,
  inProgress,
  completed,
}
