import 'package:flutter/material.dart';

class ParameterPage extends StatelessWidget {
  const ParameterPage({super.key});

  @override
  Widget build(BuildContext context) {
//Retieve the arguemtns passes
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;
//Use the subprocess variable to display relevant data
    return Scaffold(
      appBar: AppBar(
        title: Text('Parameter for $subprocess'),
      ),
      body: const SingleChildScrollView(
        child: Column(children: [
          // Display tables, descriptions or pictures of name
          //allow editing of parameters
        ]),
      ),
    );
  }
}
