import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/spares/spartpartsmodel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class AllEquipmentSparesPage extends StatefulWidget {
  @override
  _AllEquipmentSparesPageState createState() => _AllEquipmentSparesPageState();
}

class _AllEquipmentSparesPageState extends State<AllEquipmentSparesPage> {
  Map<String, List<SparePart>> allEquipmentSpares = {};

  @override
  void initState() {
    super.initState();
    _loadAllEquipmentSpares();
  }

  Future<void> _loadAllEquipmentSpares() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();
    
    for (var file in files) {
      if (file is File && file.path.endsWith('_spares.json')) {
        final equipmentName = file.path.split('/').last.split('_spares.json').first;
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        allEquipmentSpares[equipmentName] = jsonList.map((json) => SparePart.fromJson(json)).toList();
      }
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:const Text('All Equipment Spares')),
      body: ListView.builder(
        itemCount: allEquipmentSpares.length,
        itemBuilder: (context, index) {
          final equipmentName = allEquipmentSpares.keys.elementAt(index);
          final spares = allEquipmentSpares[equipmentName]!;
          return ExpansionTile(
            title: Text(equipmentName),
            children: spares.map((spare) => ListTile(
              title: Text(spare.name),
              subtitle: Text('Part Number: ${spare.partNumber}'),
              trailing: Text('Stock: ${spare.minimumStock} - ${spare.maximumStock}'),
            )).toList(),
          );
        },
      ),
    );
  }
}