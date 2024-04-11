import 'package:collector/pages/process_1/subprocess_1/subprocess_1_np.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_2_np.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess_3_np.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_4_np.dart';
import 'package:collector/pages/process_1/subprocess_5/subprocess_5_np.dart';
import 'package:collector/pages/process_1/subprocess_6/subprocess_6_np.dart';
import 'package:collector/pages/process_1/subprocess_7/subprocess_7.dart';
import 'package:flutter/material.dart';
import 'package:collector/pages/process_1/subprocess_1/subprocess_1.dart';
import 'package:collector/pages/process_1/subprocess_2/subprocess_2.dart';
import 'package:collector/pages/process_1/subprocess_3/subprocess_3.dart';
import 'package:collector/pages/process_1/subprocess_4/subprocess_4.dart';
import 'package:collector/pages/process_1/subprocess_5/subprocess_5.dart';
import 'package:collector/pages/process_1/subprocess_6/subprocess_6.dart';

class Process1Page extends StatefulWidget {
  @override
  _Process1PageState createState() => _Process1PageState();
}

class _Process1PageState extends State<Process1Page> {
  bool _productionSelected = false;
  DateTime? saveButtonClickTime;
  bool _eventfulShift = false;
  String? _eventDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trimming Cum Tension Leveler Line'),
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

                  //TextField(maxLines: 40,),
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
                      child: Text('Drives'),
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
                      child: Text('CC Motores'),
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
                      child: Text('Cranes'),
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
                      child: Text('TLL Positions (MM)'),
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
                      child: Text('TLL Crowning Position (MM)'),
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
                      child: Text('Tensions'),
                    ),
                    SizedBox(
                      height: 100,
                    ),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess7Page1(),
                          ),
                        );
                      },
                      child: Text('Currents'),
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
                if(!_productionSelected)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess1Page1_Np(),
                          ),
                        );
                      },
                      child: Text('Drives'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess2Page1_Np(),
                          ),
                        );
                      },
                      child: Text('CC Motores'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess3Page1_NP(),
                          ),
                        );
                      },
                      child: Text('Cranes'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess4Page1_NP(),
                          ),
                        );
                      },
                      child: Text('TLL Positions (MM)'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess5Page1_NP(),
                          ),
                        );
                      },
                      child: Text('TLL Crowning Position (MM)'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess6Page1_NP(),
                          ),
                        );
                      },
                      child: Text('Tensions'),
                    ),
                    SizedBox(
                      height: 100,
                    ),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubProcess7Page1(),
                          ),
                        );
                      },
                      child: Text('Currents'),
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
                )
              

            ],
            

          ),
        ),
      ),
    );
  }
}
