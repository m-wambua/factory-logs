import 'package:flutter/material.dart';

class SubProcess1Page2Details3_3 extends StatelessWidget {
  const SubProcess1Page2Details3_3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOIST MTOR'),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: 'HOIST MOTOR');
              },
              child: const Text('History')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
               
                Navigator.pushNamed(context, '/trends', arguments: 'HOIST MOTOR');
              },
              child: const Text('Trends')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/manuals', arguments: 'HOIST MOTOR');
              },
              child: const Text('Manuals')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/parameters', arguments: 'HOIST MOTOR');
              },
              child: const Text('Parameters')),
        ],
      ),
    );
  }
}
