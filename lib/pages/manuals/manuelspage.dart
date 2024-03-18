//import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ManualsPage extends StatelessWidget {
  @override
  
  Widget build(BuildContext context) {

   //Retriev the arguments passed
  final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;
    //use the subprocess variable to display relevant data
    return Scaffold(

      appBar: AppBar(
        title: Text('Manual for $subprocess'),
      ),
      body: SingleChildScrollView(
        child: Column(
            //Dispay PDF as scrollable content

            ),
      ),
    );
  }
}
