import 'package:flutter/material.dart';

class SubProcess3Page2Details4 extends StatelessWidget {
  const SubProcess3Page2Details4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LONG TRAVEL MOTORS SR NO 20946 5/11'),
      ),

      body: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history',
                      arguments: 'LONG TRAVEL MOTOR SR NO 20946 5/11');
                },
                child: const Text('History')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/trends',
                      arguments: 'LONG TRAVEL MOTOR SR NO 20946 5/11');
                },
                child: const Text('Trend')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/manuals',
                      arguments: 'LONG TRAVEL MOTOR SR NO 20946 5/11');
                },
                child: const Text('Manuals')),
            const SizedBox(
              height: 40,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/parameters',
                      arguments: 'LONG TRAVEL MOTOR SR NO 20946 5/11');

                },
                child: const Text('Parameters'))
          ],
        ));

  }
}

