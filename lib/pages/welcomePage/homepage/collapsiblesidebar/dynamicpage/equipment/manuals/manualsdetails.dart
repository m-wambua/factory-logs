import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

class ManualsDetails extends StatelessWidget {
  final String header;
  final String comment;
  final String filePath;
  ManualsDetails({
    required this.header,
    required this.comment,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    print(filePath);
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Padding(padding: const EdgeInsets.all(8.0),
            
           child: Text( header,style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),), ),
           Padding(padding: const EdgeInsets.all(8.0),
           
           child:  Text(comment,style: TextStyle(fontSize: 18),),),
           _buildFilePreview(),
          ]),
    );
  }

  Widget _buildFilePreview(){
    return FutureBuilder(future: _loadFile(), builder: (context, snapshot){
      if(snapshot.connectionState==ConnectionState.waiting){
        return CircularProgressIndicator();

      } else if (snapshot.hasError){
        return Text('Error: ${snapshot.error}');

      }else{
        //Check the file type and display the appropriate preview
        switch(snapshot.data){
          case 'pdf':
          return Column(children: [Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Click to Open the PDF',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          SizedBox(height: 20,),
          TextButton(onPressed: (){
            //Add code to open PDF using system's PDF viewer
            _openPDF(filePath);

          }, child: Text('Open PDF',style: TextStyle(color: Colors.blue),))
          
          ],);
          case 'image':
          return Image.file(
            File(filePath),
            width: 500,
            height: 500,

          );
          case 'unsupported':
          return Text('Unsuppoerted file type');
          default:
          return SizedBox();// Return empty container if file type is null or unsupported 


        }
      }
    });
  }

  Future<String?> _loadFile() async{
    if(filePath==null|| filePath.isEmpty){
      return null;

    }
    try{
      // Check if the file esists
      File file =File(filePath);
      if(!await file.exists()){
        return null;

      }
      // Check file type based on extension
      if (filePath.endsWith('.pdf')){
        return 'pdf';

      }else if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg') || filePath.endsWith('.png')){
        return 'image';
      } else{
        // Unsupported file type
        return 'unsuported';

      }
    } catch(e){
      print('Error loading file: $e');
      return null;
    }

  }

  void _openPDF(String pdfFIlePath){
    try{Process.run('xdg-open', [pdfFIlePath]);
    } catch(e){
      print(' Erro opening PDF $e');
    }
  }
}
