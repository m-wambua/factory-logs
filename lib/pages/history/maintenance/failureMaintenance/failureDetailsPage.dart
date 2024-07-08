import 'package:collector/pages/history/maintenance/failureMaintenance/failureDetails.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'Failure_details.dart';
//import 'Failure_data.dart'; // Import Failure data

class FailureDetailsPage extends StatefulWidget {
  const FailureDetailsPage({super.key});

  @override
  _FailureDetailsPageState createState() => _FailureDetailsPageState();
}

class _FailureDetailsPageState extends State<FailureDetailsPage> {
  FailureDetails? details; // Declare details as nullable
  FailureData failureData = FailureData();

  @override
  void initState() {
    super.initState();
    loadFailureDetails(); // Load Failure details when the widget initializes
  }

  Future<void> loadFailureDetails() async {
    await failureData
        .loadFailureDetails(); // Load Failure details from file
    setState(() {
      details = failureData.FailureDetailsList.isNotEmpty
          ? failureData.FailureDetailsList.first
          : null; // Assign the first details if available, otherwise null
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Failure Details')),
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

                              const SizedBox(
                                  height: 16), // Add some space between tasks
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const Center(child: Text('No Failure details available')),
      ),
    );
  }
}
