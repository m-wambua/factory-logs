import 'dart:io';

import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final String header;
  final String description;
  final String filePath;

  const DetailsPage({super.key, 
    required this.header,
    required this.description,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    print(filePath);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              header,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              description,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          _buildFilePreview(),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    return FutureBuilder(
      future: _loadFile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Check the file type and display the appropriate preview
          switch (snapshot.data) {
            case 'pdf':
              return Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20.0),
                    child: const Text(
                      'Click to Open The PDF', // Add PDF preview here
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // Add code to open PDF using system's PDF viewer
                      _openPDF(filePath);
                    },
                    child: const Text(
                      'Open PDF',
                      style: TextStyle(
                        color: Colors
                            .blue, // Resemble the usual colors of an "Open PDF" message
                      ),
                    ),
                  ),
                ],
              );
            case 'image':
              return Image.file(
                File(filePath),
                width: 500,
                height: 500,
              );
            case 'unsupported':
              return const Text('Unsupported file type');
            default:
              return const SizedBox(); // Return empty container if file type is null or unsupported
          }
        }
      },
    );
  }

  Future<String?> _loadFile() async {
    if (filePath.isEmpty) {
      return null;
    }

    try {
      // Check if the file exists
      File file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      // Check file type based on extension
      if (filePath.endsWith('.pdf')) {
        return 'pdf';
      } else if (filePath.endsWith('.jpg') ||
          filePath.endsWith('.jpeg') ||
          filePath.endsWith('.png')) {
        return 'image';
      } else {
        // Unsupported file type
        return 'unsupported';
      }
    } catch (e) {
      print('Error loading file: $e');
      return null;
    }
  }

  void _openPDF(String pdfFilePath) {
    try {
      Process.run('xdg-open', [pdfFilePath]);
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }
}
