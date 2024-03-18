import 'package:collector/pages/history/historypage.dart';
import 'package:collector/pages/manuals/manuelspage.dart';
import 'package:collector/pages/parameters/parameterspage.dart';
import 'package:collector/pages/trends/trendspage.dart';
import 'package:flutter/material.dart';

class SubProcess1Page1Details6 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RECOILER'),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: 'RECOILER');
              },
              child: Text('History')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
               
                Navigator.pushNamed(context, '/trends', arguments: 'RECOILER');
              },
              child: Text('Trends')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/manuals', arguments: 'RECOILER');
              },
              child: Text('Manuals')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/parameters', arguments: 'RECOILER');
              },
              child: Text('Parameters')),
        ],
      ),
    );
  }
}
