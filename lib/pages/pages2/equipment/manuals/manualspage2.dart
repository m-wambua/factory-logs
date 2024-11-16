


import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Manual {
  final String name;
  final String updatedBy;
  final DateTime timeStamp;
  Manual(this.name, this.updatedBy, this.timeStamp);
}

class ManualsPage extends StatefulWidget {
  @override
  State<ManualsPage> createState() => _ManualsPageState();
}

class _ManualsPageState extends State<ManualsPage> {
   // final ManualServices manualServices = ManualServices(() => null);
  late Map<String, List<String>> manualPathsMap = {};

  @override
  void initState() {
    super.initState();
    _loadSavedManuals();
  }

  @override
  Widget build(BuildContext context) {
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;
    _createApparatusManualsFolder(subprocess);

    return Scaffold(
      appBar: AppBar(
        title: 
         Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Image.asset(AppAssets.deltalogo),
              ),
              Text('Manuals for ${subprocess}'),
            ],
          ),
        
       
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Display existing manual cards
            _buildManualCards(subprocess),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddManualDialog(context, subprocess);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildManualCards(String subprocess) {
    List<String>? manuals = manualPathsMap[subprocess];
    if (manuals == null || manuals.isEmpty) {
      return Center(
        child: Text('No manuals available'),
      );
    }

    return Column(
      children: manuals.map((manualPath) {
        return ManualCard(pdfFilePath: manualPath);
      }).toList(),
    );
  }

  void _createApparatusManualsFolder(String subprocess) {
    Directory manualsDirectory =
        Directory('services/manuals_and_images/$subprocess');
    bool exists = manualsDirectory.existsSync();
    if (!exists) {
      manualsDirectory.createSync(recursive: true);
    }
  }

  void _showAddManualDialog(BuildContext context, String subprocess) {
    String manualName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Manual'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Enter manual name'),
                onChanged: (value) {
                  manualName = value;
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () {
                      _uploadPDF(context, subprocess, manualName);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () {
                      _captureImage(context, subprocess, manualName);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save the manual and close the dialog
                _saveManual(context, subprocess, manualName);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadPDF(
      BuildContext context, String subprocess, String manualName) async {
    // Implement PDF upload logic here
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowedExtensions: ['.*'],
      );
      if (result != null) {
        File file = File(result.files.single.path!);
        // Do something with the selected PDF file
        _processFile(context, file, subprocess, manualName);
      } else {
        print('User canceled PDF upload');
      }
    } catch (e) {
      print('Error uploading PDF: $e');
    }
  }

  void _captureImage(
      BuildContext context, String subprocess, String manualName) {
    // Implement image capture logic here
  }
  void _saveManual(
      BuildContext context, String subprocess, String manualName) async {
    String manualPath = 'services/manuals_and_images/$subprocess/$manualName';
    manualPathsMap.putIfAbsent(subprocess, () => []).add(manualPath);

    // Save manual path to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(subprocess, manualPathsMap[subprocess]!);

    // Update the state to reflect the changes
    setState(() {});

    // Show a success message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Manual saved successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // Close the success dialog
            },
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  void _processFile(BuildContext context, File file, String subprocess,
      String manualName) async {
    // Display a circular progress indicator while uploading
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (context) => AlertDialog(
        title: Text('Uploading'),
        content: CircularProgressIndicator(),
      ),
    );

    try {
      // Simulate uploading delay
      await Future.delayed(Duration(seconds: 2));
      // Move file to the desired directory
      String newPath = 'services/manuals_and_images/$subprocess/$manualName';
      await file.copy(newPath);
      // Close the progress dialog
      Navigator.of(context).pop();
      // Show a success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('File uploaded successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the success dialog box
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      print('Error uploading file: $e');
      // Close the progress dialog
      Navigator.of(context).pop();
      // Show an error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to upload file. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the error dialog box
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _loadSavedManuals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (String key in prefs.getKeys()) {
        List<String>? savedManuals = prefs.getStringList(key);
        if (savedManuals != null) {
          manualPathsMap[key] = savedManuals;
        }
      }
    });
  }
}

class ManualCard extends StatelessWidget {
  final String pdfFilePath;
  const ManualCard({Key? key, required this.pdfFilePath}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String manualName = basenameWithoutExtension(pdfFilePath);
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        autofocus: true,
        leading: Icon(Icons.picture_as_pdf),
        title: Text(manualName),
        onTap: () {
          openPDF(context, pdfFilePath);
        },
      ),
    );
  }

  void openPDF(BuildContext context, String pdfFilePath) async {
    try {
      final pdfViewer = await PDFDocument.fromFile(File(pdfFilePath));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PDFViewer(document: pdfViewer),
        ),
      );
    } catch (e) {
      print('Error opening PDF: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to open PDF.'),
              SizedBox(height: 10),
              Text(
                  'Would you like to open the PDF with your system\'s PDF viewer?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _openPDF(pdfFilePath);
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
    }
  }

  void _openPDF(String pdfFilePath) {
    try {
      Process.run('xdg-open', [pdfFilePath]);
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }

  void _showLoginPopUp(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Login'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      //Perform Login Logic
                      //Update widget with login information
                      Navigator.of(context).pop();
                    },
                    child: Text('Login'))
              ],
            ));
  }
}


