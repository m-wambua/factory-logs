import 'package:flutter/material.dart';

class SubProcess1Page2Details8_2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HYDAULIC POWER PACK POWER AND STANDBY'),
      ),

      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: 'HYDRAULIC POWER PACK AND STANDBY');
              },
              child: Text('History')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
               
                Navigator.pushNamed(context, '/trends', arguments: 'HYDRAULIC POWER PACK AND STANDBY');
              },
              child: Text('Trends')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/manuals', arguments: 'HYDRAULIC POWER PACK AND STANDBY');
              },
              child: Text('Manuals')),
          SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/parameters', arguments: 'HYDRAULIC POWER PACK AND STANDBY');
              },
              child: Text('Parameters')),       ],
      ),
    );
  }
}
