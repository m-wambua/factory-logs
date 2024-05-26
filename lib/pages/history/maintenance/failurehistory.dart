/*
import 'package:collector/pages/history/maintenance/detailsmaintenance.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:collection/collection.dart';


class MaintenanceEntry {
  String equipment;
  String task;
  DateTime lastUpdate;
  int updateCount;
  String duration;


  String responsiblePerson;
  TaskState taskState;

  MaintenanceEntry({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
required this.updateCount,
    required this.duration,
    required this.responsiblePerson,
    this.taskState=TaskState.unactioned
  });
Map<String, dynamic> toJson(){
    return{
      'equipment':equipment,
      'task': task,
       'lastUpdate': lastUpdate.toIso8601String(),
      'updateCount':updateCount,
      'duration':duration,
      'responsiblePerson':responsiblePerson,
      'taskState':taskState.index

    };
  }
  factory MaintenanceEntry.fromJson(Map<String, dynamic> json) {
    return MaintenanceEntry(
      equipment: json['equipment'],
      task: json['task'],
      lastUpdate: json['lastUpdate'],
      updateCount: json['updateCount'],
      duration: json['duration'],
      responsiblePerson: json['responsiblePerson'],
      taskState: TaskState.values[json['taskState']]
    );
  }
  MaintenanceDetails toMaintenanceDetails(){
    return MaintenanceDetails(equipment: equipment, 
    task: task, 
    lastUpdate: lastUpdate, 
    situationBefore: '', 
    stepsTaken:[],
     toolsUsed: [],
      situationResolved: false,
       situationAfter: '',
        personResponsible: responsiblePerson);
  }
}
enum TaskState{
  unactioned,
  inProgress,
  complted,
}

class MaintenanceDetails{
  String equipment;
  String task;
  DateTime lastUpdate;
  String situationBefore;
  List<String> stepsTaken;
  List<String> toolsUsed;
  bool situationResolved;
  String situationAfter;
  String personResponsible;
  MaintenanceDetails({
    required this.equipment,
    required this.task,
    required this.lastUpdate,
    required this.situationBefore,
    required this.stepsTaken,
    required this.toolsUsed,
    required this.situationResolved,
    required this.situationAfter,
    required this.personResponsible,
  });

  Map<String, dynamic>toJson(){
    return{
      'equipment':equipment,
      'task':task,
      'lastUpdate':lastUpdate.toIso8601String(),
      'situationBefore':situationBefore,
      'stepsTaken':stepsTaken,
      'toolsUsed':toolsUsed,
      'situationResolved':situationResolved,
      'situationAfter':situationAfter,
      'personResponsible':personResponsible,
    };
  }
  factory MaintenanceDetails.fromJson(Map<String, dynamic>json){
    return MaintenanceDetails(
      equipment: json['equipment'], 
    task: json['task'], 
    lastUpdate: DateTime.parse(json['lastUpdate']),
     situationBefore: json['situationBefore'], 
     stepsTaken: List<String>.from(json['stepsTaken']),
    toolsUsed: List<String>.from(json['toolsUsed']),
    situationResolved:json['situationResolved'],
     situationAfter: json['situationAfter'], 
     personResponsible: json['personResponsible']);

  }

  MaintenanceDetails toMaintenanceDetails(){
    return MaintenanceDetails(
      equipment: equipment,
       task: task, 
       lastUpdate: lastUpdate,
       // Check on the below if the behavior causes something useful
        situationBefore: situationBefore, 
        stepsTaken: stepsTaken,
         toolsUsed: toolsUsed, 
         situationResolved: situationResolved,
          situationAfter: situationAfter,
           personResponsible: personResponsible
           );
  }
}
class FailureHistory extends StatefulWidget {
  String subprocess;
  FailureHistory({required this.subprocess});
  @override
  _FailureHistoryState createState() => _FailureHistoryState();
}

class _FailureHistoryState extends State<FailureHistory> {
  List<MaintenanceEntry> maintenanceEntries = [];
  Map<String, List<MaintenanceEntry>> maintenanceEntriesEquipment = {};
  List<MaintenanceEntry> maintenanceEntries=[];
  Map<String, List > 

  bool _updateExisting = false;
  @override
  void initState() {
    super.initState();
    _loadMaintenanceEntries();
  }

  @override
  Widget build(BuildContext context) {
    _loadMaintenanceEntries();

    return Scaffold(
      appBar: AppBar(
        title: Text('Failure Maintenance Checklist'),

      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DataTable(columns: [
              DataColumn(label: Text('Equipment')),
              DataColumn(label: Text('Maintenance Task')),
              DataColumn(label: Text('Previuos Occurence')),
              DataColumn(label: Text('Duration of Maintenance ')),
              DataColumn(label: Text('Person Responsible'))
            ], rows: _buildMaintenanceRows(),
            border: TableBorder.all(),),
            SizedBox(height: 20,),
            IconButton(onPressed: _addNewEntry, icon: Icon(Icons.add)
            )
          ],
        ),
      ),
    );
  }
List<DataRow> _buildMaintenanceRows(){
  List<DataRow> rows=[];
  Set<String> uniqueEntries=Set<String>();

  maintenanceEntriesEquipment.forEach((equipment, entries) {
rows.add(
  DataRow(cells: [
    DataCell(
      SizedBox.expand(
        child: 
        TextButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>MaintenanceDetailsPage(details: entries.first.toMaintenanceDetails())));
        },)
        Text(equipment),)),
        DataCell(SizedBox()),
        DataCell(SizedBox()),
        DataCell(SizedBox()),
        DataCell(SizedBox())
  ])
      );
      entries.forEach((entry) {
String entryKey='$equipment - ${entry.task}';

if(!uniqueEntries.contains(entryKey)){
  rows.add(
    DataRow(cells: [
      DataCell(SizedBox()),
      DataCell( TextButton(

        onPressed: (){
          _addProcedure(context);
        },
        child: Text(entry.task),
      )),

      DataCell(TextButton(
        onPressed: (){},
        child: Text(entry.lastUpdate),)),
        DataCell(TextButton(
          onPressed: (){
            _addApprover(context);
          },
          child: Text(entry.responsiblePerson),))
    ])
  );
  uniqueEntries.add(entryKey);
}
       });


       //  add an empty rows as seperator
       rows.add(DataRow(cells: List.generate(5, (_) => DataCell((SizedBox())))));

 } );
 return rows;


   }
   void _addNewEntry(){
    showDialog(context: context,

  
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState){
        return AlertDialog(
          title: Text('Add New Entry'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,

            children: [
              ListTile(
                title: Text('Create New'),
                leading: Radio(value: false, 
                groupValue: _updateExisting,
                 onChanged: (value){
                  setState((){
                    _updateExisting=value as bool;
                  });
                 }),
              ),

              ListTile(
                title: Text('Update Existing'),
                leading: Radio(
                value: true,  
                groupValue: _updateExisting,
                onChanged: (value){
                  setState(() {
                    
                  },);
                },),
              )
            ],),
            actions: [TextButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: Text('Cancel')),
            TextButton(onPressed: (){
              Navigator.of(context).pop();
              if(_updateExisting){
                _showExistingEntriesDialog();
              }else{
                _showEntryForm('');
              }
            }, child: Text('Next'))
            ],
        );
      });
    });
   }

   void _showExistingEntriesDialog(){
    showDialog(context: context, builder: 
    (BuildContext context){
      return AlertDialog(
        title: Text('Select Entry to Update'),
        content: Column(
          children: maintenanceEntriesEquipment.keys.map((equipment){
            return ListTile(
              title: Text(equipment),
              onTap: (){
                Navigator.of(context).pop();
                _showEntryForm(equipment);
              },
            );
          }).toList(),
        ),
      );
    }
    );
   }

   void _showEntryForm(String equipment){
    //Initialize form field values with empty strings

    String task='';
    String lastUpdate='';
    String duration='';
    String responsiblePerson='';

    showDialog(context: context, builder: (BuildContext  context){
      return AlertDialog(
        title: Text('Add new Entry'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: equipment,
                decoration: InputDecoration(labelText: 'Equipment'),
                onChanged: (value){
                  equipment=value;
                },
                enabled: equipment.isEmpty,//Make equipment editable if its empty
              ),
              TextFormField(

                decoration: InputDecoration(labelText: 'Task'),
                onChanged: (value){
                  task=value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Update/Frequency'),
                onChanged: (value){
                  lastUpdate=value;

                },
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Duration of Update'),
                onChanged: (value){
                  duration=value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Responsible Person'),
                onChanged: (value){
                  responsiblePerson=value;
                },
              )
            ],
          ),),
          actions: [
            TextButton(onPressed: (){
              Navigator.of(context).pop();

            }, child: Text('Cancel')),
            TextButton(onPressed: (){
              setState(() {
                //Create a new entry with the provided form field values
                maintenanceEntries.add(MaintenanceEntry(equipment: equipment, task: task, lastUpdate: lastUpdate, duration: duration, responsiblePerson: responsiblePerson));
              });
              _saveMaintenanceEntries();
              Navigator.of(context).pop();
            }, child: Text('Save'))
          ],
      );
    });
   }
Future<void> _addProcedure(BuildContext context) async{
  List<TextEditingController> proceduresController=[TextEditingController()];

  TextEditingController situationBefore=TextEditingController();
  bool situationResolved=false;
  showDialog(context: context, builder: (BuildContext dialogContext){
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
      return AlertDialog(
        title: Text('List of Procedures'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: situationBefore,
                decoration: InputDecoration(
                  labelText: 'Current Situation',
                  suffixIcon: Row(mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: (){}, icon: Icon(Icons.attach_file)),
                    IconButton(onPressed: (){}, icon: Icon(Icons.image))
                  ],) 
                ),
              ),
              for(int i=1;i<proceduresController.length;i++)
              TextField(
                controller: proceduresController[i],
                decoration: InputDecoration(
                  labelText: 'Step $i',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: (){}, icon: Icon(Icons.image))
                    ],)
                ),
                onChanged: (value){},
              ),
              SizedBox(height: 5,),
              TextButton(onPressed: (){
                setState((){
                  proceduresController.add(TextEditingController());
                })
              }, child: Text('Add Steps Taken')),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [IconButton(onPressed: (){
                  _addEquipmentUsed(context);
                }, icon: Icon(Icons.build_circle)),
                Text('List of Equipment Used')],
              )

            ],),
        ),
        actions: [Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Text('Was Situation Resolved ?'),
              Checkbox(value: false, onChanged: (value){
                setState(() {
                  situationResolved=value as bool;
                },);
              })
            ],)
          ],
        )],
      );
    });

  });
}

   Future<void> _loadMaintenanceEntries(){
    return AlertDialog()
  }
}
  

*/