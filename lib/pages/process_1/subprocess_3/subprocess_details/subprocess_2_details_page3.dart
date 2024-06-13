import 'package:flutter/material.dart';

class SubProcess1Page2Details2_3 extends StatelessWidget {
  const SubProcess1Page2Details2_3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('C.T MOTOR'),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history', arguments: 'C.T MOTOR');
              },
              child: const Text('History')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
               
                Navigator.pushNamed(context, '/trends', arguments: 'C.T MOTOR');
              },
              child: const Text('Trends')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/manuals', arguments: 'C.T MOTOR');
              },
              child: const Text('Manuals')),
          const SizedBox(
            height: 40,
          ),
          TextButton(
              onPressed: () {
                
                Navigator.pushNamed(context, '/parameters', arguments: 'C.T MOTOR');
              },
              child: const Text('Parameters')),
        ],
      ),
    );
  }
}
