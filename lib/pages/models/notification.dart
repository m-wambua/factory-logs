import 'dart:convert';
import 'dart:io';

class NotificationModel {
  final String title;
  final String description;
  final DateTime timestamp;
  final NotificationType type; // Enum to differentiate notification types
  bool isRead;

  // Constructor
  NotificationModel({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  // Convert NotificationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'isRead': isRead,
    };
  }

  // Create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      type: _parseNotificationType(json['type']),
      isRead: json['isRead'],
    );
  }

  // Helper function to parse NotificationType from String
  static NotificationType _parseNotificationType(String typeString) {
    switch (typeString) {
      case 'NotificationType.LogsCollected':
        return NotificationType.LogsCollected;
      case 'NotificationType.MaintenanceUpdate':
        return NotificationType.MaintenanceUpdate;
      case ' NotificationType.LogsSubmitted':
        return NotificationType.LogsSubmitted;
      default:
        throw ArgumentError('Invalid notification type: $typeString');
    }
  }
}

// Enum to define notification types
enum NotificationType {
  LogsCollected,
  MaintenanceUpdate,
  LogsSubmitted
  // Add more types as needed
}

// Function to save notifications to a JSON file
Future<void> saveNotificationsToFile(
    List<NotificationModel> notifications) async {
  try {
    final file =
        File('pages/models/notifications.json'); // Provide the full file path
    // Create the file if it doesn't exist
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    final jsonList =
        notifications.map((notification) => notification.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  } catch (e) {
    // Handle file write error
    print('Error saving notifications: $e');
  }
}

// Function to load notifications from a JSON file
Future<List<NotificationModel>> loadNotificationsFromFile() async {
  try {
    final file =
        File('pages/models/notifications.json'); // Provide the full file path
    if (!file.existsSync()) {
      return [];
    }
    final jsonString = await file.readAsString();
    final jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList.map((json) => NotificationModel.fromJson(json)).toList();
  } catch (e) {
    // Handle file read error
    print('Error loading notifications: $e');
    return [];
  }
}
