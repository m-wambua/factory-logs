import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SavedValues {
  String uncoilertm1 = '';
  String uncoilertm2 = '';
  String uncoilertm3 = '';
  String uncoilertm4 = '';
  String uncoilertm5 = '';
  String uncoilertm6 = '';

  String briddle1atm1 = '';
  String briddle1atm2 = '';
  String briddle1atm3 = '';
  String briddle1atm4 = '';
  String briddle1atm5 = '';
  String briddle1atm6 = '';

  String briddle1btm1 = '';
  String briddle1btm2 = '';
  String briddle1btm3 = '';
  String briddle1btm4 = '';
  String briddle1btm5 = '';
  String briddle1btm6 = '';

  String briddle2atm1 = '';
  String briddle2atm2 = '';
  String briddle2atm3 = '';
  String briddle2atm4 = '';
  String briddle2atm5 = '';
  String briddle2atm6 = '';

  String briddle2btm1 = '';
  String briddle2btm2 = '';
  String briddle2btm3 = '';
  String briddle2btm4 = '';
  String briddle2btm5 = '';
  String briddle2btm6 = '';

  String recoilertm1 = '';
  String recoilertm2 = '';
  String recoilertm3 = '';
  String recoilertm4 = '';
  String recoilertm5 = '';
  String recoilertm6 = '';
}

SavedValues savedValues = SavedValues();

class SubProcess7Page1 extends StatefulWidget {
  @override
  State<SubProcess7Page1> createState() => _SubProcess7Page1State();
}

class _SubProcess7Page1State extends State<SubProcess7Page1> {
  TextEditingController _uncoilertm1Controller = TextEditingController();
  TextEditingController _uncoilertm2Controller = TextEditingController();
  TextEditingController _uncoilertm3Controller = TextEditingController();
  TextEditingController _uncoilertm4Controller = TextEditingController();
  TextEditingController _uncoilertm5Controller = TextEditingController();
  TextEditingController _uncoilertm6Controller = TextEditingController();

  TextEditingController _briddle1atm1Controller = TextEditingController();
  TextEditingController _briddle1atm2Controller = TextEditingController();
  TextEditingController _briddle1atm3Controller = TextEditingController();
  TextEditingController _briddle1atm4Controller = TextEditingController();
  TextEditingController _briddle1atm5Controller = TextEditingController();
  TextEditingController _briddle1atm6Controller = TextEditingController();

  TextEditingController _briddle1btm1Controller = TextEditingController();
  TextEditingController _briddle1btm2Controller = TextEditingController();
  TextEditingController _briddle1btm3Controller = TextEditingController();
  TextEditingController _briddle1btm4Controller = TextEditingController();
  TextEditingController _briddle1btm5Controller = TextEditingController();
  TextEditingController _briddle1btm6Controller = TextEditingController();

  TextEditingController _briddle2atm1Controller = TextEditingController();
  TextEditingController _briddle2atm2Controller = TextEditingController();
  TextEditingController _briddle2atm3Controller = TextEditingController();
  TextEditingController _briddle2atm4Controller = TextEditingController();
  TextEditingController _briddle2atm5Controller = TextEditingController();
  TextEditingController _briddle2atm6Controller = TextEditingController();

  TextEditingController _briddle2btm1Controller = TextEditingController();
  TextEditingController _briddle2btm2Controller = TextEditingController();
  TextEditingController _briddle2btm3Controller = TextEditingController();
  TextEditingController _briddle2btm4Controller = TextEditingController();
  TextEditingController _briddle2btm5Controller = TextEditingController();
  TextEditingController _briddle2btm6Controller = TextEditingController();

  TextEditingController _recoilertm1Controller = TextEditingController();
  TextEditingController _recoilertm2Controller = TextEditingController();
  TextEditingController _recoilertm3Controller = TextEditingController();
  TextEditingController _recoilertm4Controller = TextEditingController();
  TextEditingController _recoilertm5Controller = TextEditingController();
  TextEditingController _recoilertm6Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _uncoilertm1Controller.text = savedValues.uncoilertm1;
    _uncoilertm2Controller.text = savedValues.uncoilertm2;
    _uncoilertm3Controller.text = savedValues.uncoilertm3;
    _uncoilertm4Controller.text = savedValues.uncoilertm4;
    _uncoilertm5Controller.text = savedValues.uncoilertm5;
    _uncoilertm6Controller.text = savedValues.uncoilertm6;

    _briddle1atm1Controller.text = savedValues.briddle1atm1;
    _briddle1atm2Controller.text = savedValues.briddle1atm2;
    _briddle1atm3Controller.text = savedValues.briddle1atm3;
    _briddle1atm4Controller.text = savedValues.briddle1atm4;
    _briddle1atm5Controller.text = savedValues.briddle1atm5;
    _briddle1atm6Controller.text = savedValues.briddle1atm6;

    _briddle1btm1Controller.text = savedValues.briddle1btm1;
    _briddle1btm2Controller.text = savedValues.briddle1btm2;
    _briddle1btm3Controller.text = savedValues.briddle1btm3;
    _briddle1btm4Controller.text = savedValues.briddle1btm4;
    _briddle1btm5Controller.text = savedValues.briddle1btm5;
    _briddle1btm6Controller.text = savedValues.briddle1btm6;

    _briddle2atm1Controller.text = savedValues.briddle2atm1;
    _briddle2atm2Controller.text = savedValues.briddle2atm2;
    _briddle2atm3Controller.text = savedValues.briddle2atm3;
    _briddle2atm4Controller.text = savedValues.briddle2atm4;
    _briddle2atm5Controller.text = savedValues.briddle2atm5;
    _briddle2atm6Controller.text = savedValues.briddle2atm6;

    _briddle2btm1Controller.text = savedValues.briddle2btm1;
    _briddle2btm2Controller.text = savedValues.briddle2btm2;
    _briddle2btm3Controller.text = savedValues.briddle2btm3;
    _briddle2btm4Controller.text = savedValues.briddle2btm4;
    _briddle2btm5Controller.text = savedValues.briddle2btm5;
    _briddle2btm6Controller.text = savedValues.briddle2btm6;

    _recoilertm1Controller.text = savedValues.recoilertm1;
    _recoilertm2Controller.text = savedValues.recoilertm2;
    _recoilertm3Controller.text = savedValues.recoilertm3;
    _recoilertm4Controller.text = savedValues.recoilertm4;
    _recoilertm5Controller.text = savedValues.recoilertm5;
    _recoilertm6Controller.text = savedValues.recoilertm6;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currents'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: [
              DataColumn(label: Text('Parameter')),
              DataColumn(label: Text('Time 1')),
              DataColumn(label: Text('Time 2')),
              DataColumn(label: Text('Time 3')),
              DataColumn(label: Text('Time 4')),
              DataColumn(label: Text('Time 5')),
              DataColumn(label: Text('Time 6'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('UNCOILER'),
                  onPressed: () {},
                )),
                DataCell(TextField(
                  controller: _uncoilertm1Controller,
                )),
                DataCell(TextField(
                  controller: _uncoilertm2Controller,
                )),
                DataCell(TextField(
                  controller: _uncoilertm3Controller,
                )),
                DataCell(TextField(
                  controller: _uncoilertm4Controller,
                )),
                DataCell(TextField(
                  controller: _uncoilertm5Controller,
                )),
                DataCell(TextField(
                  controller: _uncoilertm6Controller,
                ))
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 1A'),
                  onPressed: () {},
                )),
                DataCell(TextField(
                  controller: _briddle1atm1Controller,
                )),
                DataCell(TextField(
                  controller: _briddle1atm2Controller,
                )),
                DataCell(TextField(
                  controller: _briddle1atm3Controller,
                )),
                DataCell(TextField(
                  controller: _briddle1atm4Controller,
                )),
                DataCell(TextField(
                  controller: _briddle1atm5Controller,
                )),
                DataCell(TextField(
                  controller: _briddle1atm6Controller,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 1B'),
                  onPressed: () {},
                )),
                DataCell(TextField(
                  controller: _briddle1btm1Controller,
                )),
                DataCell(TextField(
                  controller: _briddle1btm2Controller,
                )),
                DataCell(TextField(
                  controller: _briddle1btm3Controller,
                )),
                DataCell(TextField(
                  controller: _briddle1btm4Controller,
                )),
                DataCell(TextField(controller: _briddle1btm5Controller)),
                DataCell(TextField(
                  controller: _briddle1btm6Controller,
                ))
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 2A'),
                  onPressed: () {},
                )),
                DataCell(TextField(
                  controller: _briddle2atm1Controller,
                )),
                DataCell(TextField(
                  controller: _briddle2atm2Controller,
                )),
                DataCell(TextField(
                  controller: _briddle2atm3Controller,
                )),
                DataCell(TextField(
                  controller: _briddle2atm4Controller,
                )),
                DataCell(TextField(
                  controller: _briddle2atm5Controller,
                )),
                DataCell(TextField(
                  controller: _briddle2atm6Controller,
                ))
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('BRIDDLE 2B'),
                  onPressed: () {},
                )),
                DataCell(TextField(
                  controller: _briddle2btm1Controller,
                )),
                DataCell(TextField(
                  controller: _briddle2btm2Controller,
                )),
                DataCell(TextField(
                  controller: _briddle2btm3Controller,
                )),
                DataCell(TextField(
                  controller: _briddle2btm4Controller,
                )),
                DataCell(TextField(
                  controller: _briddle2btm5Controller,
                )),
                DataCell(TextField(
                  controller: _briddle2btm6Controller,
                ))
              ]),

              DataRow(cells: [
                DataCell(TextButton(
                  child: Text('RECOILER'),
                  onPressed: () {},
                )),
                DataCell(TextField(
                  controller: _recoilertm1Controller,
                )),
                DataCell(TextField(
                  controller: _recoilertm2Controller,
                )),
                DataCell(TextField(
                  controller: _recoilertm3Controller,
                )),
                DataCell(TextField(
                  controller: _recoilertm4Controller,
                )),
                DataCell(TextField(
                  controller: _recoilertm5Controller,
                )),
                DataCell(TextField(
                  controller: _recoilertm6Controller,
                ))
              ]),
            ]),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  savedValues.uncoilertm1 = _uncoilertm1Controller.text.trim();
                  savedValues.uncoilertm2 = _uncoilertm2Controller.text.trim();
                  savedValues.uncoilertm3 = _uncoilertm3Controller.text.trim();
                  savedValues.uncoilertm4 = _uncoilertm4Controller.text.trim();
                  savedValues.uncoilertm5 = _uncoilertm5Controller.text.trim();
                  savedValues.uncoilertm6 = _uncoilertm6Controller.text.trim();

                  savedValues.briddle1atm1 =
                      _briddle1atm1Controller.text.trim();
                      savedValues.briddle1atm2 =
                      _briddle1atm2Controller.text.trim();
                      savedValues.briddle1atm3 =
                      _briddle1atm3Controller.text.trim();
                      savedValues.briddle1atm4 =
                      _briddle1atm4Controller.text.trim();
                      savedValues.briddle1atm5 =
                      _briddle1atm5Controller.text.trim();
                      savedValues.briddle1atm6 =
                      _briddle1atm6Controller.text.trim();


                  savedValues.briddle1btm1 =
                      _briddle1btm1Controller.text.trim();
                      savedValues.briddle1btm2 =
                      _briddle1btm2Controller.text.trim();
                      savedValues.briddle1btm3 =
                      _briddle1btm3Controller.text.trim();
                      savedValues.briddle1btm4 =
                      _briddle1btm4Controller.text.trim();
                      savedValues.briddle1btm5 =
                      _briddle1btm5Controller.text.trim();
                      savedValues.briddle1btm6 =
                      _briddle1btm6Controller.text.trim();

                      

                                        savedValues.briddle2atm1 =
                      _briddle2atm1Controller.text.trim();
                      savedValues.briddle2atm2 =
                      _briddle2atm2Controller.text.trim();
                      savedValues.briddle2atm3 =
                      _briddle2atm3Controller.text.trim();
                      savedValues.briddle2atm4 =
                      _briddle2atm4Controller.text.trim();
                      savedValues.briddle2atm5 =
                      _briddle2atm5Controller.text.trim();
                      savedValues.briddle2atm6 =
                      _briddle2atm6Controller.text.trim();


                                        savedValues.briddle2btm1 =
                      _briddle2btm1Controller.text.trim();
                      savedValues.briddle2btm2 =
                      _briddle2btm2Controller.text.trim();
                      savedValues.briddle2btm3 =
                      _briddle2btm3Controller.text.trim();
                      savedValues.briddle2btm4 =
                      _briddle2btm4Controller.text.trim();
                      savedValues.briddle2btm5 =
                      _briddle2btm5Controller.text.trim();
                      savedValues.briddle2btm6 =
                      _briddle2btm6Controller.text.trim();


                  savedValues.recoilertm1 = _recoilertm1Controller.text.trim();
                  savedValues.recoilertm2 = _recoilertm2Controller.text.trim();
                  savedValues.recoilertm3 = _recoilertm3Controller.text.trim();
                  savedValues.recoilertm4 = _recoilertm4Controller.text.trim();
                  savedValues.recoilertm5 = _recoilertm5Controller.text.trim();
                  savedValues.recoilertm6 = _recoilertm6Controller.text.trim();
                },
                child: Text('Save as Draft'))
            // Add buttons for additonal functionality
          ]),
        ),
      ),
    );
  }
}
