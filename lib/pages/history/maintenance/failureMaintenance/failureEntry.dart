import 'dart:convert';

import 'package:collector/pages/history/maintenance/preventiveMaintenance/maintenance_details.dart';
import 'package:collector/pages/history/maintenance/preventiveMaintenance/maintenancehistory.dart';

class FailureEntry {
  String equipment;
  String task;
  DateTime lastUpdate;
  int updateCount;
  String duration;
  String responsiblePerson;
  TaskState taskState;

  FailureEntry({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
    required this.updateCount,
    required this.duration,
    required this.responsiblePerson,
    required this.taskState,
  });

  factory FailureEntry.fromJson(Map<String, dynamic> json) {
    return FailureEntry(
      equipment: json['equipment'],
      task: json['task'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      updateCount: json['updateCount'],
      duration: json['duration'],
      responsiblePerson: json['responsiblePerson'],
      taskState: TaskState.values[json['taskState']],
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
    );
  }
}

enum TaskState {
  unactioned,
  inProgress,
  completed,
}
