import 'package:collector/pages/models/notification.dart';
import 'package:flutter/material.dart';

class NotificationDetailsPage extends StatelessWidget {
  final NotificationModel notification;
  const NotificationDetailsPage({Key? key, required this.notification})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Details'),

        // if you want to add buttons on the app bar you do it here
//actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Subject:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8,
          ),
          Text(notification.description),
          SizedBox(
            height: 16,
          ),
          Text(
            'Date:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(notification.timestamp.toString()),
          SizedBox(height: 10,),
          Text(notification.type.toString())
        ]),
      ),
    );
  }
}
