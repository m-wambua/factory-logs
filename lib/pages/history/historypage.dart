import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Retriev the arguments passed
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;

        //Use the subprocess variable to display relevant data
    return Scaffold(
      appBar: AppBar(
        title: Text('History for $subprocess'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          //Display scrollable Excel-like table
          //Implement subpages for failure and maintenance

          TextButton(onPressed: (){}, child: Text('Failure History')),
          SizedBox(height: 30,),
          TextButton(onPressed: (){}, child: Text('Maintenance History')),
        ],
      )),
    );
  }
}
