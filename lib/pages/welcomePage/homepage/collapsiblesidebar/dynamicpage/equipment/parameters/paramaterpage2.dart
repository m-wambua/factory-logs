/*
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:shared_preferences/shared_preferences.dart';

import 'parameterdetails.dart';

class ParameterPage extends StatefulWidget {
  @override
  _ParameterPageState createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _parameterDataList = [];
  late SharedPreferences _prefs;
  late Map<String, List<String>> parameterPathsMap = {};

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedParameters();
  }

  @override
  Widget build(BuildContext context) {
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;
    _createApparatusParametersFolder(subprocess);
    return Scaffold(
      appBar: AppBar(
        title: Text('Parameters for : $subprocess'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAllParameters();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _parameterDataList.length,
        itemBuilder: (context, index) {
          final parameterData = _parameterDataList[index];
          return Card(
            child: ListTile(
              title: Text(parameterData['header']),
              subtitle: Text(parameterData['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteParameter(index);
                    },
                  ),
                  _buildFileUploadedIndicator(parameterData),
                ],
              ),
              onTap: () {
                ItemData itemData = ItemData(
                  header: parameterData['header'],
                  description: parameterData['description'],
                  imagePath: parameterData['imagePath'],
                  pdfPath: parameterData['pdfPath'],
                  fileType: _determineFileType(parameterData),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPage(itemData: itemData)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addParameter(context, subprocess);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _createApparatusParametersFolder(String subprocess) {
    Directory parametersDirectory =
        Directory('services/parameter_and_images/$subprocess');
    bool exists = parametersDirectory.existsSync();
    if (!exists) {
      parametersDirectory.createSync(recursive: true);
    }
  }

  Future<void> _addParameter(BuildContext context, String subprocess) async {
    List<TextEditingController> headerControllers = [TextEditingController()];
    List<TextEditingController> descriptionControllers = [
      TextEditingController()
    ];

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Parameter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < headerControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: headerControllers[i],
                              decoration: InputDecoration(labelText: 'Header'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: descriptionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Description',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.attach_file),
                                      onPressed: () {
                                        _pickPDF(context, i);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () {
                                        _pickImage(context, i);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          headerControllers.add(TextEditingController());
                          descriptionControllers.add(TextEditingController());
                        });
                      },
                      child: Text('Add More'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    for (int i = 0; i < headerControllers.length; i++) {
                      final newParameterData = {
                        'header': headerControllers[i].text,
                        'description': descriptionControllers[i].text,
                        'pdfPath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['pdfPath'] ?? ''
                            : '',
                        'imagePath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['imagePath'] ?? ''
                            : '',
                      };
                      _parameterDataList.add(newParameterData);
                      await _saveParameter(
                          context,
                          subprocess,
                          headerControllers[i].text,
                          _parameterDataList[i]['pdfPath']);
                    }
                    setState(() {});
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadSavedParameters() async {
    final parameterList = _prefs.getStringList('parameters');
    if (parameterList != null) {
      setState(() {
        _parameterDataList.clear();
        for (final parameterJson in parameterList) {
          if (parameterJson.isNotEmpty) {
            Map<String, dynamic>? parameterData;
            try {
              parameterData = jsonDecode(parameterJson);
            } catch (e) {
              print('Error decoding parameterJson: $e');
            }
            if (parameterData != null) {
              _parameterDataList.add({
                'header': parameterData['header'] ?? '',
                'description': parameterData['description'] ?? '',
                'imagePath': parameterData['imagePath'] ?? '',
                'pdfPath': parameterData['pdfPath'] ?? '',
              });
            }
          }
        }
      });
    }
  }

  FileType _determineFileType(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if (pdfPath != null && pdfPath.isNotEmpty) {
      return FileType.PDF;
    } else if (imagePath != null && imagePath.isNotEmpty) {
      return FileType.Image;
    } else {
      return FileType.None;
    }
  }

  Future<void> _saveParameter(BuildContext context, String subprocess,
      String parameterName, String filePath) async {
    String parameterPath =
        'services/parameter_and_images/$subprocess/$parameterName';
    parameterPathsMap.putIfAbsent(subprocess, () => []).add(parameterPath);

    // Display the loading dialog with a progress indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Parameter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // Progress indicator
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    try {
      // Copy the file to the parameter directory
      File file = File(filePath);
      await file.copy(parameterPath);

      // Close the loading dialog
      Navigator.pop(context);

      // Show a success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Parameter saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the success dialog
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      // Close the loading dialog
      Navigator.pop(context);

      // Show an error message if copying fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save parameter: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the error dialog
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  Future<void> _pickPDF(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['pdf'],
    );

    Navigator.pop(context); // Close the progress dialog

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['pdfPath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        } else {
          print('Error: Invalid parameter index.');
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _pickImage(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    Navigator.pop(context);

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['imagePath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _showFileNameConfirmationDialog(BuildContext context) async {
    bool? retainName = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Do you want to retain the current file name?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Retain'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (retainName != null && !retainName) {
      _showRenameFileDialog(context);
    }
  }

  Future<void> _showRenameFileDialog(BuildContext context) async {
    String? newFileName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String newName = '';
        return AlertDialog(
          title: Text('Rename File'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: 'Enter new file name'),
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
                Navigator.of(context).pop(newName);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newFileName != null && newFileName.isNotEmpty) {
      // Rename the file
    }
  }

  Widget _buildFileUploadedIndicator(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if ((pdfPath != null && pdfPath.isNotEmpty) ||
        (imagePath != null && imagePath.isNotEmpty)) {
      return Icon(Icons.attach_file, color: Colors.green);
    } else {
      return SizedBox.shrink();
    }
  }

  void _deleteAllParameters() {
    setState(() {
      _parameterDataList.clear();
      _prefs.remove('parameters');
    });
  }

  void _deleteParameter(int index) {
    setState(() {
      _parameterDataList.removeAt(index);
      _saveParametersToPrefs();
    });
  }

  void _saveParametersToPrefs() async {
    final parameterList = _parameterDataList.map((e) => jsonEncode(e)).toList();
    await _prefs.setStringList('parameters', parameterList);
  }
}
*/
/*
// Changes to what i assume works
// Changes to what i assume works
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:shared_preferences/shared_preferences.dart';

import 'parameterdetails.dart';

class ParameterPage extends StatefulWidget {
  @override
  _ParameterPageState createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late SharedPreferences _prefs;
  late Map<String, List<String>> parameterPathsMap = {};
  List<Map<String, dynamic>> _parameterDataList = [];

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedParameters();
  }

  @override
  Widget build(BuildContext context) {
    final String subprocess = ModalRoute.of(context)?.settings.arguments as String;
    _createApparatusParametersFolder(subprocess);
    return Scaffold(
      appBar: AppBar(
        title: Text('Parameters for: $subprocess'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAllParameters();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _parameterDataList.length,
        itemBuilder: (context, index) {
          final parameterData = _parameterDataList[index];
          return Card(
            child: ListTile(
              title: Text(parameterData['header']),
              subtitle: Text(parameterData['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteParameter(index);
                    },
                  ),
                  _buildFileUploadedIndicator(parameterData),
                ],
              ),
              onTap: () {
                ItemData itemData = ItemData(
                  header: parameterData['header'],
                  description: parameterData['description'],
                  imagePath: parameterData['imagePath'],
                  pdfPath: parameterData['pdfPath'],
                  fileType: _determineFileType(parameterData),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPage(itemData: itemData)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addParameter(context, subprocess);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _createApparatusParametersFolder(String subprocess) {
    Directory parametersDirectory =
        Directory('services/parameter_and_images/$subprocess');
    bool exists = parametersDirectory.existsSync();
    if (!exists) {
      parametersDirectory.createSync(recursive: true);
    }
  }

  Future<void> _addParameter(BuildContext context, String subprocess) async {
    List<TextEditingController> headerControllers = [TextEditingController()];
    List<TextEditingController> descriptionControllers = [TextEditingController()];

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Parameter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < headerControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: headerControllers[i],
                              decoration: InputDecoration(labelText: 'Header'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: descriptionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Description',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.attach_file),
                                      onPressed: () {
                                        _pickPDF(context, i);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () {
                                        _pickImage(context, i);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          headerControllers.add(TextEditingController());
                          descriptionControllers.add(TextEditingController());
                        });
                      },
                      child: Text('Add More'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    for (int i = 0; i < headerControllers.length; i++) {
                      final newParameterData = {
                        'header': headerControllers[i].text,
                        'description': descriptionControllers[i].text,
                        'pdfPath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['pdfPath'] ?? ''
                            : '',
                        'imagePath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['imagePath'] ?? ''
                            : '',
                      };
                      final fileType = _determineFileType(newParameterData);
                      newParameterData['fileType'] = fileType;
                      _parameterDataList.add(newParameterData);
                      await _saveParameter(
                          context,
                          subprocess,
                          headerControllers[i].text,
                          _parameterDataList[i]['pdfPath']);
                    }
                    setState(() {});
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

Future<void> _loadSavedParameters() async {
  final parameterList = _prefs.getStringList('parameters');
  if (parameterList != null) {
    for (final parameterJson in parameterList) {
      try {
        final dynamic decodedData = jsonDecode(parameterJson);
        if (decodedData is Map<String, dynamic>) {
          _parameterDataList.add({
            'header': decodedData['header'] ?? '',
            'description': decodedData['description'] ?? '',
            'imagePath': decodedData['imagePath'] ?? '',
            'pdfPath': decodedData['pdfPath'] ?? '',
          });
        }
      } catch (e) {
        print('Error decoding parameterJson: $e');
      }
    }
  }
}

  FileType _determineFileType(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if (pdfPath != null && pdfPath.isNotEmpty) {
      return FileType.PDF;
    } else if (imagePath != null && imagePath.isNotEmpty) {
      return FileType.Image;
    } else {
      return FileType.None;
    }
  }

  Future<void> _saveParameter(BuildContext context, String subprocess,
      String parameterName, String filePath) async {
    String parameterPath =
        'services/parameter_and_images/$subprocess/$parameterName';
    parameterPathsMap.putIfAbsent(subprocess, () => []).add(parameterPath);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Parameter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    try {
      File file = File(filePath);
      if (!file.existsSync()) {
        await file.copy(parameterPath);
      }

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Parameter saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save parameter: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  Future<void> _pickPDF(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['pdf'],
    );

    Navigator.pop(context); 

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['pdfPath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        } else {
          print('Error: Invalid parameter index.');
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _pickImage(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    Navigator.pop(context);

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['imagePath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _showFileNameConfirmationDialog(BuildContext context) async {
    bool? retainName = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Do you want to retain the current file name?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Retain'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (retainName != null && !retainName) {
      _showRenameFileDialog(context);
    }
  }

  Future<void> _showRenameFileDialog(BuildContext context) async {
    String? newFileName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String newName = '';
        return AlertDialog(
          title: Text('Rename File'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: 'Enter new file name'),
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
                Navigator.of(context).pop(newName);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newFileName != null && newFileName.isNotEmpty) {
      // Rename the file
    }
  }

  Widget _buildFileUploadedIndicator(Map<String, dynamic> parameterData) {
    final fileType = _determineFileType(parameterData);

    if (fileType == FileType.PDF) {
      return Icon(Icons.picture_as_pdf, color: Colors.red);
    } else if (fileType == FileType.Image) {
      return Icon(Icons.image, color: Colors.blue);
    } else {
      return SizedBox(); 
    }
  }

  void _deleteAllParameters() {
    setState(() {
      _parameterDataList.clear();
      _prefs.remove('parameters');
    });
  }

  void _deleteParameter(int index) {
    setState(() {
      _parameterDataList.removeAt(index);
      _saveParametersToPrefs();
    });
  }

  void _saveParametersToPrefs() async {
    final parameterList = _parameterDataList.map((e) => jsonEncode(e)).toList();
    await _prefs.setStringList('parameters', parameterList);
  }
}
*/
/*
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:shared_preferences/shared_preferences.dart';

import 'parameterdetails.dart';

//enum FileType { PDF, Image, None }

class ParameterPage extends StatefulWidget {
  @override
  _ParameterPageState createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _parameterDataList = [];
  late SharedPreferences _prefs;
  late Map<String, List<String>> parameterPathsMap = {};

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedParameters();
  }

  @override
  Widget build(BuildContext context) {
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;
    _createApparatusParametersFolder(subprocess);
    return Scaffold(
      appBar: AppBar(
        title: Text('Parameters for : $subprocess'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAllParameters();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _parameterDataList.length,
        itemBuilder: (context, index) {
          final parameterData = _parameterDataList[index];
          return Card(
            child: ListTile(
              title: Text(parameterData['header']),
              subtitle: Text(parameterData['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteParameter(index);
                    },
                  ),
                  _buildFileUploadedIndicator(parameterData),
                ],
              ),
              onTap: () {
                ItemData itemData = ItemData(
                  header: parameterData['header'],
                  description: parameterData['description'],
                  imagePath: parameterData['imagePath'],
                  pdfPath: parameterData['pdfPath'],
                  fileType: _determineFileType(parameterData),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPage(itemData: itemData)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addParameter(context, subprocess);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _createApparatusParametersFolder(String subprocess) {
    Directory parametersDirectory =
        Directory('services/parameter_and_images/$subprocess');
    bool exists = parametersDirectory.existsSync();
    if (!exists) {
      parametersDirectory.createSync(recursive: true);
    }
  }

  Future<void> _addParameter(BuildContext context, String subprocess) async {
    List<TextEditingController> headerControllers = [TextEditingController()];
    List<TextEditingController> descriptionControllers = [
      TextEditingController()
    ];

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Parameter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < headerControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: headerControllers[i],
                              decoration: InputDecoration(labelText: 'Header'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: descriptionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Description',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.attach_file),
                                      onPressed: () {
                                        _pickPDF(context, i);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () {
                                        _pickImage(context, i);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          headerControllers.add(TextEditingController());
                          descriptionControllers.add(TextEditingController());
                        });
                      },
                      child: Text('Add More'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    for (int i = 0; i < headerControllers.length; i++) {
                      final newParameterData = {
                        'header': headerControllers[i].text,
                        'description': descriptionControllers[i].text,
                        'pdfPath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['pdfPath'] ?? ''
                            : '',
                        'imagePath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['imagePath'] ?? ''
                            : '',
                      };
                      _parameterDataList.add(newParameterData);
                      await _saveParameter(
                          context,
                          subprocess,
                          headerControllers[i].text,
                          _parameterDataList[i]['pdfPath'] ?? '');
                    }
                    setState(() {});
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadSavedParameters() async {
    final parameterList = _prefs.getStringList('parameters');
    if (parameterList != null) {
      setState(() {
        _parameterDataList.clear();
        for (final parameterJson in parameterList) {
          if (parameterJson.isNotEmpty) {
            Map<String, dynamic>? parameterData;
            try {
              parameterData = jsonDecode(parameterJson);
            } catch (e) {
              print('Error decoding parameterJson: $e');
            }
            if (parameterData != null) {
              _parameterDataList.add({
                'header': parameterData['header'] ?? '',
                'description': parameterData['description'] ?? '',
                'imagePath': parameterData['imagePath'] ?? '',
                'pdfPath': parameterData['pdfPath'] ?? '',
              });
            }
          }
        }
      });
    }
  }

  FileType _determineFileType(Map<String, dynamic> parameterData) {
  final String pdfPath = parameterData['pdfPath'];
  final String imagePath = parameterData['imagePath'];

  if (pdfPath != null && pdfPath.isNotEmpty && pdfPath.toLowerCase().endsWith('.pdf')) {
    return FileType.PDF;
  } else if (imagePath != null && imagePath.isNotEmpty &&
      (imagePath.toLowerCase().endsWith('.jpg') ||
          imagePath.toLowerCase().endsWith('.jpeg') ||
          imagePath.toLowerCase().endsWith('.png') ||
          imagePath.toLowerCase().endsWith('.gif'))) {
    return FileType.Image;
  } else {
    return FileType.None;
  }
}

  Future<void> _saveParameter(BuildContext context, String subprocess,
      String parameterName, String filePath) async {
    String parameterPath =
        'services/parameter_and_images/$subprocess/$parameterName';
    parameterPathsMap.putIfAbsent(subprocess, () => []).add(parameterPath);

    // Display the loading dialog with a progress indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Parameter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // Progress indicator
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    try {
      // Copy the file to the parameter directory
      File file = File(filePath);
      await file.copy(parameterPath);

      // Close the loading dialog
      Navigator.pop(context);

      // Show a success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Parameter saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the success dialog
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      // Close the loading dialog
      Navigator.pop(context);

      // Show an error message if copying fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save parameter: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the error dialog
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  Future<void> _pickPDF(BuildContext context, int parameterIndex) async {
    file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['pdfPath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        } else {
          print('Error: Invalid parameter index.');
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _pickImage(BuildContext context, int parameterIndex) async {
    file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['imagePath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _showFileNameConfirmationDialog(BuildContext context) async {
    // Implement confirmation dialog if needed
  }

  Widget _buildFileUploadedIndicator(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if ((pdfPath != null && pdfPath.isNotEmpty) ||
        (imagePath != null && imagePath.isNotEmpty)) {
      return Icon(Icons.attach_file, color: Colors.green);
    } else {
      return SizedBox.shrink();
    }
  }

  void _deleteAllParameters() {
    setState(() {
      _parameterDataList.clear();
      _prefs.remove('parameters');
    });
  }

  void _deleteParameter(int index) {
    setState(() {
      _parameterDataList.removeAt(index);
      _saveParametersToPrefs();
    });
  }

  void _saveParametersToPrefs() async {
    final parameterList = _parameterDataList.map((e) => jsonEncode(e)).toList();
    await _prefs.setStringList('parameters', parameterList);
  }
}
*/

/*

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:shared_preferences/shared_preferences.dart';

import 'parameterdetails.dart';

class ParameterPage extends StatefulWidget {
  @override
  _ParameterPageState createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _parameterDataList = [];
  late SharedPreferences _prefs;
  late Map<String, List<String>> parameterPathsMap = {};

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedParameters();
  }

  @override
  Widget build(BuildContext context) {
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;
    _createApparatusParametersFolder(subprocess);
    return Scaffold(
      appBar: AppBar(
        title: Text('Parameters for : $subprocess'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAllParameters();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _parameterDataList.length,
        itemBuilder: (context, index) {
          final parameterData = _parameterDataList[index];
          return Card(
            child: ListTile(
              title: Text(parameterData['header']),
              subtitle: Text(parameterData['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteParameter(index);
                    },
                  ),
                  _buildFileUploadedIndicator(parameterData),
                ],
              ),
              onTap: () {
                ItemData itemData = ItemData(
                  header: parameterData['header'],
                  description: parameterData['description'],
                  imagePath: parameterData['imagePath'],
                  pdfPath: parameterData['pdfPath'],
                  fileType: _determineFileType(parameterData),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPage(itemData: itemData)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addParameter(context, subprocess);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _createApparatusParametersFolder(String subprocess) {
    Directory parametersDirectory =
        Directory('services/parameter_and_images/$subprocess');
    bool exists = parametersDirectory.existsSync();
    if (!exists) {
      parametersDirectory.createSync(recursive: true);
    }
  }

  Future<void> _addParameter(BuildContext context, String subprocess) async {
    List<TextEditingController> headerControllers = [TextEditingController()];
    List<TextEditingController> descriptionControllers = [
      TextEditingController()
    ];

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Parameter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < headerControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: headerControllers[i],
                              decoration: InputDecoration(labelText: 'Header'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: descriptionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Description',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.attach_file),
                                      onPressed: () {
                                        _pickPDF(context, i);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () {
                                        _pickImage(context, i);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          headerControllers.add(TextEditingController());
                          descriptionControllers.add(TextEditingController());
                        });
                      },
                      child: Text('Add More'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    for (int i = 0; i < headerControllers.length; i++) {
                      final newParameterData = {
                        'header': headerControllers[i].text,
                        'description': descriptionControllers[i].text,
                        'pdfPath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['pdfPath'] ?? ''
                            : '',
                        'imagePath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['imagePath'] ?? ''
                            : '',
                      };
                      _parameterDataList.add(newParameterData);
                      await _saveParameter(
                          context,
                          subprocess,
                          headerControllers[i].text,
                          _parameterDataList[i]['pdfPath']);
                    }
                    setState(() {});
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadSavedParameters() async {
    final parameterList = _prefs.getStringList('parameters');
    if (parameterList != null) {
      setState(() {
        _parameterDataList.clear();
        for (final parameterJson in parameterList) {
          if (parameterJson.isNotEmpty) {
            Map<String, dynamic>? parameterData;
            try {
              parameterData = jsonDecode(parameterJson);
            } catch (e) {
              print('Error decoding parameterJson: $e');
            }
            if (parameterData != null) {
              _parameterDataList.add({
                'header': parameterData['header'] ?? '',
                'description': parameterData['description'] ?? '',
                'imagePath': parameterData['imagePath'] ?? '',
                'pdfPath': parameterData['pdfPath'] ?? '',
              });
            }
          }
        }
      });
    }
  }

  FileType _determineFileType(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if (pdfPath != null && pdfPath.isNotEmpty) {
      return FileType.PDF;
    } else if (imagePath != null && imagePath.isNotEmpty) {
      // Check if the file extension indicates an image
      if (imagePath.toLowerCase().endsWith('.jpg') ||
          imagePath.toLowerCase().endsWith('.jpeg') ||
          imagePath.toLowerCase().endsWith('.png') ||
          imagePath.toLowerCase().endsWith('.gif')) {
        return FileType.Image;
      } else {
        // Default to PDF if the file extension is not recognized as an image
        return FileType.PDF;
      }
    } else {
      return FileType.None;
    }
  }

  Future<void> _saveParameter(BuildContext context, String subprocess,
      String parameterName, String filePath) async {
    String parameterPath =
        'services/parameter_and_images/$subprocess/$parameterName';
    parameterPathsMap.putIfAbsent(subprocess, () => []).add(parameterPath);

    // Display the loading dialog with a progress indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Parameter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // Progress indicator
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    try {
      // Copy the file to the parameter directory
      File file = File(filePath);
      await file.copy(parameterPath);

      // Close the loading dialog
      Navigator.pop(context);

      // Show a success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Parameter saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the success dialog
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      // Close the loading dialog
      Navigator.pop(context);

      // Show an error message if copying fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save parameter: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the error dialog
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  Future<void> _pickPDF(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['pdf'],
    );

    Navigator.pop(context); // Close the progress dialog

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['pdfPath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        } else {
          print('Error: Invalid parameter index.');
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

Future<void> _pickImage(BuildContext context, int parameterIndex) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Uploading Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Uploading...'),
          ],
        ),
      );
    },
  );

  final file_picker.FilePickerResult? result =
      await file_picker.FilePicker.platform.pickFiles(
    type: file_picker.FileType.image, // Only allow image files
    allowedExtensions: ['jpg', 'jpeg'], // Allow only jpg and jpeg extensions
  );

  Navigator.pop(context);

  if (result != null) {
    final filePath = result.files.single.path;
    if (filePath != null) {
      if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
        setState(() {
          _parameterDataList[parameterIndex]['imagePath'] = filePath;
        });
        await _showFileNameConfirmationDialog(context);
      }
    } else {
      print('Error: File path is null.');
    }
  } else {
    print('Error: File picker result is null.');
  }
}

  Future<void> _showFileNameConfirmationDialog(BuildContext context) async {
    bool? retainName = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Do you want to retain the current file name?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Retain'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (retainName != null && !retainName) {
      _showRenameFileDialog(context);
    }
  }

  Future<void> _showRenameFileDialog(BuildContext context) async {
    String? newFileName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String newName = '';
        return AlertDialog(
          title: Text('Rename File'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: 'Enter new file name'),
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
                Navigator.of(context).pop(newName);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newFileName != null && newFileName.isNotEmpty) {
      // Rename the file
    }
  }

  Widget _buildFileUploadedIndicator(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if ((pdfPath != null && pdfPath.isNotEmpty) ||
        (imagePath != null && imagePath.isNotEmpty)) {
      return Icon(Icons.attach_file, color: Colors.green);
    } else {
      return SizedBox.shrink();
    }
  }

  void _deleteAllParameters() {
    setState(() {
      _parameterDataList.clear();
      _prefs.remove('parameters');
    });
  }

  void _deleteParameter(int index) {
    setState(() {
      _parameterDataList.removeAt(index);
      _saveParametersToPrefs();
    });
  }

  void _saveParametersToPrefs() async {
    final parameterList = _parameterDataList.map((e) => jsonEncode(e)).toList();
    await _prefs.setStringList('parameters', parameterList);
  }
}
*/



/*

import 'dart:convert';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:shared_preferences/shared_preferences.dart';

import 'parameterdetails.dart';

class ParameterPage extends StatefulWidget {
  @override
  _ParameterPageState createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _parameterDataList = [];
  late SharedPreferences _prefs;
  late Map<String, List<String>> parameterPathsMap = {};

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedParameters();
  }

  @override
  Widget build(BuildContext context) {
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;
    _createApparatusParametersFolder(subprocess);
    return Scaffold(
      appBar: AppBar(
        title: Text('Parameters for : $subprocess'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAllParameters();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _parameterDataList.length,
        itemBuilder: (context, index) {
          final parameterData = _parameterDataList[index];
          return Card(
            child: ListTile(
              title: Text(parameterData['header']),
              subtitle: Text(parameterData['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteParameter(index);
                    },
                  ),
                  _buildFileUploadedIndicator(parameterData),
                ],
              ),
              onTap: () {
                ItemData itemData = ItemData(
                  header: parameterData['header'],
                  description: parameterData['description'],
                  imagePath: parameterData['imagePath'],
                  pdfPath: parameterData['pdfPath'],
                  fileType: _determineFileType(parameterData),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPage(itemData: itemData)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addParameter(context, subprocess);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _createApparatusParametersFolder(String subprocess) {
    Directory parametersDirectory =
        Directory('services/parameter_and_images/$subprocess');
    bool exists = parametersDirectory.existsSync();
    if (!exists) {
      parametersDirectory.createSync(recursive: true);
    }
  }

  Future<void> _addParameter(BuildContext context, String subprocess) async {
    List<TextEditingController> headerControllers = [TextEditingController()];
    List<TextEditingController> descriptionControllers = [
      TextEditingController()
    ];

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Parameter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < headerControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: headerControllers[i],
                              decoration: InputDecoration(labelText: 'Header'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: descriptionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Description',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.attach_file),
                                      onPressed: () {
                                        _pickPDF(context, i);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () {
                                        _pickImage(context, i);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          headerControllers.add(TextEditingController());
                          descriptionControllers.add(TextEditingController());
                        });
                      },
                      child: Text('Add More'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    for (int i = 0; i < headerControllers.length; i++) {
                      final newParameterData = {
                        'header': headerControllers[i].text,
                        'description': descriptionControllers[i].text,
                        'pdfPath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['pdfPath'] ?? ''
                            : '',
                        'imagePath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['imagePath'] ?? ''
                            : '',
                      };
                      _parameterDataList.add(newParameterData);
                      await _saveParameter(
                        context,
                        subprocess,
                        headerControllers[i].text,
                        _parameterDataList[i]['pdfPath'],
                      );
                    }
                    setState(() {});
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveParameter(BuildContext context, String subprocess,
      String parameterName, String filePath) async {
    String parameterPath =
        'services/parameter_and_images/$subprocess/$parameterName';
    parameterPathsMap.putIfAbsent(subprocess, () => []).add(parameterPath);

    // Save parameter path to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(subprocess, parameterPathsMap[subprocess]!);

    // Copy the file to the parameter directory
    try {
      File file = File(filePath);
      await file.copy(parameterPath);

      // Update the state to reflect the changes
      setState(() {});

      // Show a success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Parameter saved successfully!'),
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
    } catch (e) {
      // Show an error message if copying fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save parameter: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // Close the error dialog
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  Future<void> _loadSavedParameters() async {
    final parameterList = _prefs.getStringList('parameters') ?? [];
    for (final parameterJson in parameterList) {
      final parameterData = jsonDecode(parameterJson);
      _parameterDataList.add(parameterData);
    }
    setState(() {});
  }

  FileType _determineFileType(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if (pdfPath != null && pdfPath.isNotEmpty) {
      return FileType.PDF;
    } else if (imagePath != null && imagePath.isNotEmpty) {
      return FileType.Image;
    } else {
      return FileType.None;
    }
  }

  Widget _buildFileUploadedIndicator(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if ((pdfPath != null && pdfPath.isNotEmpty) ||
        (imagePath != null && imagePath.isNotEmpty)) {
      return Icon(Icons.attach_file, color: Colors.green);
    } else {
      return SizedBox.shrink();
    }
  }

  void _deleteAllParameters() {
    setState(() {
      _parameterDataList.clear();
      _prefs.remove('parameters');
    });
  }

  void _deleteParameter(int index) {
    setState(() {
      _parameterDataList.removeAt(index);
      _saveParametersToPrefs();
    });
  }

  void _saveParametersToPrefs() async {
    final parameterList = _parameterDataList.map((e) => jsonEncode(e)).toList();
    await _prefs.setStringList('parameters', parameterList);
  }

  Future<void> _pickPDF(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['pdf'],
    );

    Navigator.pop(context); // Close the progress dialog

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['pdfPath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        } else {
          print('Error: Invalid parameter index.');
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _pickImage(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    Navigator.pop(context);

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['imagePath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _showFileNameConfirmationDialog(BuildContext context) async {
    bool? retainName = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Do you want to retain the current file name?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Retain'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (retainName != null && !retainName) {
      _showRenameFileDialog(context);
    }
  }
Future<void> _showRenameFileDialog(BuildContext context) async {
  String? newFileName = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      String newName = '';
      return AlertDialog(
        title: Text('Rename File'),
        content: TextField(
          onChanged: (value) {
            newName = value;
          },
          decoration: InputDecoration(hintText: 'Enter new file name'),
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
              Navigator.of(context).pop(newName);
            },
            child: Text('Rename'),
          ),
        ],
      );
    },
  );

  if (newFileName != null && newFileName.isNotEmpty) {
    for (int i = 0; i < _parameterDataList.length; i++) {
      int parameterIndex = _parameterDataList.indexWhere((element) =>
          element['pdfPath'] == _parameterDataList[i]['pdfPath'] ||
          element['imagePath'] == _parameterDataList[i]['imagePath']);

      if (parameterIndex != -1) {
        String newPath;
        String oldPath = _parameterDataList[parameterIndex]['pdfPath'] ??
            _parameterDataList[parameterIndex]['imagePath'];

        if (_parameterDataList[parameterIndex]['pdfPath'] != null) {
          newPath = oldPath.replaceFirst(
              RegExp(
                  '${_parameterDataList[parameterIndex]['pdfPath'].split('/').last}'),
              newFileName);
          _parameterDataList[parameterIndex]['pdfPath'] = newPath;
        } else if (_parameterDataList[parameterIndex]['imagePath'] != null) {
          newPath = oldPath.replaceFirst(
              RegExp(
                  '${_parameterDataList[parameterIndex]['imagePath'].split('/').last}'),
              newFileName);
          _parameterDataList[parameterIndex]['imagePath'] = newPath;
        }

        setState(() {});
      }
    }
  }
}

  }
*/

/*

// copy of the code you are not to delete
import 'dart:convert';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:shared_preferences/shared_preferences.dart';

import 'parameterdetails.dart';

class ParameterPage extends StatefulWidget {
  @override
  _ParameterPageState createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, dynamic>> _parameterDataList = [];
  late SharedPreferences _prefs;
  late Map<String, List<String>> parameterPathsMap = {};

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedParameters();
  }

  @override
  Widget build(BuildContext context) {
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;
    _createApparatusParametersFolder(subprocess);
    return Scaffold(
      appBar: AppBar(
        title: Text('Parameters for : $subprocess'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAllParameters();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _parameterDataList.length,
        itemBuilder: (context, index) {
          final parameterData = _parameterDataList[index];
          return Card(
            child: ListTile(
              title: Text(parameterData['header']),
              subtitle: Text(parameterData['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteParameter(index);
                    },
                  ),
                  _buildFileUploadedIndicator(parameterData),
                ],
              ),
              onTap: () {
                ItemData itemData = ItemData(
                  header: parameterData['header'],
                  description: parameterData['description'],
                  imagePath: parameterData['imagePath'],
                  pdfPath: parameterData['pdfPath'],
                  fileType: _determineFileType(parameterData),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPage(itemData: itemData)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addParameter(context, subprocess);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _createApparatusParametersFolder(String subprocess) {
    Directory parametersDirectory =
        Directory('services/parameter_and_images/$subprocess');
    bool exists = parametersDirectory.existsSync();
    if (!exists) {
      parametersDirectory.createSync(recursive: true);
    }
  }

  Future<void> _addParameter(BuildContext context, String subprocess) async {
    List<TextEditingController> headerControllers = [TextEditingController()];
    List<TextEditingController> descriptionControllers = [
      TextEditingController()
    ];

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Parameter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < headerControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: headerControllers[i],
                              decoration: InputDecoration(labelText: 'Header'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: descriptionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Description',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.attach_file),
                                      onPressed: () {
                                        _pickPDF(context, i);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () {
                                        _pickImage(context, i);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          headerControllers.add(TextEditingController());
                          descriptionControllers.add(TextEditingController());
                        });
                      },
                      child: Text('Add More'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    for (int i = 0; i < headerControllers.length; i++) {
                      final newParameterData = {
                        'header': headerControllers[i].text,
                        'description': descriptionControllers[i].text,
                        'pdfPath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['pdfPath'] ?? ''
                            : '',
                        'imagePath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['imagePath'] ?? ''
                            : '',
                      };
                      _parameterDataList.add(newParameterData);
                      await _saveParameter(
                        context,
                        subprocess,
                        headerControllers[i].text,
                        _parameterDataList[i]['pdfPath'],
                      );
                    }
                    setState(() {});
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveParameter(BuildContext context, String subprocess,
      String parameterName, String filePath) async {
    String parameterPath =
        'services/parameter_and_images/$subprocess/$parameterName';
    parameterPathsMap.putIfAbsent(subprocess, () => []).add(parameterPath);

    // Save parameter path to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(subprocess, parameterPathsMap[subprocess]!);

    // Copy the file to the parameter directory
    try {
      File file = File(filePath);
      await file.copy(parameterPath);

      // Update the state to reflect the changes
      setState(() {});

      // Show a success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Parameter saved successfully!'),
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
    } catch (e) {
      // Show an error message if copying fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save parameter: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // Close the error dialog
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  Future<void> _loadSavedParameters() async {
    final parameterList = _prefs.getStringList('parameters') ?? [];
    for (final parameterJson in parameterList) {
      final parameterData = jsonDecode(parameterJson);
      _parameterDataList.add(parameterData);
    }
    setState(() {});
  }

  FileType _determineFileType(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if (pdfPath != null && pdfPath.isNotEmpty) {
      return FileType.PDF;
    } else if (imagePath != null && imagePath.isNotEmpty) {
      return FileType.Image;
    } else {
      return FileType.None;
    }
  }

  Widget _buildFileUploadedIndicator(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if ((pdfPath != null && pdfPath.isNotEmpty) ||
        (imagePath != null && imagePath.isNotEmpty)) {
      return Icon(Icons.attach_file, color: Colors.green);
    } else {
      return SizedBox.shrink();
    }
  }

  void _deleteAllParameters() {
    setState(() {
      _parameterDataList.clear();
      _prefs.remove('parameters');
    });
  }

  void _deleteParameter(int index) {
    setState(() {
      _parameterDataList.removeAt(index);
      _saveParametersToPrefs();
    });
  }

  void _saveParametersToPrefs() async {
    final parameterList = _parameterDataList.map((e) => jsonEncode(e)).toList();
    await _prefs.setStringList('parameters', parameterList);
  }

  Future<void> _pickPDF(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['pdf'],
    );

    Navigator.pop(context); // Close the progress dialog

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['pdfPath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        } else {
          print('Error: Invalid parameter index.');
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _pickImage(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    Navigator.pop(context);

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['imagePath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _showFileNameConfirmationDialog(BuildContext context) async {
    bool? retainName = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Do you want to retain the current file name?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Retain'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (retainName != null && !retainName) {
      _showRenameFileDialog(context);
    }
  }
Future<void> _showRenameFileDialog(BuildContext context) async {
  String? newFileName = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      String newName = '';
      return AlertDialog(
        title: Text('Rename File'),
        content: TextField(
          onChanged: (value) {
            newName = value;
          },
          decoration: InputDecoration(hintText: 'Enter new file name'),
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
              Navigator.of(context).pop(newName);
            },
            child: Text('Rename'),
          ),
        ],
      );
    },
  );

  if (newFileName != null && newFileName.isNotEmpty) {
    for (int i = 0; i < _parameterDataList.length; i++) {
      int parameterIndex = _parameterDataList.indexWhere((element) =>
          element['pdfPath'] == _parameterDataList[i]['pdfPath'] ||
          element['imagePath'] == _parameterDataList[i]['imagePath']);

      if (parameterIndex != -1) {
        String newPath;
        String oldPath = _parameterDataList[parameterIndex]['pdfPath'] ??
            _parameterDataList[parameterIndex]['imagePath'];

        if (_parameterDataList[parameterIndex]['pdfPath'] != null) {
          newPath = oldPath.replaceFirst(
              RegExp(
                  '${_parameterDataList[parameterIndex]['pdfPath'].split('/').last}'),
              newFileName);
          _parameterDataList[parameterIndex]['pdfPath'] = newPath;
        } else if (_parameterDataList[parameterIndex]['imagePath'] != null) {
          newPath = oldPath.replaceFirst(
              RegExp(
                  '${_parameterDataList[parameterIndex]['imagePath'].split('/').last}'),
              newFileName);
          _parameterDataList[parameterIndex]['imagePath'] = newPath;
        }

        setState(() {});
      }
    }
  }
}

  }


*/
/*
//this has issues
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:shared_preferences/shared_preferences.dart';

import 'parameterdetails.dart';

class ParameterPage extends StatefulWidget {
  @override
  _ParameterPageState createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late List<Map<String, dynamic>> _parameterDataList = [];
  late SharedPreferences _prefs;
  late Map<String, List<String>> parameterPathsMap;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

Future<void> _initSharedPreferences() async {
  _prefs = await SharedPreferences.getInstance();
  final List<Map<String, dynamic>> loadedParameters = await _loadSavedParameters();
  _parameterDataList = loadedParameters;
  parameterPathsMap = {}; // Initialize parameterPathsMap here
}


  @override
Widget build(BuildContext context) {
  final String subprocess =
      ModalRoute.of(context)?.settings.arguments as String;
  _createApparatusParametersFolder(subprocess);
  return FutureBuilder(
    future: _loadSavedParameters(), // Load parameters asynchronously
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator(); // Show loading indicator while parameters are loading
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}'); // Show error if loading fails
      } else {
        // Parameters loaded successfully, build your UI using the loaded parameters
        return Scaffold(
          appBar: AppBar(
            title: Text('Parameters for : $subprocess'),
            actions: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteAllParameters();
                },
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: _parameterDataList.length,
            itemBuilder: (context, index) {
              final parameterData = _parameterDataList[index];
              return Card(
                child: ListTile(
                  title: Text(parameterData['header']),
                  subtitle: Text(parameterData['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteParameter(index);
                        },
                      ),
                      _buildFileUploadedIndicator(parameterData),
                    ],
                  ),
                  onTap: () {
                    ItemData itemData = ItemData(
                      header: parameterData['header'],
                      description: parameterData['description'],
                      imagePath: parameterData['imagePath'],
                      pdfPath: parameterData['pdfPath'],
                      fileType: _determineFileType(parameterData),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailsPage(itemData: itemData)),
                    );
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _addParameter(context, subprocess);
            },
            child: Icon(Icons.add),
          ),
        );
      }
    },
  );
}


  void _createApparatusParametersFolder(String subprocess) {
    Directory parametersDirectory =
        Directory('services/parameter_and_images/$subprocess');
    bool exists = parametersDirectory.existsSync();
    if (!exists) {
      parametersDirectory.createSync(recursive: true);
    }
  }

  Future<void> _addParameter(BuildContext context, String subprocess) async {
    List<TextEditingController> headerControllers = [TextEditingController()];
    List<TextEditingController> descriptionControllers = [
      TextEditingController()
    ];

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Parameter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < headerControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: headerControllers[i],
                              decoration: InputDecoration(labelText: 'Header'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: descriptionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Description',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.attach_file),
                                      onPressed: () {
                                        _pickPDF(context, i);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () {
                                        _pickImage(context, i);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          headerControllers.add(TextEditingController());
                          descriptionControllers.add(TextEditingController());
                        });
                      },
                      child: Text('Add More'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    for (int i = 0; i < headerControllers.length; i++) {
                      final newParameterData = {
                        'header': headerControllers[i].text,
                        'description': descriptionControllers[i].text,
                        'pdfPath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['pdfPath'] ?? ''
                            : '',
                        'imagePath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['imagePath'] ?? ''
                            : '',
                      };
                      _parameterDataList.add(newParameterData);
                      await _saveParameter(
                        context,
                        subprocess,
                        headerControllers[i].text,
                        _parameterDataList[i]['pdfPath'],
                      );
                    }
                    setState(() {});
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveParameter(BuildContext context, String subprocess,
      String parameterName, String filePath) async {
    String parameterPath =
        'services/parameter_and_images/$subprocess/$parameterName';
    parameterPathsMap.putIfAbsent(subprocess, () => []).add(parameterPath);

    // Save parameter path to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(subprocess, parameterPathsMap[subprocess]!);

    // Copy the file to the parameter directory
    try {
      File file = File(filePath);
      await file.copy(parameterPath);

      // Show a success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Parameter saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      // Show an error message if copying fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save parameter: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }
Future<List<Map<String, dynamic>>> _loadSavedParameters() async {
  final List<Map<String, dynamic>> loadedParameters = [];
  for (final key in _prefs.getKeys()) {
    final parameterPaths = _prefs.getStringList(key);
    if (parameterPaths != null) {
      for (final parameterPath in parameterPaths) {
        // Load parameter data asynchronously and add it to loadedParameters list
        // Example: final parameterData = await loadParameterData(parameterPath);
        // loadedParameters.add(parameterData);
      }
    }
  }
  return loadedParameters;
}

  FileType _determineFileType(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if (pdfPath != null && pdfPath.isNotEmpty) {
      return FileType.PDF;
    } else if (imagePath != null && imagePath.isNotEmpty) {
      return FileType.Image;
    } else {
      return FileType.None;
    }
  }

  Widget _buildFileUploadedIndicator(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if ((pdfPath != null && pdfPath.isNotEmpty) ||
        (imagePath != null && imagePath.isNotEmpty)) {
      return Icon(Icons.attach_file, color: Colors.green);
    } else {
      return SizedBox.shrink();
    }
  }

  void _deleteAllParameters() {
    setState(() {
      _parameterDataList.clear();
      _prefs.remove('parameters');
    });
  }

  void _deleteParameter(int index) {
    setState(() {
      _parameterDataList.removeAt(index);
      _saveParametersToPrefs();
    });
  }

  void _saveParametersToPrefs() async {
    final parameterList = _parameterDataList.map((e) => jsonEncode(e)).toList();
    await _prefs.setStringList('parameters', parameterList);
  }

  Future<void> _pickPDF(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['pdf'],
    );

    Navigator.pop(context); // Close the progress dialog

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['pdfPath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        } else {
          print('Error: Invalid parameter index.');
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _pickImage(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    Navigator.pop(context);

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['imagePath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _showFileNameConfirmationDialog(BuildContext context) async {
    bool? retainName = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Do you want to retain the current file name?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Retain'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (retainName != null && !retainName) {
      _showRenameFileDialog(context);
    }
  }

  Future<void> _showRenameFileDialog(BuildContext context) async {
    String? newFileName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String newName = '';
        return AlertDialog(
          title: Text('Rename File'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: 'Enter new file name'),
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
                Navigator.of(context).pop(newName);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newFileName != null && newFileName.isNotEmpty) {
      // Rename the file
    }
  }
}
*/
/*
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:shared_preferences/shared_preferences.dart';

import 'parameterdetails.dart';

class ParameterPage extends StatefulWidget {
  @override
  _ParameterPageState createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _parameterDataList = [];
  late SharedPreferences _prefs;
  late Map<String, List<String>> parameterPathsMap = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;
    _createApparatusParametersFolder(subprocess);
    return FutureBuilder(
      future: _loadSavedParameters(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          _parameterDataList = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Parameters for : $subprocess'),
              actions: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteAllParameters,
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: _parameterDataList.length,
              itemBuilder: (context, index) {
                final parameterData = _parameterDataList[index];
                return Card(
                  child: ListTile(
                    title: Text(parameterData['header']),
                    subtitle: Text(parameterData['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteParameter(index);
                          },
                        ),
                        _buildFileUploadedIndicator(parameterData),
                      ],
                    ),
                    onTap: () {
                      ItemData itemData = ItemData(
                        header: parameterData['header'],
                        description: parameterData['description'],
                        imagePath: parameterData['imagePath'],
                        pdfPath: parameterData['pdfPath'],
                        fileType: _determineFileType(parameterData),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailsPage(itemData: itemData)),
                      );
                    },
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _addParameter(context, subprocess);
              },
              child: Icon(Icons.add),
            ),
          );
        }
      },
    );
  }

  void _createApparatusParametersFolder(String subprocess) {
    Directory parametersDirectory =
        Directory('services/parameter_and_images/$subprocess');
    bool exists = parametersDirectory.existsSync();
    if (!exists) {
      parametersDirectory.createSync(recursive: true);
    }
  }

  Future<void> _addParameter(BuildContext context, String subprocess) async {
    List<TextEditingController> headerControllers = [TextEditingController()];
    List<TextEditingController> descriptionControllers = [
      TextEditingController()
    ];

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Parameter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < headerControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: headerControllers[i],
                              decoration: InputDecoration(labelText: 'Header'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: descriptionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Description',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.attach_file),
                                      onPressed: () {
                                        _pickPDF(context, i);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () {
                                        _pickImage(context, i);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          headerControllers.add(TextEditingController());
                          descriptionControllers.add(TextEditingController());
                        });
                      },
                      child: Text('Add More'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    for (int i = 0; i < headerControllers.length; i++) {
                      final newParameterData = {
                        'header': headerControllers[i].text,
                        'description': descriptionControllers[i].text,
                        'pdfPath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['pdfPath'] ?? ''
                            : '',
                        'imagePath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['imagePath'] ?? ''
                            : '',
                      };
                      _parameterDataList.add(newParameterData);
                      await _saveParameter(
                        context,
                        subprocess,
                        headerControllers[i].text,
                        _parameterDataList[i]['pdfPath'],
                      );
                    }
                    setState(() {});
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveParameter(BuildContext context, String subprocess,
      String parameterName, String filePath) async {
    String parameterPath =
        'services/parameter_and_images/$subprocess/$parameterName';
    parameterPathsMap.putIfAbsent(subprocess, () => []).add(parameterPath);

    // Save parameter path to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(subprocess, parameterPathsMap[subprocess]!);

    // Copy the file to the parameter directory
    try {
      File file = File(filePath);
      await file.copy(parameterPath);

      // Show a success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Parameter saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      // Show an error message if copying fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save parameter: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _loadSavedParameters() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> loadedParameters = [];
    for (final key in prefs.getKeys()) {
      final parameterPaths = prefs.getStringList(key);
      if (parameterPaths != null) {
        for (final parameterPath in parameterPaths) {
          // Load parameter data asynchronously and add it to loadedParameters list
          // Example: final parameterData = await loadParameterData(parameterPath);
          // loadedParameters.add(parameterData);
        }
      }
    }
    return loadedParameters;
  }

  FileType _determineFileType(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if (pdfPath != null && pdfPath.isNotEmpty) {
      return FileType.PDF;
    } else if (imagePath != null && imagePath.isNotEmpty) {
      return FileType.Image;
    } else {
      return FileType.None;
    }
  }

  Widget _buildFileUploadedIndicator(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if ((pdfPath != null && pdfPath.isNotEmpty) ||
        (imagePath != null && imagePath.isNotEmpty)) {
      return Icon(Icons.attach_file, color: Colors.green);
    } else {
      return SizedBox.shrink();
    }
  }

  void _deleteAllParameters() {
    setState(() {
      _parameterDataList.clear();
      _prefs.remove('parameters');
    });
  }

  void _deleteParameter(int index) {
    setState(() {
      _parameterDataList.removeAt(index);
      _saveParametersToPrefs();
    });
  }

  void _saveParametersToPrefs() async {
    final parameterList = _parameterDataList.map((e) => jsonEncode(e)).toList();
    await _prefs.setStringList('parameters', parameterList);
  }

 
  Future<void> _pickPDF(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['pdf'],
    );

    Navigator.pop(context); // Close the progress dialog

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['pdfPath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        } else {
          print('Error: Invalid parameter index.');
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _pickImage(BuildContext context, int parameterIndex) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    Navigator.pop(context);

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['imagePath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _showFileNameConfirmationDialog(BuildContext context) async {
    bool? retainName = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Do you want to retain the current file name?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Retain'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (retainName != null && !retainName) {
      _showRenameFileDialog(context);
    }
  }

  Future<void> _showRenameFileDialog(BuildContext context) async {
    String? newFileName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String newName = '';
        return AlertDialog(
          title: Text('Rename File'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: 'Enter new file name'),
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
                Navigator.of(context).pop(newName);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newFileName != null && newFileName.isNotEmpty) {
      // Rename the file
    }
  }
}*/







/*
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:shared_preferences/shared_preferences.dart';

import 'parameterdetails.dart';

class ParameterPage extends StatefulWidget {
  @override
  _ParameterPageState createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late SharedPreferences _prefs;
  late Map<String, List<String>> parameterPathsMap = {};
  List<Map<String, dynamic>> _parameterDataList = [];

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedParameters();
  }

  @override
  Widget build(BuildContext context) {
    final String subprocess =
        ModalRoute.of(context)?.settings.arguments as String;
    _createApparatusParametersFolder(subprocess);
    return Scaffold(
      appBar: AppBar(
        title: Text('Parameters for : $subprocess'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAllParameters();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _parameterDataList.length,
        itemBuilder: (context, index) {
          final parameterData = _parameterDataList[index];
          return Card(
            child: ListTile(
              title: Text(parameterData['header']),
              subtitle: Text(parameterData['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteParameter(index);
                    },
                  ),
                  _buildFileUploadedIndicator(parameterData),
                ],
              ),
              onTap: () {
                ItemData itemData = ItemData(
                  header: parameterData['header'],
                  description: parameterData['description'],
                  imagePath: parameterData['imagePath'],
                  pdfPath: parameterData['pdfPath'],
                  fileType: _determineFileType(parameterData),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailsPage(itemData: itemData)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addParameter(context, subprocess);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _createApparatusParametersFolder(String subprocess) {
    Directory parametersDirectory =
        Directory('services/parameter_and_images/$subprocess');
    bool exists = parametersDirectory.existsSync();
    if (!exists) {
      parametersDirectory.createSync(recursive: true);
    }
  }

  Future<void> _addParameter(BuildContext context, String subprocess) async {
    List<TextEditingController> headerControllers = [TextEditingController()];
    List<TextEditingController> descriptionControllers = [
      TextEditingController()
    ];

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Parameter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < headerControllers.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: headerControllers[i],
                              decoration:
                                  InputDecoration(labelText: 'Header'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: descriptionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Description',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.attach_file),
                                      onPressed: () {
                                        _pickPDF(context, i);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.camera_alt),
                                      onPressed: () {
                                        _pickImage(context, i);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          headerControllers
                              .add(TextEditingController());
                          descriptionControllers
                              .add(TextEditingController());
                        });
                      },
                      child: Text('Add More'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    for (int i = 0; i < headerControllers.length; i++) {
                      final newParameterData = {
                        'header': headerControllers[i].text,
                        'description': descriptionControllers[i].text,
                        'pdfPath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['pdfPath'] ?? ''
                            : '',
                        'imagePath': _parameterDataList.isNotEmpty &&
                                i < _parameterDataList.length
                            ? _parameterDataList[i]['imagePath'] ?? ''
                            : '',
                      };
                      _parameterDataList.add(newParameterData);
                      await _saveParameter(
                          context,
                          subprocess,
                          headerControllers[i].text,
                          _parameterDataList[i]['pdfPath'] ?? '');
                    }
                    setState(() {});
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadSavedParameters() async {
    final parameterList = _prefs.getStringList('parameters');
    if (parameterList != null) {
      setState(() {
        _parameterDataList.clear();
        for (final parameterJson in parameterList) {
          if (parameterJson.isNotEmpty) {
            Map<String, dynamic>? parameterData;
            try {
              parameterData = jsonDecode(parameterJson);
            } catch (e) {
              print('Error decoding parameterJson: $e');
            }
            if (parameterData != null) {
              _parameterDataList.add({
                'header': parameterData['header'] ?? '',
                'description': parameterData['description'] ?? '',
                'imagePath': parameterData['imagePath'] ?? '',
                'pdfPath': parameterData['pdfPath'] ?? '',
              });
            }
          }
        }
      });
    }
  }

  FileType _determineFileType(Map<String, dynamic> parameterData) {
    final String pdfPath = parameterData['pdfPath'];
    final String imagePath = parameterData['imagePath'];

    if (pdfPath != null && pdfPath.isNotEmpty) {
      return FileType.PDF;
    } else if (imagePath != null && imagePath.isNotEmpty) {
      return FileType.Image;
    } else {
      return FileType.None;
    }
  }

  Future<void> _saveParameter(BuildContext context, String subprocess,
      String parameterName, String filePath) async {
    String parameterPath =
        'services/parameter_and_images/$subprocess/$parameterName';
    parameterPathsMap.putIfAbsent(subprocess, () => []).add(parameterPath);

    // Display the loading dialog with a progress indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Uploading Parameter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // Progress indicator
              SizedBox(height: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    try {
      if (filePath.isNotEmpty) {
        // Copy the file to the parameter directory
        File file = File(filePath);
        await file.copy(parameterPath);
      }

      // Close the loading dialog
      Navigator.pop(context);

      // Show a success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Parameter saved successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the success dialog
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      // Close the loading dialog
      Navigator.pop(context);

      // Show an error message if copying fails
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save parameter: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the error dialog
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  Future<void> _pickPDF(BuildContext context, int parameterIndex) async {
    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['pdfPath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        } else {
          print('Error: Invalid parameter index.');
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _pickImage(BuildContext context, int parameterIndex) async {
    final file_picker.FilePickerResult? result =
        await file_picker.FilePicker.platform.pickFiles(
      type: file_picker.FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        if (parameterIndex >= 0 && parameterIndex < _parameterDataList.length) {
          setState(() {
            _parameterDataList[parameterIndex]['imagePath'] = filePath;
          });
          await _showFileNameConfirmationDialog(context);
        }
      } else {
        print('Error: File path is null.');
      }
    } else {
      print('Error: File picker result is null.');
    }
  }

  Future<void> _showFileNameConfirmationDialog(BuildContext context) async {
    bool? retainName = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Do you want to retain the current file name?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Retain'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (retainName != null && !retainName) {
      _showRenameFileDialog(context);
    }
  }

  Future<void> _showRenameFileDialog(BuildContext context) async {
    String? newFileName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String newName = '';
        return AlertDialog(
          title: Text('Rename File'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: 'Enter new file name'),
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
                Navigator.of(context).pop(newName);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newFileName != null && newFileName.isNotEmpty) {
      // Rename the file
    }
  }

  Widget _buildFileUploadedIndicator(Map<String, dynamic> parameterData) {
    if (parameterData['pdfPath'] != null && parameterData['pdfPath'].isNotEmpty ||
        parameterData['imagePath'] != null && parameterData['imagePath'].isNotEmpty) {
      return Icon(Icons.check_circle, color: Colors.green);
    } else {
      return SizedBox();
    }
  }

  void _deleteParameter(int index) {
    setState(() {
      _parameterDataList.removeAt(index);
    });
    // Perform delete operation
  }

  void _deleteAllParameters() {
    setState(() {
      _parameterDataList.clear();
    });
    // Perform delete all operation
  }
}
*/

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:shared_preferences/shared_preferences.dart';

class ParameterPage extends StatefulWidget {
  @override
  _ParameterPageState createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late SharedPreferences _prefs;
  late List<Map<String, dynamic>> _parameterDataList=[];

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedParameters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parameters'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAllParameters();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _parameterDataList.length,
        itemBuilder: (context, index) {
          final parameterData = _parameterDataList[index];
          return Card(
            child: ListTile(
              title: Text(parameterData['header']),
              subtitle: Text(parameterData['description']),
              trailing: _buildFileUploadedIndicator(parameterData),
              onTap: () {
                // Handle tapping on parameter
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addParameter(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

Future<void> _loadSavedParameters() async {
  final jsonStringList = _prefs.getStringList('parameters');
  if (jsonStringList != null) {
    _parameterDataList = jsonStringList
        .map((jsonString) {
          try {
            return jsonDecode(jsonString);
          } catch (e) {
            print('Error decoding parameter JSON: $e');
            return null;
          }
        })
        .whereType<Map<String, dynamic>>() // Filter out null values
        .toList();
  }
}

  Widget _buildFileUploadedIndicator(Map<String, dynamic> parameterData) {
    if (parameterData['pdfPath'] != null && parameterData['pdfPath'].isNotEmpty) {
      return Icon(Icons.picture_as_pdf, color: Colors.red);
    } else if (parameterData['imagePath'] != null && parameterData['imagePath'].isNotEmpty) {
      return Icon(Icons.image, color: Colors.blue);
    } else {
      return SizedBox(); // No file uploaded
    }
  }

  Future<void> _addParameter(BuildContext context) async {
    // Your implementation for adding a parameter
  }

  void _deleteAllParameters() async {
    await _prefs.remove('parameters');
    setState(() {
      _parameterDataList.clear();
    });
  }

  void _deleteParameter(int index) {
    setState(() {
      _parameterDataList.removeAt(index);
    });
  }

  void _saveParametersToPrefs() async {
    final jsonStringList = _parameterDataList.map((parameterData) => jsonEncode(parameterData)).toList();
    await _prefs.setStringList('parameters', jsonStringList);
  }
}
