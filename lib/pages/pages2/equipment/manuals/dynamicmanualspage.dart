import 'dart:convert';
import 'dart:io';

import 'package:collector/pages/pages2/equipment/manuals/manualsdetails.dart';
import 'package:collector/pages/pages2/equipment/manuals/manualspage2.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddManualWidget extends StatefulWidget {
  final void Function(
      String header, String comment, String? filePath, String fileName) onSave;
  AddManualWidget({Key? key, required this.onSave}) : super(key: key);
  @override
  _AddManualWidgetState createState() => _AddManualWidgetState();
}

class _AddManualWidgetState extends State<AddManualWidget> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  String? _filePath;
  String? _fileName;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Manual'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _headerController,
            decoration: InputDecoration(labelText: 'Header'),
          ),
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: _commentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(labelText: 'Comment'),
              )),
              IconButton(
                  onPressed: () async {
                    // Handle attatchement for PDF files
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                            type: FileType.custom, allowedExtensions: ['pdf']);
                    if (result != null) {
                      setState(() {
                        _filePath = result.files.single.path!;
                        _showRenameDialog(context);
                      });
                    }
                  },
                  icon: Icon(Icons.attach_file)),
              IconButton(
                  onPressed: () async {
                    // Handle pit picture action for images
                    final picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                  },
                  icon: Icon(Icons.image))
            ],
          )
        ],
      ),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close)),
        TextButton(onPressed: _saveManual, child: Text('Save Manual'))
      ],
    );
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Rename File'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: ' New File Name'),
                  onChanged: (value) {
                    // Update file name when user types in the text field
                    _fileName = value;
                  },
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _fileName = null;
                  },
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _saveManual();
                  },
                  child: Text('Save'))
            ],
          );
        });
  }

  void _clearFields() {
    setState(() {
      _headerController.clear();
      _commentController.clear();
      _filePath = null;
      _fileName = null;
    });
  }

  void _saveManual() {
    final header = _headerController.text;
    final comment = _commentController.text;
    final fileName = _fileName ?? '';
    widget.onSave(header, comment, _filePath, fileName);
    _clearFields();
  }
}

class DynamicManualsPage extends StatefulWidget {
  final String processName;
  final String subprocessName;
  final String equipmentName;
  const DynamicManualsPage(
      {super.key,
      required this.processName,
      required this.subprocessName,
      required this.equipmentName});

  @override
  State<DynamicManualsPage> createState() => _DynamicManualsPageState();
}

class _DynamicManualsPageState extends State<DynamicManualsPage> {
  List<Map<String, String>> _manuals = [];

  @override
  Widget build(BuildContext context) {
    _loadManuals();
    _createApparatusManualFolder(widget.equipmentName);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Image.asset(AppAssets.deltalogo),
            ),
            Text(
                'Manuals for ${widget.equipmentName} for processName ${widget.processName} and subprocessName ${widget.subprocessName}'),
            IconButton(
                onPressed: () {
                  handleUpload(context);
                },
                icon: Icon(Icons.upload))
          ],
        ),
        actions: [
          IconButton(onPressed: _deleteAllManuals, icon: Icon(Icons.delete))
        ],
      ),
      body: ListView.builder(
          itemCount: _manuals.length,
          itemBuilder: (context, index) {
            final manual = _manuals[index];
            return GestureDetector(
              onTap: () async {
                //Check if filePath ends with .pdf
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManualsDetails(
                            header: manual['header'] ?? '',
                            comment: manual['comment'] ?? '',
                            filePath: manual['copiedFilePath'] ?? '')));
              },
              child: Card(
                child: ListTile(
                  title: Text(
                    manual['header'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(manual['comment'] ?? ''),
                  trailing: _buildFileTypeStatus(manual['file_path']),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddManualDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddManualDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) =>
            AddManualWidget(onSave: (header, comment, filePath, fileName) {
              _addManual(header, comment, filePath, fileName);
            }));
  }

  void _createApparatusManualFolder(String equipmentName) async {
    String folderPath = 'services/manuals/files_and_folders/$equipmentName';
    Directory manualsDirectory = Directory(folderPath);
    bool exists = manualsDirectory.existsSync();
    if (!exists) {
      manualsDirectory.createSync(recursive: true);
      Directory filesDirectory = Directory('${manualsDirectory.path}/files');
      Directory imageDirectory = Directory('${manualsDirectory.path}/images');
      filesDirectory.createSync();
      imageDirectory.createSync();
    }
  }

  void _deleteAllManuals() {
    setState(() {
      _manuals.clear();
    });
    _saveManuals();
    print('Deleting all manuals..............');
  }

  Future<String?> _addManual(
      String header, String comment, String? filePath, String? fileName) async {
// Save the parameters to the JSON file
    String? copiedFilePath;
    await _saveManuals();
    print('Adding a parameters.............');

    if (filePath != null) {
      try {
        String folderPath =
            'services/manuals/file_and_folders/${widget.equipmentName}';
        Directory targetDir = Directory(folderPath);
        // Determine the subdirectory based on the file type
        String subDir = filePath.endsWith('.pdf') ? 'files' : 'images';
        Directory subdir = Directory('${targetDir.path}/$subDir');
        if (!await subdir.exists()) {
          subdir.createSync(recursive: true);
        }
        // Get the file name from the file path
        //copy the file to the subdirectory

        String fileName = filePath.split('/').last;
        if (fileName != null) {
          // if user provided a new file name concatenate it with the original
          fileName = fileName! + '_' + fileName;
        } else {
          // if user chose to retain the name , concatenate the header with the original file name
          if (header.isNotEmpty) {
            fileName = header! + '_' + fileName;
          }
        }
        File originalFile = File(filePath);
        File copiedFile = await originalFile.copy('${subdir.path}/$fileName');
        copiedFilePath = copiedFile.path;
        print('File is copied to ${copiedFile.path}');
        print('file path is now${filePath}');
        Map<String, String> manual = {
          'header': header,
          'comment': comment,
          'file_path': copiedFilePath ?? '',
          'copiedFilePath': copiedFilePath ?? ''
        };
        setState(() {
          _manuals.add(manual);
        });
        await _saveManuals();
      } catch (e) {
        print(' Error copying file $e');
      }
    }
    return copiedFilePath;
  }

  void _refreshedmanuals() {
    print('Refreshing manuals.......');
  }

  Future<void> _loadManuals() async {
    final String folderPath =
        'services/manuals/files_and_folders/${widget.equipmentName}';
    final File manualFile = File('$folderPath/manuals.json');
    try {
      if (await manualFile.exists()) {
        final String jsonString = await manualFile.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _manuals =
            jsonList.map((json) => Map<String, String>.from(json)).toList();

        setState(() {});
      }
    } catch (e) {
      print('Error Loading manuals: $e');
    }
  }

  Future<void> _saveManuals() async {
    final String folderPath =
        'services/manuals/files_and_folders/${widget.equipmentName}';

    final File manualsFile = File('$folderPath/manuals.json');
    try {
      if (!await manualsFile.exists()) {
        await manualsFile.create(recursive: true);
      }
      await manualsFile.writeAsString(jsonEncode(_manuals));
    } catch (e) {
      print('Error saving manuals: $e');
    }
  }

  // function to build file type status widget
  Widget _buildFileTypeStatus(String? filePath) {
    if (filePath != null) {
      return Icon(
        filePath.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image,
        color: Colors.blue,
      );
    } else {
      return SizedBox();
    }
  }

  Future<File?> pickPDFFile() async {
    print('Starting file picker...'); // Debug log
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      print(
          'FilePicker result: ${result?.files.length ?? 'null'}'); // Debug log

      if (result != null && result.files.isNotEmpty) {
        print('File selected: ${result.files.single.path}'); // Debug log
        return File(result.files.single.path!);
      }
      print('No file selected'); // Debug log
      return null;
    } catch (e) {
      print('Error in pickPDFFile: $e'); // Debug log
      return null;
    }
  }

  Future<void> uploadPDF(File pdfFile, BuildContext context) async {
    print('Starting upload process...');
    final url = Uri.parse('http://0.0.0.0:8000/pdf-transfer');

    try {
      var request = http.MultipartRequest('POST', url);

      // Add these lines to send form fields
      request.fields['filemenu'] = 'Manuals' ?? '';
      request.fields['process_name'] = widget.processName ?? '';
      request.fields['subprocess_name'] = widget.subprocessName ?? '';
      request.fields['equipment_name'] = widget.equipmentName ?? '';

      var stream = http.ByteStream(pdfFile.openRead());
      var length = await pdfFile.length();
      var multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: pdfFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      print('Sending request...');
      var response = await request.send();
      print('Response status code: ${response.statusCode}');

      final responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        print('File uploaded successfully');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF uploaded successfully')));
          print(
              'Uploaded to:  Manuals ${widget.processName}/${widget.subprocessName}/${widget.equipmentName}');
        }
      } else {
        print('Upload failed: ${response.statusCode}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload PDF: $responseBody')));
        }
      }
    } catch (e, stackTrace) {
      print('Error uploading file: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error uploading PDF: $e')));
      }
    }
  }

  Future<void> handleUpload(BuildContext context) async {
    print('Handle upload started...'); // Debug log
    try {
      final file = await pickPDFFile();
      if (file != null) {
        print('File picked, starting upload...'); // Debug log
        await uploadPDF(file, context);
      } else {
        print('No file selected in handleUpload');
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('No file selected')));
        }
      }
    } catch (e) {
      print('Error in handleUpload: $e'); // Debug log
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
