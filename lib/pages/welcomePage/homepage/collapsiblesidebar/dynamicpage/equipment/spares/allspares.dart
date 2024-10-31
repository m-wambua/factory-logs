import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/spares/spartpartsmodel.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

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
    try {
      final baseDir =
          '/home/wambua/mike/Python/FactoryLogs/collector/lib/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/spares/sparesstorage';
      final directory = Directory(baseDir);

      if (await directory.exists()) {
        final List<FileSystemEntity> entities = await directory.list().toList();
        for (var entity in entities) {
          if (entity is Directory) {
            final equipmentName = path.basename(entity.path);
            final filePath =
                path.join(entity.path, '${equipmentName}_spares.json');
            final file = File(filePath);

            if (await file.exists()) {
              final contents = await file.readAsString();
              final List<dynamic> jsonList = json.decode(contents);
              allEquipmentSpares[equipmentName] =
                  jsonList.map((json) => SparePart.fromJson(json)).toList();
            }
          }
        }
      }
    } catch (e) {
      print("Error loading spare parts: $e");
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Image.asset(AppAssets.deltalogo),
              ),
              Text('All Equipment Spares'),
            ],
          ),
        
      
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],
      ),
      body: ListView.builder(
        itemCount: allEquipmentSpares.length,
        itemBuilder: (context, index) {
          final equipmentName = allEquipmentSpares.keys.elementAt(index);
          final spares = allEquipmentSpares[equipmentName]!;
          return ExpansionTile(
            title: Text(equipmentName),
            children: spares
                .map((spare) => ListTile(
                      title: Text(spare.name),
                      subtitle: Text('Part Number: ${spare.partNumber}'),
                      trailing: Text(
                          'Stock: ${spare.minimumStock} - ${spare.maximumStock}'),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
