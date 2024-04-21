import 'package:flutter/material.dart';

class SubProcess1Page2Details11
 extends StatelessWidget {
  const SubProcess1Page2Details11({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BOTTOM PICK-UP ROLL'),
      ),

     body: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history',
                      arguments: 'BOTTOM PICK-UP ROLL');
                },
                child: const Text('History')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/trends',
                      arguments: 'BOTTOM PICK-UP ROLL');
                },
                child: const Text('Trend')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manuals',
                      arguments: 'BOTTOM PICK-UP ROLL');
                },
                child: const Text('Manuals')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/parameters',
                      arguments: 'BOTTOM PICK-UP ROLL');

                },
                child: const Text('Parameters'))
          ],
        ));

  }
}

