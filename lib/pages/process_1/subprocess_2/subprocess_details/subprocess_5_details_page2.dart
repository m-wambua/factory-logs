import 'package:flutter/material.dart';

class SubProcess1Page2Details5_2 extends StatelessWidget {
  const SubProcess1Page2Details5_2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BRIDDLE 2B MOTOR BLOWER'),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history',
                    arguments: 'BRIDDLE 2B MOTOR BLOWER');
              },
              child: const Text('History')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/trends',
                    arguments: 'BRIDDLE 2B MOTOR BLOWER');
              },
              child: const Text('Trends')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/manuals',
                    arguments: 'BRIDDLE 2B MOTOR BLOWER');
              },
              child: const Text('Manuals')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/parameters',
                    arguments: 'BRIDDLE 2B MOTOR BLOWER');
              },
              child: const Text('Parameters')),
        ],
      ),
    );
  }
}
