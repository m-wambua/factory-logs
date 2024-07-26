import 'package:flutter/material.dart';

class ExistingCodeBasesPage extends StatelessWidget {
  const ExistingCodeBasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Existing Code Base'),
      ),
      body: const Center(
        child: Text(
          'Details of Existing code bases will be shown here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
