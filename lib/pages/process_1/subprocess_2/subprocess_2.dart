import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubProcess2Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MCC MOTORS'),
      ),
     body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //Table for data entry specific to subprocess 1
            Text('FEEDER MOTORS CURRENT'),
            SizedBox(height: 10,),
            DataTable(columns: [
              DataColumn(label: Text('FEEDER MOTORS CURRENT')),
              DataColumn(label: Text('RATED')),
              DataColumn(label: Text('DRAWN')),
              DataColumn(label: Text('Remarks'))
              


            ], rows: [
              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(child: Text('UNCOILER BLOWER MOTOR'),onPressed: () {
                  
                },)),

                DataCell(Text('6.0')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              //Add more rows as needed

              // Add rows or data entry
              DataRow(cells: [
                DataCell(TextButton(child:Text('BRIDDLE 1 #A BLOWER') , onPressed: (){},)
                  ),//BRIDDLE 1 #A BLOWER
                DataCell(Text('2.8')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('BRIDLE 1#B BLOWER'),onPressed: () {
                    
                  },)
                  ),//BRIDLE 1#B BLOWER
                DataCell(Text('6.0')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),
// Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('BRIDDLE 2#A BLOWER MOTOR'),onPressed: () {
                    
                  },)
                  ),//BRIDDLE 2#A BLOWER MOTOR
                DataCell(Text('6.1')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton( child:Text('BRIDDLE 2#B BLOWER MOTOR') ,onPressed: () {
                    
                  },)
                  ),//BRIDDLE 2#B BLOWER MOTOR
                DataCell(Text('2.8')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('RECOILER MOTOR BLOWER'),onPressed: () {
                    
                  },)
                  ),//RECOILER MOTOR BLOWER
                DataCell(Text('6.0')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('FLATTENER MOTOR'),onPressed: () {
                    
                  },)
                  ),//FLATTENER MOTOR
                DataCell(Text('20.5')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('REC LUB MOTOR') ,onPressed: () {
                    
                  },)
                  ),//REC LUB MOTOR
                DataCell(Text('3.4')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('HYD P PACK WRK & STBY') ,onPressed: (){},)
                  ),//HYD P PACK WRK & STBY
                DataCell(Text('40.0')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child: Text('HYDR. RECIRCULATIONS') ,onPressed: (){},)
                 ),//HYDR. RECIRCULATIONS
                DataCell(Text('3.4')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('WELDER MOTOR') ,onPressed: () {
                    
                  },)
                  ),//WELDER MOTOR
                DataCell(Text('5.37/3.45')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('SCRAP BALLER MOTOR') ,onPressed: () {
                    
                  },)
                  ),//SCRAP BALLER MOTOR
                DataCell(Text('39.5')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),

              // Add rows or data entry
              DataRow(cells: [
                DataCell(
                  TextButton(child:Text('UNC. LUB MOTOR') ,onPressed: () {
                    
                  },)
                  ),//UNC. LUB MOTOR
                DataCell(Text('3.4')),
                DataCell(TextField()),
                DataCell(TextField())
              ]),


            ]),
            SizedBox(
              height: 20,
            ),
            // Add buttons for additonal functionality
          ]),
        ),
      ),
    );
  }
}
