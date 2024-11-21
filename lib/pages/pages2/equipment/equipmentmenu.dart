import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';

class EquipmentMenu extends StatelessWidget {
  final String processName;
  final String subprocessName;
  final String equipmentName;

  const EquipmentMenu(
      {super.key,
      required this.processName,
      required this.subprocessName,
      required this.equipmentName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Image.asset(AppAssets.deltalogo),
            ),
            Text(
                'Submenu Items for $equipmentName, from the processName $processName and Subprocess $subprocessName'),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history', arguments: {
                    'equipmentName': equipmentName,
                    'processName': processName,
                    'subprocessName': subprocessName
                  });
                },
                child: Text('History')),
            SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manuals', arguments: {
                    'equipmentName': equipmentName,
                    'processName': processName,
                    'subprocessName': subprocessName
                  });
                },
                child: Text('Manuals')),
            SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/parameters', arguments: {
                    'equipmentName': equipmentName,
                    'processName': processName,
                    'subprocessName': subprocessName,
                  });
                },
                child: Text('Parameters')),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/spares', arguments: {
                    'equipmentName': equipmentName,
                    'processName': processName,
                    'subprocessName': subprocessName
                  });
                },
                child: Text('Spares'))
          ],
        ),
      ),
    );
  }
}
