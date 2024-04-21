import 'package:flutter/material.dart';

class SubProcess1Page2Details13
 extends StatelessWidget {
  const SubProcess1Page2Details13({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OVEN SECTION A BLOWERS'),
      ),

     body: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history',
                      arguments: 'OVEN SECTION  A BLOWERS');
                },
                child: const Text('History')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/trends',
                      arguments: 'OVEN SECTION  A BLOWERS');
                },
                child: const Text('Trend')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manuals',
                      arguments: 'OVEN SECTION  A BLOWERS');
                },
                child: const Text('Manuals')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/parameters',
                      arguments: 'OVEN SECTION  A BLOWERS');

                },
                child: const Text('Parameters'))
          ],
        ));

  }
}

