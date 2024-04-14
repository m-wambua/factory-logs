/*class NotificationModel {
  final String title;
  final String description;
  final DateTime timestamp;
  
  final bool isRead;
  

  NotificationModel({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isRead,
    required this.type
  });

  // Enum to define notification types
  enum NotificationType{
    LogsCollected,
    MaintenanceUpdate,
    // Add more types as needed
  }
}
*/

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
     this.isRead=false,
  });
}

// Enum to define notification types
enum NotificationType {
  LogsCollected,
  MaintenanceUpdate,
  // Add more types as needed
}
