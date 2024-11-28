import 'dart:io';

import 'package:flutter/material.dart';

class ManualsDetails extends StatelessWidget {
  final String header;
  final String comment;
  final String filePath;
  const ManualsDetails({super.key, 
    required this.header,
    required this.comment,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    print(filePath);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Padding(padding: const EdgeInsets.all(8.0),
            
           child: Text( header,style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),), ),
           Padding(padding: const EdgeInsets.all(8.0),
           
           child:  Text(comment,style: const TextStyle(fontSize: 18),),),
           _buildFilePreview(),
          ]),
    );
  }

  Widget _buildFilePreview(){
    return FutureBuilder(future: _loadFile(), builder: (context, snapshot){
      if(snapshot.connectionState==ConnectionState.waiting){
        return const CircularProgressIndicator();

      } else if (snapshot.hasError){
        return Text('Error: ${snapshot.error}');

      }else{
        //Check the file type and display the appropriate preview
        switch(snapshot.data){
          case 'pdf':
          return Column(children: [Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20.0),
            child: const Text(
              'Click to Open the PDF',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          const SizedBox(height: 20,),
          TextButton(onPressed: (){
            //Add code to open PDF using system's PDF viewer
            _openPDF(filePath);

          }, child: const Text('Open PDF',style: TextStyle(color: Colors.blue),))
          
          ],);
          case 'image':
          return Image.file(
            File(filePath),
            width: 500,
            height: 500,

          );
          case 'unsupported':
          return const Text('Unsuppoerted file type');
          default:
          return const SizedBox();// Return empty container if file type is null or unsupported 


        }
      }
    });
  }

  Future<String?> _loadFile() async{
    if(filePath.isEmpty){
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
