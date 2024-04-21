import 'package:flutter/material.dart';

class SubProcess1Page1Details5 extends StatelessWidget {
  const SubProcess1Page1Details5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BRIDDLE 2B'),
      ),

      body: Column(
        children: [
TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: 'BRIDDLE 2B');
              },
              child: const Text('History')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
               
                Navigator.pushNamed(context, '/trends', arguments: 'BRIDDLE 2B');
              },
              child: const Text('Trends')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/manuals', arguments: 'BRIDDLE 2B');
              },
              child: const Text('Manuals')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/parameters', arguments: 'BRIDDLE 2B');
              },
              child: const Text('Parameters')),        ],
        
      ),
    );
  }
}

