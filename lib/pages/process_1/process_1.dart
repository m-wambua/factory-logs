import 'package:collector/pages/models/notification.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trimming Cum Tension Leveler Line'),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _addStartUpProcedure(context);
                },
                icon: Icon(Icons.power_settings_new),
              ),
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
                            builder: (context) => const SubProcess2Page1(),
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
                            builder: (context) => const SubProcess3Page1(),
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
                            builder: (context) => const SubProcess4Page1(),
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
                            builder: (context) => const SubProcess5Page1(),
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
                    const SizedBox(height: 100),
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
                    const SizedBox(height: 100),
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
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add/Update Start-Up Procedure for TLL'),
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
                              icon: Icon(Icons.image),
                            ),
                          ],
                        ),
                      ),
                      onChanged: (value) {},
                    ),
                  SizedBox(height: 5),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        startUpController.add(TextEditingController());
                      });
                    },
                    icon: Icon(Icons.add),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed: () {}, child: Text('Save')),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
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
}
