import 'package:flutter/material.dart';

class SubProcess1Page2Details2 extends StatelessWidget {
  const SubProcess1Page2Details2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BRIDDLE 1 ROLL 1'),
      ),

     body: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history',
                      arguments: 'BRIDDLE 1 ROLL 1');
                },
                child: const Text('History')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/trends',
                      arguments: 'BRIDDLE 1 ROLL 1');
                },
                child: const Text('Trend')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manuals',
                      arguments: 'BRIDDLE 1 ROLL 1');
                },
                child: const Text('Manuals')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/parameters',
                      arguments: 'BRIDDLE 1 ROLL 1');

                },
                child: const Text('Parameters'))
          ],
        ));

  }
}
