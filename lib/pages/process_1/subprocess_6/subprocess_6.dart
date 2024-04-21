import 'package:flutter/material.dart';

class SavedValues {
  String tll_tension_tm1 = '';
  String tll_tension_tm2 = '';
  String tll_tension_tm3 = '';
  String recoiler_tensiontm1 = '';
  String recoiler_tensiontm2 = '';
  String recoiler_tensiontm3 = '';
  String uncoiler_tensiontm1 = '';
  String uncoiler_tensiontm2 = '';
  String uncoiler_tensiontm3 = '';
}

SavedValues savedValues = SavedValues();

class SubProcess6Page1 extends StatefulWidget {
  const SubProcess6Page1({super.key});

  @override
  State<SubProcess6Page1> createState() => _SubProcess6Page1State();
}

class _SubProcess6Page1State extends State<SubProcess6Page1> {
  final TextEditingController _tllTensionControllertm1 = TextEditingController();
  final TextEditingController _tllTensionControllertm2 = TextEditingController();
  final TextEditingController _tllTensionControllertm3 = TextEditingController();
  final TextEditingController _uncoilerTensionControllertm1 = TextEditingController();
  final TextEditingController _uncoilerTensionControllertm2 = TextEditingController();
  final TextEditingController _uncoilerTensionControllertm3 = TextEditingController();
  final TextEditingController _recoilerTensionControllertm1 = TextEditingController();
  final TextEditingController _recoilerTensionControllertm2 = TextEditingController();
  final TextEditingController _recoilerTensionControllertm3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tllTensionControllertm1.text = savedValues.tll_tension_tm1;
    _tllTensionControllertm2.text = savedValues.tll_tension_tm2;
    _tllTensionControllertm3.text = savedValues.tll_tension_tm3;
    _recoilerTensionControllertm1.text = savedValues.recoiler_tensiontm1;
    _recoilerTensionControllertm2.text = savedValues.recoiler_tensiontm2;
    _recoilerTensionControllertm3.text = savedValues.recoiler_tensiontm3;
    _uncoilerTensionControllertm1.text = savedValues.uncoiler_tensiontm1;
    _uncoilerTensionControllertm2.text = savedValues.uncoiler_tensiontm2;
    _uncoilerTensionControllertm3.text = savedValues.uncoiler_tensiontm3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tensions'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            DataTable(columns: const [
              DataColumn(label: Text('TENSIONS')),
              DataColumn(label: Text('TIMING 1')),
              DataColumn(label: Text('TIMING 2')),
              DataColumn(label: Text('TIMING 3'))
            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('TLL'),
                  onPressed: () {},
                )),
                DataCell(TextField(
                  controller: _tllTensionControllertm1,
                )),
                DataCell(TextField(
                  controller: _tllTensionControllertm2,
                )),
                DataCell(TextField(
                  controller: _recoilerTensionControllertm3,
                ))
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('RECOILER'),
                  onPressed: () {},
                )),
                DataCell(TextField(
                  controller: _recoilerTensionControllertm1,
                )),
                DataCell(TextField(
                  controller: _recoilerTensionControllertm2,
                )),
                DataCell(TextField(
                  controller: _recoilerTensionControllertm3,
                ))
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('UNCOILER'),
                  onPressed: () {},
                )),
                DataCell(TextField(
                  controller: _uncoilerTensionControllertm1,
                )),
                DataCell(TextField(
                  controller: _uncoilerTensionControllertm2,
                )),
                DataCell(TextField(
                  controller: _uncoilerTensionControllertm3,
                ))
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(
                  child: const Text('Parameter 1'),
                  onPressed: () {},
                )),
                const DataCell(TextField()),
                const DataCell(TextField()),
                const DataCell(TextField())
              ]),

              // Add rows or data entry
              /*
              DataRow(cells: [
                DataCell(Text('Parameter 1')),
                DataCell(TextField()),
                DataCell(TextField()),
                DataCell(TextField())
              ]),
              */
            ]),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  savedValues.tll_tension_tm1 =
                      _tllTensionControllertm1.text.trim();
                  savedValues.tll_tension_tm2 =
                      _tllTensionControllertm2.text.trim();
                  savedValues.tll_tension_tm3 =
                      _tllTensionControllertm3.text.trim();
                  savedValues.recoiler_tensiontm1 =
                      _recoilerTensionControllertm1.text.trim();
                            savedValues.recoiler_tensiontm2 =
                      _recoilerTensionControllertm2.text.trim();
                            savedValues.recoiler_tensiontm3 =
                      _recoilerTensionControllertm3.text.trim();
                },
                child: const Text('Saved as Draft'))
            // Add buttons for additonal functionality
          ]),
        ),
      ),
    );
  }
}
