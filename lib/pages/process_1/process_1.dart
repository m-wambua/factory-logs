import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/process_1/cableSchedule/cablescheduleadd.dart';
import 'package:collector/pages/process_1/codebase/codebase.dart';
import 'package:collector/pages/process_1/codebase/codedetails.dart';
import 'package:collector/pages/process_1/startup.dart';
import 'package:collector/pages/process_1/startuppage.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_1_np.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_2_np.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess_3_np.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_4_np.dart';
import 'package:collector/pages/process_1/subprocess_5/subprocess_5_np.dart';
import 'package:collector/pages/process_1/subprocess_6/subprocess_6_np.dart';
import 'package:collector/pages/process_1/subprocess_7/subprocess_7.dart';
import 'package:collector/pages/process_1/subprocess_7/subprocess_7_np.dart';
import 'package:flutter/material.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_1.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_2.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess_3.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_4.dart';
import 'package:collector/pages/process_1/subprocess_5/subprocess_5.dart';
import 'package:collector/pages/process_1/subprocess_6/subprocess_6.dart';

class Process1Page extends StatefulWidget {
  const Process1Page({super.key});

  @override
  _Process1PageState createState() => _Process1PageState();
}

class _Process1PageState extends State<Process1Page> {
  bool _productionSelected = false;
  DateTime? saveButtonClickTime;
  bool _eventfulShift = false;
  String? _eventDescription;
  final List<NotificationModel> notifications = [];
  StartUpEntryData startUpEntryData = StartUpEntryData();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trimming Cum Tension Leveler Line'),
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.chrome_reader_mode)),
              IconButton(
                  onPressed: () {
                    _showCableScheduleDialog(context);
                  },
                  icon: const Icon(Icons.cable_outlined)),
              IconButton(
                  onPressed: () {
                    _showOptionsDialog(context);
                  },
                  icon: const Icon(Icons.code)),
              IconButton(
                onPressed: () {
                  _addStartUpProcedure(context);
                },
                icon: const Icon(Icons.power_settings_new),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Radio buttons for production selection
              Row(
                children: [
                  Radio(
                    value: true,
                    groupValue: _productionSelected,
                    onChanged: (value) {
                      setState(() {
                        _productionSelected = value!;
                      });
                    },
                  ),
                  const Text('Production'),
                  Radio(
                    value: false,
                    groupValue: _productionSelected,
                    onChanged: (value) {
                      setState(() {
                        _productionSelected = value!;
                      });
                    },
                  ),
                  const Text('No Production'),
                ],
              ),
              const SizedBox(height: 20),
              // Display subprocess buttons only if production was selected
              if (_productionSelected)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess1Page1(
                              onNotificationAdded: (notification) {
                                setState(() {
                                  notifications.add(notification);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text('Drives'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess2Page1(
                              onNotificationAdded: (notification) {
                                setState(() {
                                  notifications.add(notification);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text('MCC Motors'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess3Page1(
                              onNotificationAdded: (notification) {
                                setState(() {
                                  notifications.add(notification);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text('Cranes'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess4Page1(
                              onNotificationAdded: (notification) {
                                setState(() {
                                  notifications.add(notification);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text('TLL Positions (MM)'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess5Page1(
                              onNotificationAdded: (notification) {
                                setState(() {
                                  notifications.add(notification);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text('TLL Crowning Position (MM)'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess6Page1(),
                          ),
                        );
                      },
                      child: const Text('Tensions'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess7Page1(),
                          ),
                        );
                      },
                      child: const Text('Currents'),
                    ),
                    const SizedBox(height: 100),
                    const Text(
                        'ODS Occurrence During Shift (Delay please indicate time)'),
                    TextFormField(
                      maxLines: 20,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          saveButtonClickTime = DateTime.now();
                        });
                      },
                      child: const Text('Save Current Values'),
                    ),
                    if (saveButtonClickTime != null)
                      Text('The data was saved at $saveButtonClickTime'),
                    const SizedBox(height: 30),
                    CheckboxListTile(
                      title: const Text('Was the shift eventful?'),
                      value: _eventfulShift,
                      onChanged: (value) {
                        setState(() {
                          _eventfulShift = value!;
                        });
                      },
                    ),
                    if (_eventfulShift)
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Describe the event....',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _eventDescription = value;
                          });
                        },
                      ),
                  ],
                ),
              if (!_productionSelected)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess1Page1_Np(),
                          ),
                        );
                      },
                      child: const Text('Drives'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess2Page1_Np(),
                          ),
                        );
                      },
                      child: const Text('MCC Motors'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess3Page1_NP(),
                          ),
                        );
                      },
                      child: const Text('Cranes'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess4Page1_NP(),
                          ),
                        );
                      },
                      child: const Text('TLL Positions (MM)'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess5Page1_NP(),
                          ),
                        );
                      },
                      child: const Text('TLL Crowning Position (MM)'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess6Page1_NP(),
                          ),
                        );
                      },
                      child: const Text('Tensions'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess7Page1_NP(),
                          ),
                        );
                      },
                      child: const Text('Currents'),
                    ),
                    const SizedBox(height: 100),
                    const Text(
                        'ODS Occurrence During Shift (Delay please indicate time)'),
                    TextFormField(
                      maxLines: 20,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          saveButtonClickTime = DateTime.now();
                        });
                      },
                      child: const Text('Save Current Values'),
                    ),
                    if (saveButtonClickTime != null)
                      Text('The data was saved at $saveButtonClickTime'),
                    const SizedBox(height: 30),
                    CheckboxListTile(
                      title: const Text('Was the shift eventful?'),
                      value: _eventfulShift,
                      onChanged: (value) {
                        setState(() {
                          _eventfulShift = value!;
                        });
                      },
                    ),
                    if (_eventfulShift)
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Describe the event....',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _eventDescription = value;
                          });
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addStartUpProcedure(BuildContext context) async {
    List<TextEditingController> startUpController = [TextEditingController()];
    TextEditingController lastUpdatePerson = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add/Update Start-Up Procedure for TLL'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 1; i < startUpController.length; i++)
                    TextField(
                      controller: startUpController[i],
                      decoration: InputDecoration(
                        labelText: 'Procedure $i',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.image),
                            ),
                          ],
                        ),
                      ),
                      onChanged: (value) {},
                    ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: lastUpdatePerson,
                    decoration: const InputDecoration(labelText: 'Updated By'),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        startUpController.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            final startUpEntry = StartUpEntry(
                                startupStep: startUpController
                                    .map((controller) => controller.text)
                                    .toList(),
                                lastPersonUpdate: lastUpdatePerson.text,
                                lastUpdate: DateTime.now());

                            startUpEntryData.savingStartUpEntry(startUpEntry);
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('Save')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const StartUpEntriesPage()));
                          },
                          child: const Text('View Saved Start-Up')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget uploadOrNot(BuildContext context) {
    return AlertDialog(
      title: const Text('Code Base Storage'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                //Handle view existing code bases
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExistingCodeBasesPage()));
              },
              child: const Text('View Existing Code Bases')),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog first
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UploadScreen()));
            },
            child: const Text('Upload New Code Bases'),
          ),
        ],
      ),
    );
  }

  Widget uploadCableScheduleorNot(BuildContext context) {
    return AlertDialog(
      title: const Text('Cable Schedule Storage'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close the dialog
                //Handle view  existing cable schedule
              },
              child: const Text('View Existing Cable Schedule')),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close the dialog first
                //Handle the uploading of the cable Schedule
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UploadScreenCableSchedule()));
              },
              child: const Text('Upload New/Updated Cable Schedule'))
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return uploadOrNot(context);
        });
  }

  void _showCableScheduleDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return uploadCableScheduleorNot(context);
        });
  }
}
