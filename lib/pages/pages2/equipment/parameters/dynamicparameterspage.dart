import 'dart:io';

import 'package:collector/pages/pages2/equipment/parameters/parametersmodel.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

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
  final List<Map<String, String>> _parameters = [];
  List<ParameterStorage> _parameterStorage = [];
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isDropdownOpen = false;
  File? _selectedFile;
  FileType? _selectedFileType;
  bool _isLoading = true;
  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadParameters();
  }

  Future<void> _loadParameters() async {
    try {
      final loadParameters =
          await ParameterStorage.loadParameterList(widget.equipmentName);

      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          _parameterStorage = loadParameters;
          _isLoading = false; // Set loading to false
        });
      }
    } catch (e) {
      // Only show snackbar if widget is mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading spare parts: $e')));
        setState(() {
          _isLoading = false; // Set loading to false even on error
        });
      }
    }
  }

  Future<void> _saveParameters() async {
    try {
      await ParameterStorage.saveParamterList(
          _parameterStorage, widget.equipmentName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving spare parts: $e')));
    }
  }

  Future<void> _deleteParameterList(int Index) async {
    setState(() {
      ParameterStorage.deleteParameterEntry(widget.equipmentName);
    });
    await _saveParameters();
  }

  Future<void> _showDeleteConfirmation(int index) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      _deleteParameterList(index);
                    },
                    child: const Text('Delete'),
                  )
                ],
              ),
            ),
          );
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
            Text(
                'Parameters for ${widget.equipmentName} for process ${widget.processName} and subprocess ${widget.subprocessName}'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              handleUpload(context);
            },
            icon: const Icon(Icons.upload),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.delete))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _parameterStorage.isEmpty
                ? const Center(
                    child: Text('No Parameters added yet. Add yout First one!'),
                  )
                : ListView.builder(
                    itemCount: _parameterStorage.length,
                    itemBuilder: (context, index) {
                      final parameter = _parameterStorage[index];
                      return GestureDetector(
                        onTap: () async {
                          // Check if file path ends with .pdf
                        },
                        onLongPress: () => _deleteParameterList(index),
                        child: Card(
                            child: ListTile(
                          title: Text(parameter.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(parameter.description),
                        )),
                      );
                    }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createNewParameters(widget.equipmentName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addParameters() {
    if (_formKey.currentState!.validate()) {
      final newparameter = ParameterStorage(
          name: _nameController.text, description: _descriptionController.text);
      setState(() {
        _parameterStorage.add(newparameter);
      });
      _saveParameters();
      _clearForm();
      Navigator.of(context).pop();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
  }

  void _createNewParameters(String equipmentName) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              scrollable: true,
              title: const Text('Create new parameters'),
              content: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a name' : null,
                        )),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: TextFormField(
                          controller: _descriptionController,
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter a description'
                              : null,
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    IconButton(
                        onPressed: () {
                          _toggleDropdown();
                          if (_isDropdownOpen) {
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () => handleUpload(context),
                                    icon: const Icon(Icons.picture_as_pdf)),
                                const SizedBox(
                                  height: 10,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.image),
                                  onPressed: () => handleUpload(context),
                                )
                              ],
                            );
                          }
                        },
                        icon: const Icon(Icons.attach_file))
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _addParameters();
                        },
                        child: const Text(
                          'Save Parameter',
                          style: TextStyle(color: Colors.green),
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                )
              ],
            ));
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
