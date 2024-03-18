import 'package:collector/pages/history/historypage.dart';
import 'package:collector/pages/manuals/manuelspage.dart';
import 'package:collector/pages/parameters/parameterspage.dart';
import 'package:collector/pages/trends/trendspage.dart';
import 'package:flutter/material.dart';

class SubProcess1Page1Details5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BRIDDLE 2B'),
      ),

      body: Column(
        children: [
TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: 'BRIDDLE 2B');
              },
              child: Text('History')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
               
                Navigator.pushNamed(context, '/trends', arguments: 'BRIDDLE 2B');
              },
              child: Text('Trends')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/manuals', arguments: 'BRIDDLE 2B');
              },
              child: Text('Manuals')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/parameters', arguments: 'BRIDDLE 2B');
              },
              child: Text('Parameters')),        ],
        
      ),
    );
  }
}

