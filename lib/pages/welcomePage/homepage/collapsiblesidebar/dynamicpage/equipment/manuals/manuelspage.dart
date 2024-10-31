import 'dart:convert';
import 'dart:io';

import 'package:collector/pages/welcomePage/homepage/collapsiblesidebar/dynamicpage/equipment/manuals/manualsdetails.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddManualWidget extends StatefulWidget {
  final void Function(
      String header, String comment, String? filePath, String fileName) onSave;
  const AddManualWidget({Key? key, required this.onSave}) : super(key: key);
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
                    // Handle attacment for PDF files
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
                    //Handle picture action for images
                    final picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      //Image captures
                      setState(() {
                        _filePath = image.path;
                        _showRenameDialog(context);
                      });
                    }
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
            title: Text('Renam File'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'New File Name'),
                  onChanged: (value) {
                    //Update file name when  user types in the text field
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

class ManualsPage extends StatefulWidget {
  @override
  State<ManualsPage> createState() => _ManualsPageState();
}

class _ManualsPageState extends State<ManualsPage> {
  List<Map<String, String>> _manuals = [];
  late String _subprocess;
  @override
  Widget build(BuildContext context) {
    _subprocess = ModalRoute.of(context)?.settings.arguments as String;
    _loadManuals();

    final String subprocess = _subprocess;
    _createApparatusManualFolder(subprocess);

    return Scaffold(
      appBar: AppBar(
        title:  Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Image.asset(AppAssets.deltalogo),
              ),
              Text('Manuals for ${_subprocess}'),
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
                            filePath: manual['copiedFilePath'] ?? '',
                          )));
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
        },
      ),
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

  void _createApparatusManualFolder(String subprocess) async {
    String folderPath = 'services/manuals/files_and_folders/$subprocess';
    Directory manualsDirectory = Directory(folderPath);
    bool exists = manualsDirectory.existsSync();
    if (!exists) {
      manualsDirectory.createSync(recursive: true);
      Directory filesDirectory = Directory('${manualsDirectory.path}/files');
      Directory imagesDirectory = Directory('${manualsDirectory.path}/images');
      filesDirectory.createSync();
      imagesDirectory.createSync();
    }
  }

  void _deleteAllManuals() {
    setState(() {
      _manuals.clear();
    });
    _saveManuals();
    print('Deleting all manuals.......');
  }

  Future<String?> _addManual(String header, String comment, String? filePath,
      String? _fileName) async {
    // Save the parameters to the JSON File
    String? copiedFilePath;
    await _saveManuals();
    print('Adding a parameter..............');

    if (filePath != null) {
      try {
        String folcderPath = 'services/manuals/file_and_folders/$_subprocess';
        Directory targetDir = Directory(folcderPath);
        // Determine the subdirectory based on the file type
        String subDir = filePath.endsWith('.pdf') ? 'files' : 'images';
        Directory subdir = Directory('${targetDir.path}/$subDir');

        if (!await subdir.exists()) {
          subdir.createSync(recursive: true);
        }

        // Get the file name from the file Path

        // copy the file to the subdirectory
        String fileName = filePath.split('/').last;
        if (_fileName != null) {
          //if user provided a new file name, concatenate it with the original name
          fileName = _fileName! + '_' + fileName;
        } else {
          // if user chose to retain the name, concatenate the header with the original file name
          if (header.isNotEmpty) {
            fileName = header! + '_' + fileName;
          }
        }
        File originalFile = File(filePath);
        File copiedFile = await originalFile.copy('${subdir.path}/$fileName');
        copiedFilePath = copiedFile.path;
        filePath = copiedFilePath;
        print(' FIle is copied to ${copiedFile.path}');
        print('File path is now${filePath}');
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
        print('Error copying file: $e');
      }
    }
    return copiedFilePath;
  }

  void _refreshedmanuals() {
    print('Refreshing manuals.....');
  }

  Future<void> _loadManuals() async {
    final String folderPath = 'services/manuals/files_and_folders/$_subprocess';
    final File manuallFile = File('$folderPath/manuals.json');
    try {
      if (await manuallFile.exists()) {
        final String jsonString = await manuallFile.readAsString();
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
    final String folderPath = 'services/manuals/files_and_folders/$_subprocess';
    final File manualsFile = File('$folderPath/manuals.json');
    try {
      if (!await manualsFile.exists()) {
        await manualsFile.create(recursive: true);
      }
      await manualsFile.writeAsString(jsonEncode(_manuals));
    } catch (e) {
      print('Error saving  Manuals: $e');
    }
  }

  // function to build file type status widge

  Widget _buildFileTypeStatus(String? filePath) {
    if (filePath != null) {
      return Icon(
        filePath.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image,
        color: Colors.blue,
      );
    } else {
      return SizedBox(); // Return empty container if file path is null
    }
  }
}
