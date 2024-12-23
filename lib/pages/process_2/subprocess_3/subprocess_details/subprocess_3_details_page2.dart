import 'package:flutter/material.dart';

class SubProcess3Page2Details3 extends StatelessWidget {
  const SubProcess3Page2Details3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOIST MOTOR SR NO 20946 4/11'),
      ),

      body: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history',
                      arguments: 'HOIST MOTOR SR NO 20946 4/11');
                },
                child: const Text('History')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/trends',
                      arguments: 'HOIST MOTOR SR NO 20946 4/11');
                },
                child: const Text('Trend')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manuals',
                      arguments: 'HOIST MOTOR SR NO 20946 4/11');
                },
                child: const Text('Manuals')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/parameters',
                      arguments: 'HOIST MOTOR SR NO 20946 4/11');

                },
                child: const Text('Parameters'))
          ],
        ));

  }
}

