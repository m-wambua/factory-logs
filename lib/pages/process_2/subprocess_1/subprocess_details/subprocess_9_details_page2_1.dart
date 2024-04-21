import 'package:flutter/material.dart';

class SubProcess1Page2Details9 extends StatelessWidget {
  const SubProcess1Page2Details9({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOP PICK-UP ROLL'),
      ),

     body: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history',
                      arguments: 'TOP PICK-UP ROLL');
                },
                child: const Text('History')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/trends',
                      arguments: 'TOP PICK-UP ROLL');
                },
                child: const Text('Trend')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manuals',
                      arguments: 'TOP PICK-UP ROLL');
                },
                child: const Text('Manuals')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/parameters',
                      arguments: 'TOP PICK-UP ROLL');

                },
                child: const Text('Parameters'))
          ],
        ));

  }
}

