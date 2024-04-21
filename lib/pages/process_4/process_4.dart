import 'package:collector/pages/process_4/subprocess_1/subprocess_1.dart';
import 'package:collector/pages/process_4/subprocess_2/subprocess_2.dart';
import 'package:collector/pages/process_4/subprocess_3/subprocess_3.dart';
import 'package:collector/pages/process_4/subprocess_4/subprocess_4.dart';
import 'package:collector/pages/process_4/subprocess_5/subprocess_5.dart';
import 'package:collector/pages/process_4/subprocess_6/subprocess_6.dart';
import 'package:flutter/material.dart';

class Process4Page extends StatefulWidget {
  const Process4Page({super.key});

  @override
  State<Process4Page> createState() => _Process4PageState();
}

class _Process4PageState extends State<Process4Page> {
  bool _productionSelected = false;
  DateTime? saveButtonClickTime;
  bool _eventfulShift = false;
  String? _eventDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process 1'),
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
                            builder: (context) => const SubProcess1Page4(),
                          ),
                        );
                      },
                      child: const Text('Subprocess 1'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess2Page4(),
                          ),
                        );
                      },
                      child: const Text('Subprocess 2'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess3Page4(),
                          ),
                        );
                      },
                      child: const Text('Subprocess 3'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess4Page4(),
                          ),
                        );
                      },
                      child: const Text('Subprocess 4'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess5Page4(),
                          ),
                        );
                      },
                      child: const Text('Subprocess 5'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubProcess6Page4(),
                          ),
                        );
                      },
                      child: const Text('Subprocess 6'),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    const Text(
                        'ODS Occurence During Shift (Delay please indicate time)'),
                    TextFormField(
                      maxLines: 20,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          filled: true,
                          fillColor: Colors.grey[200]),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            saveButtonClickTime = DateTime.now();
                          });
                        },
                        child: const Text('Save Current Values')),
                    if (saveButtonClickTime != null)
                      Text('The data was saved at$saveButtonClickTime'),

                    const SizedBox(
                      height: 30,
                    ),
                    CheckboxListTile(
                        title: const Text('Was the shift eventful?'),
                        value: _eventfulShift,
                        onChanged: (value) {
                          setState(() {
                            _eventfulShift = value!;
                          });
                        }),
                    //TextFormField for event description if shift was eventful
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
                      )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
