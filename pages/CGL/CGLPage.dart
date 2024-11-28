import 'package:flutter/material.dart';

class CGLPage extends StatelessWidget {
  const CGLPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CGL'),
        
      ),
      body: ListView(
        children: [
          for (var subprocess in _subprocesses)
            ListTile(
              title: Text(subprocess),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/CGL/${subprocess}_p');
                    },
                    child: const Text('Production'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/CGL/${subprocess}_np');
                    },
                    child: const Text('No Production'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

final List<String> _subprocesses = ['Subprocess1P', 'Subprocess2NP', 'Subprocess3P'];
