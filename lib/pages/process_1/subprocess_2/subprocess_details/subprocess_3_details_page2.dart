import 'package:flutter/material.dart';

class SubProcess1Page2Details3_2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BRIDDLE 1 B BLOWER MOTOR'),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: 'BRIDDLE 1 B BLOWER MOTOR');
              },
              child: Text('History')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
               
                Navigator.pushNamed(context, '/trends', arguments: 'BRIDDLE 1 B bLOWER MOTOR');
              },
              child: Text('Trends')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/manuals', arguments: 'BRIDDLE 1B BLOWER MOTOR');
              },
              child: Text('Manuals')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/parameters', arguments: 'BRIDDLE 1B BLOWER MOTOR');
              },
              child: Text('Parameters')),
        ],
      ),
    );
  }
}

