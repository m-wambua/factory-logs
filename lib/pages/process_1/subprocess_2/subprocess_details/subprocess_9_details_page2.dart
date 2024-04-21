import 'package:flutter/material.dart';

class SubProcess1Page2Details9_2 extends StatelessWidget {
  const SubProcess1Page2Details9_2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HYDRAULIC RECIRCULATION'),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: 'HYDRAULIC RECIRCULATION');
              },
              child: const Text('History')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
               
                Navigator.pushNamed(context, '/trends', arguments: 'HYDRAULIC RECIRCULATION');
              },
              child: const Text('Trends')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/manuals', arguments: 'HYDRAULIC RECIRCULATION');
              },
              child: const Text('Manuals')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/parameters', arguments: 'HYDRAULIC RECIRCULATION');
              },
              child: const Text('Parameters')),       ],
      ),
    );
  }
}
