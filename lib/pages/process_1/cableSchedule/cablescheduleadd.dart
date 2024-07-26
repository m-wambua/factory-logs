import 'dart:io';

import 'package:collector/pages/process_1/cableSchedule/cablescheduledata.dart';
import 'package:flutter/material.dart';

class UploadScreenCableSchedule extends StatefulWidget {
  const UploadScreenCableSchedule({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreenCableSchedule> {
  final List<File> _uploadedFiles = [];
  bool _uploadComplete = false;
  List<TextEditingController> notesController = [TextEditingController()];
  TextEditingController lastUpdatePerson = TextEditingController();
  void _handleFileUpload(List<File> files) {
    setState(() {
      _uploadedFiles.addAll(files);
      _uploadComplete = true;
    });
  }

  @override
  void dispose() {
    for (var controller in notesController) {
      controller.dispose();
    }
    lastUpdatePerson.dispose();
    super.dispose();
  }

  void _saveData() {
    List<String> notes =
        notesController.map((controller) => controller.text).toList();
    String updatedBy = lastUpdatePerson.text;
    List<String> uploadedFilesPaths =
        _uploadedFiles.map((file) => file.path).toList();

    UploadData data = UploadData(
        notes: notes, updatedBy: updatedBy, uploadedFiles: uploadedFilesPaths);
    print('Data Saved ${data.notes}, ${data.updatedBy}, ${data.uploadedFiles}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Cable/Update Schedule'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //Upload Form
            Stack(
              children: [
                TextFormField(
                  maxLines: 20,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onTap: () {
                    //Handle onTap(e.g show file picker)
                  },
                  onChanged: (value) {
                    // Handle onChanged
                  },
                  onFieldSubmitted: (value) {
                    //Handle onFieldSubmitted
                  },
                  // Implement copy-paste and drag-drop actions
                ),
                Positioned.fill(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.table_chart,
                          size: 200,
                          color: Colors.green,
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      ' Upload Files and Folders',
                      style: TextStyle(color: Colors.green),
                    )
                  ],
                ))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // Progess Indicator or CheckMark based on Upload Status
            _uploadComplete
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 30.0,
                  )
                : const CircularProgressIndicator(),
            const SizedBox(
              height: 20,
            ),
            for (int i = 0; i < notesController.length; i++)
              TextFormField(
                controller: notesController[i],
                decoration: InputDecoration(
                    labelText: 'Notes Entry ${i + 1}',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {},
                    )),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onChanged: (value) {},
              ),
            IconButton(
                onPressed: () {
                  setState(() {
                    notesController.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.note_add)),
            const SizedBox(
              height: 20.0,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Updated By:',
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  // Implement save logic: check if upload and compression are complete
                  if (_uploadComplete) {
                    //Save logic
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Save Successfull'),
                            content:
                                const Text('Upload and compression complete'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ok'),
                              )
                            ],
                          );
                        });
                  } else {
                    // Display a status indicator and message
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title:
                                const Text('Upload or Compression Incomplete'),
                            content: const Text(
                                ' Please wait for upload and compression to complete'),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Ok'))
                            ],
                          );
                        });
                  }
                  _saveData();
                },
                child: const Text('Save'))
          ],
        ),
      ),
    );
  }
}
