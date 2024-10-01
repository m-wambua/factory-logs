import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FolderUploadPage extends StatefulWidget {
  @override
  _FolderUploadPageState createState() => _FolderUploadPageState();
}

class _FolderUploadPageState extends State<FolderUploadPage> {
  String? folderName;

  Future<void> pickFolder() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
      allowedExtensions: null,
      allowCompression: false,
    );

    if (result != null) {
      setState(() {
        folderName = result.files.first.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folder Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: pickFolder,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder, size: 100, color: Colors.blue),
                    SizedBox(height: 10),
                    Text(
                      folderName ?? 'Upload Folder',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
