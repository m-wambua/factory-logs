import 'package:flutter/material.dart';

class SubProcess1Page2Details1_2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UNCOILER BLOWER'),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: 'UNCOILER BLOWER');
              },
              child: Text('History')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
               
                Navigator.pushNamed(context, '/trends', arguments: 'UNCOILER BLOWER');
              },
              child: Text('Trends')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/manuals', arguments: 'UNCOILER BLOWER');
              },
              child: Text('Manuals')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/parameters', arguments: 'UNCOILER BLOWER');
              },
              child: Text('Parameters')),
        ],
      ),
    );
  }
}

