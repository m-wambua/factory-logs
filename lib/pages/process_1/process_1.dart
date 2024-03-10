import 'package:flutter/material.dart';
import 'package:collector/pages/process_1/subprocess_1.dart';
import 'package:collector/pages/process_1/subprocess_2.dart';
import 'package:collector/pages/process_1/subprocess_3.dart';
import 'package:collector/pages/process_1/subprocess_4.dart';
import 'package:collector/pages/process_1/subprocess_5.dart';
import 'package:collector/pages/process_1/subprocess_6.dart';

class Process1Page extends StatefulWidget {
  @override
  _Process1PageState createState() => _Process1PageState();
}

class _Process1PageState extends State<Process1Page> {
  bool _productionSelected = false;
  DateTime? saveButtonClickTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Process 1'),
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
                            builder: (context) => SubProcess1Page1(),
                          ),
                        );
                      },
                      child: Text('Subprocess 1'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess2Page1(),
                          ),
                        );
                      },
                      child: Text('Subprocess 2'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess3Page1(),
                          ),
                        );
                      },
                      child: Text('Subprocess 3'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess4Page1(),
                          ),
                        );
                      },
                      child: Text('Subprocess 4'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess5Page1(),
                          ),
                        );
                      },
                      child: Text('Subprocess 5'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess6Page1(),
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
                        if(saveButtonClickTime!=null)
                        Text('The data was saved at${saveButtonClickTime}')
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
