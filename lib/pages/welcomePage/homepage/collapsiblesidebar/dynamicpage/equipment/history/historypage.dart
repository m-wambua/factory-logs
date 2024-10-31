import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/history/maintenance/failureMaintenance/failurehistory.dart';
import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/history/maintenance/preventiveMaintenance/maintenancehistory.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<NotificationModel> notifications = [];
  @override
  Widget build(BuildContext context) {
    //Retriev the arguments passed
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;

    //Use the subprocess variable to display relevant data
    return Scaffold(
      appBar: AppBar(
        title:  Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Image.asset(AppAssets.deltalogo),
              ),
              Text('History for $subprocess '),
            ],
          ),
        
       
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          //Display scrollable Excel-like table
          //Implement subpages for failure and maintenance

          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            FailureHistory(subprocess: subprocess)));
              },
              child: const Text('Failure History')),
          const SizedBox(
            height: 30,
          ),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyMaintenanceHistory(
                              subprocess: subprocess,
                              onNotificationAdded: (notification) {
                                setState(() {
                                  notifications.add(notification);
                                });
                              },
                            )));
              },
              child: const Text('Maintenance History')),
        ],
      )),
    );
  }
}
