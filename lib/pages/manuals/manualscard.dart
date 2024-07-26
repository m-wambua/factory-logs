import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class ManualCard extends StatefulWidget {
  final String pdfFilePath;
  const ManualCard({super.key, required this.pdfFilePath});

  @override
  State<ManualCard> createState() => _ManualCardState();
}

class _ManualCardState extends State<ManualCard> {
  @override
  Widget build(BuildContext context ) {
    String manualName = basenameWithoutExtension(widget.pdfFilePath);
    
    return Card(
      
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        autofocus: true,
        leading: const Icon(Icons.picture_as_pdf),
        title: Text(manualName),
        onTap: () {
          openPDF(context, widget.pdfFilePath);

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
          title: const Text('Error'),
          content: const Column(
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
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _openPDF(pdfFilePath);
              },
              child: const Text('Yes'),
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
              title: const Text('Login'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
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
                    child: const Text('Login'))
              ],
            ));
  }
}
