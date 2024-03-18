import 'package:flutter/material.dart';

class SubProcess1Page2Details2_2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BRIDDLE 1A BLOWER MOTOR'),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: 'BRIDDLE 1A BLOWER MOTOR');
              },
              child: Text('History')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
               
                Navigator.pushNamed(context, '/trends', arguments: 'BRIDDLE 1A BLOWER MOTOR');
              },
              child: Text('Trends')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/manuals', arguments: 'BRIDDLE 1A BLOWER MOTOR');
              },
              child: Text('Manuals')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/parameters', arguments: 'BRIDDLE 1A BLOWER MOTOR');
              },
              child: Text('Parameters')),
        ],
      ),
    );
  }
}
