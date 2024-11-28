import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManualServices {
  late Map<String, List<String>> manualPathsMap = {};
  late Function() updateState; // Callback function to update state
  String? _selectedManualPath; // Stores the path of the selected manual path
  ManualServices(this.updateState);

  void createApparatusManualsFolder(String subprocess) {
    Directory manualsDirectory =
        Directory('services/manuals_and_images/$subprocess');
    bool exists = manualsDirectory.existsSync();
    if (!exists) {
      manualsDirectory.createSync(recursive: true);
    }
  }

  void showAddManualDialog(BuildContext context, String subprocess) {
    String manualName = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Manual'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Enter manual name'),
                onChanged: (value) {
                  manualName = value;
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      _uploadPDF(context, subprocess, manualName);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save the manual and close the dialog
                _saveManual(context, subprocess, manualName);
              },
              child: const Text('Save'),
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

    // Call the updateState callback to notify the widget of changes
    updateState();

    // Show a success message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Manual saved successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // Close the success dialog
            },
            child: const Text('OK'),
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
      builder: (context) => const AlertDialog(
        title: Text('Uploading'),
        content: CircularProgressIndicator(),
      ),
    );

    try {
      // Simulate uploading delay
      await Future.delayed(const Duration(seconds: 2));
      // Move file to the desired directory
      String newPath = 'services/manuals_and_images/$subprocess/$manualName';
      await file.copy(newPath);
      // Close the progress dialog
      Navigator.of(context).pop();
      // Call the updateState callback to notify the widget of changes
      updateState();
      // Show a success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('File uploaded successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the success dialog box
              },
              child: const Text('OK'),
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
          title: const Text('Error'),
          content: const Text('Failed to upload file. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the error dialog box
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> loadSavedManuals() async {
updateState();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String key in prefs.getKeys()) {
      List<String>? savedManuals = prefs.getStringList(key);
      if (savedManuals != null) {
        manualPathsMap[key] = savedManuals;
      }
    }
    // Call the updateState callback to notify the widget of changes
    
  }
}
