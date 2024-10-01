import 'dart:convert';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/history/maintenance/preventiveMaintenance/maintenance_details.dart';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/history/maintenance/preventiveMaintenance/maintenancehistory.dart';

class MaintenanceEntry {
  String equipment;
  String task;
  DateTime lastUpdate;
  int updateCount;
  String duration;
  String responsiblePerson;
  TaskState taskState;
  List<ChecklistItem> checklistItems; // Updated to List<ChecklistItem>

  MaintenanceEntry({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
    required this.updateCount,
    required this.duration,
    required this.responsiblePerson,
    required this.taskState,
    this.checklistItems = const [], // Updated default value
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
      checklistItems: (json['checklistItems'] as List)
          .map((item) => ChecklistItem.fromJson(item))
          .toList(), // Parse checklist items from JSON
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
      'checklistItems': checklistItems.map((item) => item.toJson()).toList(), // Convert checklist items to JSON
    };
  }

  MaintenanceTaskDetails toMaintenanceTaskDetails() {
    return MaintenanceTaskDetails(
      task: task,
      lastUpdate: lastUpdate,
      situationBefore: '',
      stepsTaken: [],
      toolsUsed: [],
      situationResolved: false,
      situationAfter: '',
      personResponsible: responsiblePerson,
      checklist: checklistItems, // Include checklist items
    );
  }
}

enum TaskState {
  unactioned,
  inProgress,
  completed,
}
