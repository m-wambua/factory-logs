import 'package:flutter/material.dart';

class SubProcess1Page2Details10_2 extends StatelessWidget {
  const SubProcess1Page2Details10_2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WELDER MOTOR'),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history',
                    arguments: 'WELDER MOTOR');
              },
              child: const Text('History')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/trends',
                    arguments: 'WELDER MOTOR');
              },
              child: const Text('Trends')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/manuals',
                    arguments: 'WELDER MOTOR');
              },
              child: const Text('Manuals')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/parameters',
                    arguments: 'WELDER MOTOR');
              },
              child: const Text('Parameters')),
        ],
      ),
    );
  }
}
