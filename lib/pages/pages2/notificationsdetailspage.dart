import 'package:collector/pages/models/notification.dart';
import 'package:flutter/material.dart';

class NotificationDetailsPage extends StatelessWidget {
  final NotificationModel notification;
  const NotificationDetailsPage({super.key, required this.notification});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),

        // if you want to add buttons on the app bar you do it here
//actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Subject:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(notification.description),
          const SizedBox(
            height: 16,
          ),
          const Text(
            'Date:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(notification.timestamp.toString()),
          const SizedBox(height: 10,),
          Text(notification.type.toString())
        ]),
      ),
    );
  }
}
