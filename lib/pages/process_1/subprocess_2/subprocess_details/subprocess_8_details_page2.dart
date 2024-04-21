import 'package:flutter/material.dart';

class SubProcess1Page2Details8_2 extends StatelessWidget {
  const SubProcess1Page2Details8_2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HYDAULIC POWER PACK POWER AND STANDBY'),
      ),

      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: 'HYDRAULIC POWER PACK AND STANDBY');
              },
              child: const Text('History')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
               
                Navigator.pushNamed(context, '/trends', arguments: 'HYDRAULIC POWER PACK AND STANDBY');
              },
              child: const Text('Trends')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/manuals', arguments: 'HYDRAULIC POWER PACK AND STANDBY');
              },
              child: const Text('Manuals')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/parameters', arguments: 'HYDRAULIC POWER PACK AND STANDBY');
              },
              child: const Text('Parameters')),       ],
      ),
    );
  }
}
