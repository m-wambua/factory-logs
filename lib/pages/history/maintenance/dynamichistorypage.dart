import 'package:collector/pages/history/maintenance/failureMaintenance/failurehistory.dart';
import 'package:collector/pages/history/maintenance/preventiveMaintenance/maintenancehistory.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:flutter/material.dart';

class DynamicHistoryPage extends StatefulWidget {
  final String equipmentName;
  const DynamicHistoryPage({super.key, required this.equipmentName});

  @override
  State<DynamicHistoryPage> createState() => _DynamicHistoryPageState();
}

class _DynamicHistoryPageState extends State<DynamicHistoryPage> {
  final List<NotificationModel> notifications = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Maintenance History for ${widget.equipmentName}'),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FailureHistory(
                                subprocess: widget.equipmentName)));
                  },
                  child: Text('Failure History')),
              SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyMaintenanceHistory(
                                subprocess: widget.equipmentName,
                                onNotificationAdded: (notification) {
                                  setState(() {
                                    notifications.add(notification);
                                  });
                                })));
                  },
                  child: Text('Preventive Maintenance History'))
            ],
          ),
        ));
  }
}
