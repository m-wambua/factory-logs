import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';

class EquipmentMenu extends StatelessWidget {
  final String equipmentName;

  const EquipmentMenu({super.key, required this.equipmentName});
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
            Text('Submenu Items for $equipmentName'),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history',
                      arguments: '$equipmentName');
                },
                child: Text('History')),
            SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manuals',
                      arguments: '$equipmentName');
                },
                child: Text('Manuals')),
            SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/parameters',
                      arguments: equipmentName);
                },
                child: Text('Parameters')),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/spares',
                      arguments: '$equipmentName');
                },
                child: Text('Spares'))
          ],
        ),
      ),
    );
  }
}
