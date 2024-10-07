import 'package:flutter/material.dart';

class EquipmentMenu extends StatelessWidget {
  final String equipmentName;

  const EquipmentMenu({super.key, required this.equipmentName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(equipmentName),
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
