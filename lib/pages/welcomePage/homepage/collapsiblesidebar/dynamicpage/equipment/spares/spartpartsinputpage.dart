import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/spares/spartpartsmodel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EquipmentSparePartsPage extends StatefulWidget {
  final String equipmentName;

  const EquipmentSparePartsPage({Key? key, required this.equipmentName})
      : super(key: key);

  @override
  _EquipmentSparePartsPageState createState() =>
      _EquipmentSparePartsPageState();
}

class _EquipmentSparePartsPageState extends State<EquipmentSparePartsPage> {
  List<SparePart> spareParts = [];
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _partNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();
  final _leadTimeController = TextEditingController();
  final _supplierInfoController = TextEditingController();
  final _criticalityController = TextEditingController();
  final _conditionController = TextEditingController();
  final _warrantyController = TextEditingController();
  final _usageRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSpareParts();
  }

  Future<void> _loadSpareParts() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${widget.equipmentName}_spares.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      setState(() {
        spareParts = jsonList.map((json) => SparePart.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveSpareParts() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${widget.equipmentName}_spares.json');
    await file.writeAsString(
        json.encode(spareParts.map((sp) => sp.toJson()).toList()));
  }

  void _addSparePart() {
    if (_formKey.currentState!.validate()) {
      final newSparePart = SparePart(
        name: _nameController.text,
        partNumber: _partNumberController.text,
        description: _descriptionController.text,
        minimumStock: int.tryParse(_minStockController.text) ?? 0,
        maximumStock: int.tryParse(_maxStockController.text) ?? 0,
        leadTime: _leadTimeController.text,
        supplierInfo: _supplierInfoController.text,
        criticality: _criticalityController.text,
        condition: _conditionController.text,
        warranty: _warrantyController.text,
        usageRate: _usageRateController.text,
      );
      setState(() {
        spareParts.add(newSparePart);
      });
      _saveSpareParts();
      _clearForm();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _partNumberController.clear();
    _descriptionController.clear();
    _minStockController.clear();
    _maxStockController.clear();
    _leadTimeController.clear();
    _supplierInfoController.clear();
    _criticalityController.clear();
    _conditionController.clear();
    _warrantyController.clear();
    _usageRateController.clear();
  }

  Future<void> _generatePDF(SparePart sparePart) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Spare Part Details',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Name: ${sparePart.name}'),
            pw.Text('Part Number: ${sparePart.partNumber}'),
            pw.Text('Description: ${sparePart.description}'),
            pw.Text(
                'Stock Levels: ${sparePart.minimumStock} - ${sparePart.maximumStock}'),
            pw.Text('Condition: ${sparePart.condition}'),
            pw.Text('Lead Time: ${sparePart.leadTime}'),
            pw.Text('Supplier Info: ${sparePart.supplierInfo}'),
            pw.Text('Criticality: ${sparePart.criticality}'),
            pw.Text('Warranty: ${sparePart.warranty}'),
            pw.Text('Usage Rate: ${sparePart.usageRate}'),
          ],
        ),
      ),
    );
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: '${sparePart.name}_details.pdf');
  }

  Future<void> _sendEmail(SparePart sparePart) async {
    // Implement email sending logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.equipmentName} Spare Parts'),
        actions: [
          IconButton(
            onPressed: () {
              _createNewSpares(widget.equipmentName);
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: spareParts.length,
              itemBuilder: (context, index) {
                final sparePart = spareParts[index];
                return Card(
                  child: ExpansionTile(
                    title: Text(sparePart.name),
                    subtitle: Text('Part Number: ${sparePart.partNumber}'),
                    children: [
                      ListTile(
                          title: Text('Description: ${sparePart.description}')),
                      ListTile(
                          title: Text(
                              'Stock: ${sparePart.minimumStock} - ${sparePart.maximumStock}')),
                      ListTile(
                          title: Text('Condition: ${sparePart.condition}')),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _generatePDF(sparePart),
                            child: Text('Print'),
                          ),
                          ElevatedButton(
                            onPressed: () => _sendEmail(sparePart),
                            child: Text('Email'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _createNewSpares(String equipmentName) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              scrollable: true,
              title: Text('Create New Spare Part for $equipmentName'),
              content: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a name' : null,
                    ),
                    TextFormField(
                      controller: _partNumberController,
                      decoration: InputDecoration(labelText: 'Part Number'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a part number' : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    TextFormField(
                      controller: _minStockController,
                      decoration: InputDecoration(labelText: 'Minimum Stock'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _maxStockController,
                      decoration: InputDecoration(labelText: 'Maximum Stock'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _leadTimeController,
                      decoration: InputDecoration(labelText: 'Lead Time'),
                    ),
                    TextFormField(
                      controller: _supplierInfoController,
                      decoration:
                          InputDecoration(labelText: 'Supplier Information'),
                    ),
                    TextFormField(
                      controller: _criticalityController,
                      decoration: InputDecoration(labelText: 'Criticality'),
                    ),
                    TextFormField(
                      controller: _conditionController,
                      decoration: InputDecoration(labelText: 'Condition'),
                    ),
                    TextFormField(
                      controller: _warrantyController,
                      decoration:
                          InputDecoration(labelText: 'Warranty Information'),
                    ),
                    TextFormField(
                      controller: _usageRateController,
                      decoration: InputDecoration(labelText: 'Usage Rate'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _addSparePart();
                        },
                        child: Text(
                          'Save Spare',
                          style: TextStyle(color: Colors.green),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ))
                  ],
                ),
              ],
            ));
  }
}
