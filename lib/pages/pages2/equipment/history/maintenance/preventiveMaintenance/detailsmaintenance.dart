import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'maintenance_details.dart';
//import 'maintenance_data.dart'; // Import maintenance data

class MaintenanceDetailsPage extends StatefulWidget {
  final String subprocess;
  const MaintenanceDetailsPage({super.key, required this.subprocess});
  @override
  _MaintenanceDetailsPageState createState() => _MaintenanceDetailsPageState();
}

class _MaintenanceDetailsPageState extends State<MaintenanceDetailsPage> {
  MaintenanceDetails? details; // Declare details as nullable
  MaintenanceData maintenanceData = MaintenanceData();

  @override
  void initState() {
    super.initState();
    loadMaintenanceDetails(); // Load maintenance details when the widget initializes
  }

  Future<void> loadMaintenanceDetails() async {
    await MaintenanceData.loadMaintenanceDetails(
        widget.subprocess); // Load maintenance details from file
    setState(() {
      details = maintenanceData.maintenanceDetailsList.isNotEmpty
          ? maintenanceData.maintenanceDetailsList.first
          : null; // Assign the first details if available, otherwise null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:
       Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Image.asset(AppAssets.deltalogo),
              ),
              const Text('Maintenance Details'),
            ],
          ),
      
     ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: details != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Equipment: ${details!.equipment}'),
                  const SizedBox(
                      height: 16), // Add some space between equipment and tasks
                  Expanded(
                    child: ListView.builder(
                      itemCount: details!.tasks.length,
                      itemBuilder: (BuildContext context, int index) {
                        final task = details!.tasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0), // Adjust the left padding as needed
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: 'Task: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: task.task,
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: 'Last Update:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          DateFormat('yyyy-MM-dd HH:mm:ss').format(task.lastUpdate),
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: 'Situation Before: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: task.situationBefore,
                                    ),
                                  ],
                                ),
                              ),
                              const Text('Steps Taken:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: task.stepsTaken.length,
                                itemBuilder:
                                    (BuildContext context, int stepIndex) {
                                  return Text(
                                      '${stepIndex + 1}. ${task.stepsTaken[stepIndex]}');
                                },
                              ),
                              const Text('Tools Used:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: task.toolsUsed.length,
                                itemBuilder:
                                    (BuildContext context, int toolIndex) {
                                  return Text(
                                      '${toolIndex + 1}. ${task.toolsUsed[toolIndex]}');
                                },
                              ),

                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: 'Situation Resolved: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          task.situationResolved ? 'Yes' : 'No',
                                    ),
                                  ],
                                ),
                              ),

                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: 'Situation After: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: task.situationAfter,
                                    ),
                                  ],
                                ),
                              ),

                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: 'Person Responsible: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: task.personResponsible,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),
                              const Text('Checklist Issued:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: task.checklist.length,
                                itemBuilder:
                                    (BuildContext context, int checklistIndex) {
                                  final checklistItem =
                                      task.checklist[checklistIndex];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${checklistIndex + 1}. ${checklistItem.item}'),
                                      Row(
                                        children: [
                                          const Text('Checked: '),
                                          Checkbox(
                                            value: checklistItem.isChecked,
                                            onChanged: (value) {
                                              // Handle checkbox change if needed
                                            },
                                          ),
                                        ],
                                      ),
                                      Text('Comment: ${checklistItem.comment}'),
                                    ],
                                  );
                                },
                              ),
                              // Add some space between tasks
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const Center(child: Text('No maintenance details available')),
      ),
    );
  }
}
