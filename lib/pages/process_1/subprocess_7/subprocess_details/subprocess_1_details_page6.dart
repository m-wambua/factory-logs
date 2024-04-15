import 'package:flutter/material.dart';

class SubProcess1Page2Details1_7 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UNCOILER'),
      ),

      body: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history',
                      arguments: 'TLL Crownings');
                },
                child: Text('History')),
            SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/trends',
                      arguments: 'TLL Crownings');
                },
                child: Text('Trend')),
            SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manuals',
                      arguments: 'TLL Crownings');
                },
                child: Text('Manuals')),
            SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/parameters',
                      arguments: 'TLL Crownings');

                },
                child: Text('Parameters'))
          ],
        ));

  }
}

