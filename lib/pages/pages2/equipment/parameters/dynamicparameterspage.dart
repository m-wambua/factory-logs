import 'dart:convert';
import 'dart:io';

import 'package:collector/pages/pages2/equipment/parameters/parameterdetails.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AddParameterWidget extends StatefulWidget {
  final void Function(
          String header, String description, String? filePath, String fileName)
      onSave;
  const AddParameterWidget({Key? key, required this.onSave}) : super(key: key);
  @override
  _AddParameterWidgetState createState() => _AddParameterWidgetState();
}

class _AddParameterWidgetState extends State<AddParameterWidget> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _filePath;
  String? _fileName;
  List<Map<String, String>> _parameters = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Parameter'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                controller: _descriptionController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(labelText: 'Decoration'),
              )),
              IconButton(
                  onPressed: () async {
                    // Handle Attachement action for PDF files
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                            type: FileType.custom, allowedExtensions: ['pdf']);
                    if (result != null) {
                      //File selected
                      setState(() {
                        _filePath = result.files.single.path!;
                        _showRenameDialog(context);
                      });
                    }
                  },
                  icon: Icon(Icons.attach_file)),
              IconButton(
                  onPressed: () async {
                    // Handle picture action for images
                    final picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      // Image captured
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
        TextButton(onPressed: _clearFields, child: Text('Clear All')),
        ElevatedButton(onPressed: _saveParameter, child: Text('Save Parameter'))
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
                  decoration: InputDecoration(labelText: 'New File Name'),
                  onChanged: (value) {
                    //update file name when users types in the Text field
                    _fileName = value;
                  },
                )
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _saveParameter();
                  },
                  child: Text('Save'))
            ],
          );
        });
  }

  void _clearFields() {
    setState(() {
      _headerController.clear();
      _descriptionController.clear();
      _fileName = null;
      _filePath = null;
    });
  }

  void _saveParameter() {
    final header = _headerController.text;
    final description = _descriptionController.text;
    final fileName = _fileName ?? '';
    widget.onSave(header, description, _filePath, fileName);
    _clearFields();
  }
}

class DynamicParametersPage extends StatefulWidget {
  final String processName;
  final String subprocessName;
  final String equipmentName;
  const DynamicParametersPage(
      {super.key,
      required this.processName,
      required this.subprocessName,
      required this.equipmentName});

  @override
  State<DynamicParametersPage> createState() => _DynamicParametersPageState();
}

class _DynamicParametersPageState extends State<DynamicParametersPage> {
  List<Map<String, String>> _parameters = [];

  @override
  Widget build(BuildContext context) {
    _createApparatusFolder(widget.equipmentName);
    _loadParameters();
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
                'Parameters for ${widget.equipmentName} for process ${widget.processName} and subprocess ${widget.subprocessName}'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              handleUpload(context);
            },
            icon: Icon(Icons.upload),
          ),
          IconButton(onPressed: _deleteAllParameters, icon: Icon(Icons.delete))
        ],
      ),
      body: ListView.builder(
          itemCount: _parameters.length,
          itemBuilder: (context, index) {
            final parameter = _parameters[index];
            return GestureDetector(
              onTap: () async {
                // Check if file path ends with .pdf
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailsPage(
                            header: parameter['header'] ?? '',
                            description: parameter['description'] ?? '',
                            filePath: parameter['copiedFilePath'] ?? '')));
              },
              child: Card(
                  child: ListTile(
                title: Text(parameter['header'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(parameter['description'] ?? ''),
                trailing: _buildFileTypeStatus(parameter['file_path']),
              )),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddParameterDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddParameterDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AddParameterWidget(
                onSave: (header, description, filePath, fileName) {
              _addParameter(header, description, filePath, fileName);
            }));
  }

  void _createApparatusFolder(String equipmentName) async {
    final directory = await getApplicationDocumentsDirectory();

    String folderPath = 'services/parameters/files_and_folders/$equipmentName';
    Directory parameterDirectory = Directory(folderPath);
    bool exists = parameterDirectory.existsSync();

    if (!exists) {
      parameterDirectory.createSync(recursive: true);

      // Create subdirectories for files and images
      Directory filesDirectory = Directory('${parameterDirectory.path}/files');
      Directory imagesDirectory =
          Directory('${parameterDirectory.path}/images');
      filesDirectory.createSync();
      imagesDirectory.createSync();
    }
  }

  void _deleteAllParameters() {
    setState(() {
      _parameters.clear();
    });
    _saveParameters();
    print('Deleting all parameters....');
  }

  Future<String?> _addParameter(String header, String description,
      String? filePath, String? _fileName) async {
    // Save the parameters to the Json file
    String? copiedFilePath;

    await _saveParameters();

    print('Adding a parameter');

    if (filePath != null) {
      try {
        // Get the directory where the Json file is stored
        String folderPath =
            'servives/parameters/files_and_folders/${widget.equipmentName}';
        Directory targetDir = Directory(folderPath);

        // Determine the subdirectory based on the file type
        String subDir = filePath.endsWith('.pdf') ? 'files' : 'images';

        Directory subdir = Directory('${targetDir.path}/$subDir');

        // Create the subdirectorry if it doesn't exist

        if (!await subdir.exists()) {
          subdir.createSync(recursive: true);
        }

        // Get the filename from the file path

        // Copy the file to the subdirectory

        String fileName = filePath.split('/').last;

        if (_fileName != null) {
          //if the user provided a new file name, concatenate it with the original name
          fileName = fileName! + '_' + fileName;
        } else {
          // if  use chose to retain the nam, concatenate the header with the original filename
          if (header.isNotEmpty) {
            fileName = header! + '_' + fileName;
          }
        }
        File originalFile = File(filePath);
        File copiedFile = await originalFile.copy('${subdir.path}/$fileName');
        copiedFilePath = copiedFile.path;
        filePath = copiedFilePath;
        print('File copied to:${copiedFile.path}');
        print('File path is now${filePath}');

        Map<String, String> parameter = {
          'header': header,
          'description': description,
          'file_path': copiedFilePath ?? '',
          'copiedFilePath': copiedFilePath ?? ''
        };

        setState(() {
          _parameters.add(
              // Save the file path in the JSON file
              parameter);
        });
        await _saveParameters();
      } catch (e) {
        print('Error copying file $e');
      }
    }
    return copiedFilePath;
  }

  Future<void> _loadParameters() async {
    final String folderPath =
        'services/parameters/files_and_folders/${widget.equipmentName}';
    final File paramerFile = File('$folderPath/parameters.json');
    try {
      if (await paramerFile.exists()) {
        final String jsonString = await paramerFile.readAsString();
        final List<dynamic> JsonList = jsonDecode(jsonString);
        _parameters =
            JsonList.map((json) => Map<String, String>.from(json)).toList();
        setState(() {}); // Trigger a rebuild after loading parameters
      }
    } catch (e) {
      print('Error loading parameters $e');
    }
  }

  Future<void> _saveParameters() async {
    final String folderPath =
        'services/parameters/files_and_folders/${widget.equipmentName}';
    final File parameterFile = File('$folderPath/parameters.json');
    try {
      if (!await parameterFile.exists()) {
        await parameterFile.create(recursive: true);
      }
      await parameterFile.writeAsString(jsonEncode(_parameters));
    } catch (e) {
      print('Error saving parameters: $e');
    }
  }

  // Function to build file types status widget
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
      request.fields['filemenu'] = 'Parameters' ?? '';
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
              'Uploaded to:  Parameters ${widget.processName}/${widget.subprocessName}/${widget.equipmentName}');
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
