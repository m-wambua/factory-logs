import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/notificationsdetailspage.dart';
import 'package:flutter/material.dart';
//import 'package:collector/models/notification.dart'; // Import the notification model

/*
class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel> notifications = []; // List to store notifications

  @override
  void initState() {
    super.initState();
    // Fetch notifications from database, API, or local storage
    fetchNotifications();
  }

  void fetchNotifications() {
    // Mock data for demonstration
    setState(() {
      notifications = [
        NotificationModel(
          title: 'Notification 1',
          description: 'This is notification 1',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        NotificationModel(
          title: 'Notification 2',
          description: 'This is notification 2',
          timestamp: DateTime.now().subtract(Duration(days: 1)),
          isRead: true,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          NotificationModel notification = notifications[index];
          return ListTile(
            title: Text(notification.title),
            subtitle: Text(notification.description),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Implement logic to delete notification
                setState(() {
                  notifications.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement logic to clear all notifications
          setState(() {
            notifications.clear();
          });
        },
        child: Icon(Icons.clear_all),
      ),
    );
  }
}
*/

class NotificationsPage extends StatefulWidget {
  final List<NotificationModel> notifications;
  const NotificationsPage({super.key, required this.notifications});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: () {
              _showDeleteAllConfirmationDialog(context);
            },
            icon: const Icon(Icons.delete_forever),
          )
        ],
      ),
      body: ListView.builder(
          itemCount: widget.notifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationCard(context, widget.notifications[index]);
          }),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, NotificationModel notification) {
    return Card(
        child: ListTile(
      title: Row(
        children: [
          // Display different icons based on the seen status
          Icon(
            notification.isRead ? Icons.done_all : Icons.done_all_outlined,
            color: notification.isRead
                ? Colors.blue
                : null, // turn blue for seen notifications
          ),
          const SizedBox(
            width: 10,
          ),
          Text(notification.title),
        ],
      ),
      subtitle: Text(notification.description),
      
      onTap: () {
        _showNotificationDetailsPage(context, notification);
        setState(() {
          notification.isRead = true;
        });
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          _showDeleteConfirmationDialog(context, notification);
        },
      ),
    ));
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, NotificationModel notification) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text('Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _deleteNotification(
                      context, notification);
                },
                child: const Text('Delete'),
              )
            ],
          );
        });
  }

  void _deleteNotification(
      BuildContext context, NotificationModel notification) {
    // Find the index of the notification in the list
    int index = widget.notifications.indexOf(notification);
    // remove the notification from the list
    if (index != -1) {
      setState(() {
        widget.notifications.removeAt(index);
      });
      //Close the confirmation dialog
      Navigator.pop(context);
    }
  }

  void _showNotificationDetailsPage(
      BuildContext context, NotificationModel notification) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NotificationDetailsPage(notification: notification),
        ));
    
  }

  void _deleteAllNotifications(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete All Notifications'),
            content: const Text('Are you sure you want to delete all notifications?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                  onPressed: () {
                    // Clear the list of notifications
                    setState(() {
                      widget.notifications.clear();
                    });
                    // close the confirmation dialog
                    Navigator.pop(context);
                  },
                  child: const Text('Delete All'))
            ],
          );
        });
  }

  void _showDeleteAllConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete All Notifications'),
          content: const Text('Are you sure you want to delete all notifications?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteAllNotifications(context);
              },
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }
}