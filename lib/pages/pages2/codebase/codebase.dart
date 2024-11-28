import 'dart:io';

import 'package:collector/widgets/appassets.dart';
import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final List<File> _uploadedFiles = [];
  bool _uploadComplete = false;

  void _handleFileUpload(List<File> files) {
    setState(() {
      _uploadedFiles.addAll(files);
      _uploadComplete = true; // For demo, assume upload is complete
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Image.asset(AppAssets.deltalogo),
              ),
              const Text('Upload Code Base'),
            ],
          ),
        
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Upload Form
            Stack(
              children: [
                TextFormField(
                  maxLines: 20,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    // labelText: 'Upload Files and Folders',
                    // icon: Icon(Icons.folder),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onTap: () {
                    // Handle onTap (e.g., show file picker)
                  },
                  onChanged: (value) {
                    // Handle onChanged
                  },
                  onFieldSubmitted: (value) {
                    // Handle onFieldSubmitted
                  },
                  // Implement copy-paste and drag-drop actions
                ),
                Positioned.fill(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      IconButton(
                        icon: const Icon(
                          Icons.folder,
                          size: 80,
                          color: Colors.blue,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Upload Files and FOlders',
                        style: TextStyle(color: Colors.blue),
                      )
                    ]))
              ],
            ),

            const SizedBox(height: 20.0),
            // Progress Indicator or Check Mark based on upload status
            _uploadComplete
                ? const Icon(Icons.check_circle, color: Colors.green, size: 30.0)
                : const CircularProgressIndicator(),
            const SizedBox(height: 20.0),
            // Text Editor for Notes Entry
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Notes Entry',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Handle adding entries
                  },
                ),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              // Implement logic for adding entries
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Implement save logic: check if upload and compression are complete
                if (_uploadComplete) {
                  // Save logic
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Save Successful'),
                        content: const Text('Upload and compression complete.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Display a status indicator and message
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Upload or Compression Incomplete'),
                        content: const Text(
                            'Please wait for upload and compression to complete.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
