import 'package:flutter/material.dart';

class ExistingCodeBasesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Existing Code Base'),
      ),
      body: Center(
        child: Text(
          'Details of Existing code bases will be shown here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
