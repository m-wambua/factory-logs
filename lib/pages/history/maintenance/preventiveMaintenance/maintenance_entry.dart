import 'package:collector/pages/history/maintenance/preventiveMaintenance/maintenance_details.dart';


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
}

enum TaskState {
  unactioned,
  inProgress,
  completed,
}
