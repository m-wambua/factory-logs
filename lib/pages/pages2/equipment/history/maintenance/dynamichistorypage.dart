import 'package:collector/pages/pages2/equipment/history/maintenance/failureMaintenance/failurehistory.dart';
import 'package:collector/pages/pages2/equipment/history/maintenance/preventiveMaintenance/maintenancehistory.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/pages2/equipment/history/maintenance/preventiveMaintenance/preventivemaintanancetable.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';

class DynamicHistoryPage extends StatefulWidget {
  final String equipmentName;
  final String processName;
  final String subprocessName;
  const DynamicHistoryPage(
      {super.key,
      required this.processName,
      required this.subprocessName,
      required this.equipmentName});

  @override
  State<DynamicHistoryPage> createState() => _DynamicHistoryPageState();
}

class _DynamicHistoryPageState extends State<DynamicHistoryPage> {
  final List<NotificationModel> notifications = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Image.asset(AppAssets.deltalogo),
              ),
              Text(
                  'Maintenance History for ${widget.equipmentName} for process ${widget.processName} and subprocess ${widget.subprocessName}'),
            ],
          ),
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
                                subprocess: widget.subprocessName,
                                processName: widget.processName,
                                equipmentName: widget.equipmentName)));
                  },
                  child: const Text('Failure History')),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyMaintenanceHistory(
                                equipmentName: widget.equipmentName,
                                subprocess: widget.subprocessName,
                                processName: widget.processName,
                                onNotificationAdded: (notification) {
                                  setState(() {
                                    notifications.add(notification);
                                  });
                                })));
                  },
                  child: const Text('Preventive Maintenance History')),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MaintenanceTablePage(equipmentName: widget.equipmentName,
                            subprocessName:widget.subprocessName, processName: widget.processName)));
                  },
                  child: Text("Preventive Maintenance (2)"))
            ],
          ),
        ));
  }
}
