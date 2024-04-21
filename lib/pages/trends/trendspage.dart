import 'package:flutter/material.dart';

class TrendsPage extends StatelessWidget {
  const TrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    //Retrieve the arguments passes
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;
        //Use the subprocess variable to display relevant data
    return Scaffold(
      appBar: AppBar(
        title: Text('Trends for $subprocess'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            //Display line graph with past values
            // implement date filter
          ],
        ),
      ),
    );
  }
}
