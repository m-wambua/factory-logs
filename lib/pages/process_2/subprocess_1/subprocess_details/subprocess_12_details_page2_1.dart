import 'package:flutter/material.dart';

class SubProcess1Page2Details12
 extends StatelessWidget {
  const SubProcess1Page2Details12({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BOTTOM APPLICATOR ROLL'),
      ),

     body: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history',
                      arguments: 'BOTTOM APPLICATOR ROLL');
                },
                child: const Text('History')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/trends',
                      arguments: 'BOTTOM APPLICATOR ROLL');
                },
                child: const Text('Trend')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manuals',
                      arguments: 'BOTTOM APPLICATOR ROLL');
                },
                child: const Text('Manuals')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/parameters',
                      arguments: 'BOTTOM APPLICATOR ROLL');

                },
                child: const Text('Parameters'))
          ],
        ));

  }
}

