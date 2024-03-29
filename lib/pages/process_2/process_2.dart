import 'package:collector/pages/process_2/subprocess_1/subprocess_1.dart';
import 'package:collector/pages/process_2/subprocess_2/subprocess_2.dart';
import 'package:collector/pages/process_2/subprocess_3/subprocess_3.dart';
import 'package:collector/pages/process_2/subprocess_4/subprocess_4.dart';
import 'package:collector/pages/process_2/subprocess_5/subprocess_5.dart';
import 'package:collector/pages/process_2/subprocess_6/subprocess_6.dart';
import 'package:flutter/material.dart';

class Process2Page extends StatefulWidget {
  @override
  State<Process2Page> createState() => _Process2PageState();
}

class _Process2PageState extends State<Process2Page> {
  bool _productionSelected = false;
  DateTime? saveButtonClickTime;
  bool _eventfulShift = false;
  String? _eventDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('COLOR COATING LINE'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
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
                  Text('Production'),
                  Radio(
                    value: false,
                    groupValue: _productionSelected,
                    onChanged: (value) {
                      setState(() {
                        _productionSelected = value!;
                      });
                    },
                  ),
                  Text('No Production'),
                ],
              ),
              SizedBox(height: 20),
              // Display subprocess buttons only if production was selected
              if (_productionSelected)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess1Page2(),
                          ),
                        );
                      },
                      child: Text('DRIVES'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess2Page2(),
                          ),
                        );
                      },
                      child: Text('MCC MOTORS'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess3Page2(),
                          ),
                        );
                      },
                      child: Text('CRANES'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess4Page2(),
                          ),
                        );
                      },
                      child: Text('TENSIONS'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess5Page2(),
                          ),
                        );
                      },
                      child: Text('SPEEDS'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess6Page2(),
                          ),
                        );
                      },
                      child: Text('Subprocess 6'),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Text(
                        'ODS Occurence During Shift (Delay please indicate time)'),
                    TextFormField(
                      maxLines: 20,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          filled: true,
                          fillColor: Colors.grey[200]),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            saveButtonClickTime = DateTime.now();
                          });
                        },
                        child: Text('Save Current Values')),
                    if (saveButtonClickTime != null)
                      Text('The data was saved at${saveButtonClickTime}'),

                    SizedBox(
                      height: 30,
                    ),
                    CheckboxListTile(
                        title: Text('Was the shift eventful?'),
                        value: _eventfulShift,
                        onChanged: (value) {
                          setState(() {
                            _eventfulShift = value!;
                          });
                        }),
                    //TextFormField for event description if shift was eventful
                    if (_eventfulShift)
                      TextFormField(
                        decoration: InputDecoration(
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
