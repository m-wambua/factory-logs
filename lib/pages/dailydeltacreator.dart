import 'package:collector/pages/delltafilemanager.dart';
import 'package:collector/pages/file_manager.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/subdeltacreatorpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DailyDeltaCreator extends StatefulWidget {
  final String processName;
  final List<String>? subdeltas;
  const DailyDeltaCreator({
    Key? key,
    required this.processName,
    this.subdeltas,
    //Accept the call back
  }) : super(key: key);
  @override
  _DailyDeltaCreatorState createState() => _DailyDeltaCreatorState();
}

class _DailyDeltaCreatorState extends State<DailyDeltaCreator> {
  late List<String> _subdeltas;

  List<NotificationModel> _notifications = [];
  bool _isSaving = false;

  @override 
  void initState(){
    super.initState();
    // Use the passed subdeltas if available, otherwuse use a default list
    _subdeltas = widget.subdeltas ?? [

      'Subdelta 1',
      'Subdelta 2',
      'Subdelta 3',
      'Subdelta 4',
      
    ];
  }

  @override 
  Widget build (BuildContext context){
    return Scaffold( 
appBar: AppBar( 
  title: Text('Delta\'s Creator - ${widget.processName}'),
  actions: [ 
    IconButton(onPressed: (){
      // Save functionality if needed
      _saveDeltaAndSubdletas();
    }, icon: Icon(Icons.save)),
  ],
),
body: SingleChildScrollView( 
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column( 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ 
        for (int index=0; index<_subdeltas.length;index++)
        Card( 
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile( 
            title: Text(_subdeltas[index]),
            trailing: IconButton( 
              
              onPressed: (){
              _deleteSubdelta(index);
            },
            icon: Icon(Icons.delete),),
            onTap: (){
              Navigator.push( context
                , MaterialPageRoute(builder: (context)=>SubDeltaCreatorPage(subdeltaName:_subdeltas[index])));
            },
            onLongPress: (){
          _renameSubdelta(index);
            },
          ),
        ),
        SizedBox(height: 20,),
        ElevatedButton(onPressed: (){
          _createNewSubdelta();
        }, child: Text(' Add New SubDelta'))
      ],
    ),
   ),
),

    );
  }

  void _createNewSubdelta() async {
    String? newSubDeltaName;
    newSubDeltaName=await showDialog<String>(context: context, 
    builder:(context){
      String tempSubdelta='';
      return AlertDialog( 
        title: Text( 'Create New SubDelta'),
        content: TextField( 
          decoration: InputDecoration( 
            labelText: 'SubDelta Name'
          ),
          onChanged: (value) {
            tempSubdelta=value.trim();

          },
        ),
        actions: [ 
          TextButton(onPressed: (){
            Navigator.pop(context ,
            tempSubdelta.isEmpty? null :tempSubdelta);
          }, child: Text('Create'))
        ],
      );
    });
    if(newSubDeltaName !=null && newSubDeltaName.isNotEmpty){
      setState(() {
        
        _subdeltas.add(newSubDeltaName!);
      });
    }
  }
void _deleteSubdelta(int index){
  setState(() {
    _subdeltas.removeAt(index);
  });
}

void _renameSubdelta(int index) async {
  String? newSubdletaName;
  newSubdletaName=await showDialog<String>(context: context,
  
  builder: (context) {
    String tempSubDeltaName='';
    return AlertDialog( 
      title: Text('Rename Subdelta'),
      content: TextField( 
        decoration: InputDecoration( 
          labelText: ' New Name',
        ),
        onChanged: (value){
          tempSubDeltaName=value.trim();

        },
      ),
      actions: [ 
        TextButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text('Cancel')),
        TextButton(onPressed: (){
          Navigator.pop(context,'');
        }, child: Text('Clear')),
        ElevatedButton(onPressed: (){
          Navigator.pop(context, tempSubDeltaName.isEmpty? null:tempSubDeltaName );
        }, child: Text('Rename'))
      ],
    );

  },);
  if(newSubdletaName!=null && newSubdletaName.isNotEmpty){
    setState(() {
      _subdeltas[index]=newSubdletaName!;
    });
  }
}

void _saveDeltaAndSubdletas() async {
setState(() {
  _isSaving=true;

});
try{
  // load the existing dletas from the JSON file
  Map<String, List<String>> existingDeltas= await DeltaFileManager.loadDeltas();
  existingDeltas[widget.processName]=_subdeltas;
  // save the new deltas to the JSON file
await  DeltaFileManager.saveDeltas(existingDeltas);

ScaffoldMessenger.of(context).showSnackBar( 
  SnackBar(content: Text('Process and SubDeltas saved Succesfully')),
);
// Update Landing
Navigator.pop(context); // Go Back to Landing Page
// Update process State

// Navigator to the dynamic page with subdeltas data
Navigator.pushNamed(context,
 '/${widget.processName}',
 arguments: { 
  'processName': widget.processName,
  'subpdeltas':_subdeltas,
 });




  //Add or Update the current
}
 catch (e){
  print('Error Saving process and SubDeltas: $e');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error Saving process and SubDeltas: $e')),
  );
}
finally{
  setState(() {
    _isSaving=false;
  });
}
}
}
