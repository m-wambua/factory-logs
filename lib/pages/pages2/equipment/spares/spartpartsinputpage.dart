import 'package:collector/pages/pages2/emaiandstorage/emailsender.dart';
import 'package:collector/pages/pages2/equipment/parameters/parametersmodel.dart';
import 'package:collector/pages/pages2/equipment/spares/spartpartsmodel.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'package:win32/win32.dart';

class EquipmentSparePartsPage extends StatefulWidget {
  final String processName;
  final String subprocessName;
  final String equipmentName;

  const EquipmentSparePartsPage(
      {super.key,
      required this.processName,
      required this.subprocessName,
      required this.equipmentName});

  @override
  _EquipmentSparePartsPageState createState() =>
      _EquipmentSparePartsPageState();
}

class _EquipmentSparePartsPageState extends State<EquipmentSparePartsPage> {
  List<SparePart> spareParts = [];
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _partNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minStockController = TextEditingController();
  final _maxStockController = TextEditingController();
  final _leadTimeController = TextEditingController();
  final _supplierInfoController = TextEditingController();
  final _criticalityController = TextEditingController();
  final _conditionController = TextEditingController();
  final _warrantyController = TextEditingController();
  final _usageRateController = TextEditingController();
  List<TextEditingController> mailingListController = [TextEditingController()];
  List<File> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSpareParts();
  }

  void _showSubmitList(BuildContext context, SparePart sparePart) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Submit to: '),
            content: _submissionList(),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
                        _sendEmail(sparePart);
                      },
                      child: const Text('Send Email')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'))
                ],
              )
            ],
          );
        });
  }

  Widget _submissionList() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateDialog) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < mailingListController.length; i++)
              TextFormField(
                controller: mailingListController[i],
                decoration:
                    const InputDecoration(labelText: 'enter email address:'),
                onChanged: (value) {},
              ),
            const SizedBox(
              height: 10,
            ),
            IconButton(
                onPressed: () {
                  setStateDialog(() {
                    mailingListController.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add)),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    });
  }

  Future<void> _loadSpareParts() async {
    try {
      final loadedParts =
          await SparePart.loadSparePartsList(widget.equipmentName);
      setState(() {
        spareParts = loadedParts;
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar with the error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading spare parts: $e')),
      );
    }
  }

  Future<void> _deleteSparePart(int index) async {
    setState(() {
      SparePart.deleteSparePartsEntry(widget.equipmentName);
    });
    await _saveSpareParts();
  }

  Future<void> _showDeletConfirmation(int index) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(' Are you sure you want to delete this spare part?'),
                  Text('This Action is permanent and cannot be reverted')
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  _deleteSparePart(index);
                },
              ),
            ],
          );
        });
  }

  Future<void> _saveSpareParts() async {
    try {
      await SparePart.saveSparePartsList(spareParts, widget.equipmentName);
    } catch (e) {
      // Handle error (e.g., show a snackbar with the error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving spare parts: $e')),
      );
    }
  }

  void _addSparePart() {
    if (_formKey.currentState!.validate()) {
      final newSparePart = SparePart(
        equipmentName: widget.equipmentName,
        name: _nameController.text,
        partNumber: _partNumberController.text,
        description: _descriptionController.text,
        minimumStock: int.tryParse(_minStockController.text) ?? 0,
        maximumStock: int.tryParse(_maxStockController.text) ?? 0,
        leadTime: _leadTimeController.text,
        supplierInfo: _supplierInfoController.text,
        criticality: _criticalityController.text,
        condition: _conditionController.text,
        warranty: _warrantyController.text,
        usageRate: _usageRateController.text,
      );
      setState(() {
        spareParts.add(newSparePart);
      });
      _saveSpareParts();
      _generateAndUploadPDF(newSparePart);
      _clearForm();
      Navigator.of(context).pop();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _partNumberController.clear();
    _descriptionController.clear();
    _minStockController.clear();
    _maxStockController.clear();
    _leadTimeController.clear();
    _supplierInfoController.clear();
    _criticalityController.clear();
    _conditionController.clear();
    _warrantyController.clear();
    _usageRateController.clear();
  }

  Future<void> _generatePDF(SparePart sparePart) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('${widget.equipmentName} Spare Part Details for process',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Name: ${sparePart.name}'),
            pw.Text('Part Number: ${sparePart.partNumber}'),
            pw.Text('Description: ${sparePart.description}'),
            pw.Text(
                'Stock Levels: ${sparePart.minimumStock} - ${sparePart.maximumStock}'),
            pw.Text('Condition: ${sparePart.condition}'),
            pw.Text('Lead Time: ${sparePart.leadTime}'),
            pw.Text('Supplier Info: ${sparePart.supplierInfo}'),
            pw.Text('Criticality: ${sparePart.criticality}'),
            pw.Text('Warranty: ${sparePart.warranty}'),
            pw.Text('Usage Rate: ${sparePart.usageRate}'),
          ],
        ),
      ),
    );
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: '${sparePart.name}_details.pdf');
  }

  Future<File> _generateAndSavePDF(SparePart sparePart) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                      '${widget.equipmentName} Spare Part Details for process',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('Name: ${sparePart.name}'),
                  pw.Text('Part Number: ${sparePart.partNumber}'),
                  pw.Text('Description: ${sparePart.description}'),
                  pw.Text(
                      'Stock Levels: ${sparePart.minimumStock}- ${sparePart.maximumStock}'),
                  pw.Text('Condition: ${sparePart.condition}'),
                  pw.Text('Lead Time: ${sparePart.leadTime}'),
                  pw.Text('Supplier Info: ${sparePart.supplierInfo}'),
                  pw.Text('Criticality: ${sparePart.criticality}'),
                  pw.Text('Warranty: ${sparePart.warranty}'),
                  pw.Text('Usage Rate: ${sparePart.usageRate}'),
                ])));

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/${sparePart.name}_details.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _sendEmail(SparePart sparePart) async {
    Map<String, dynamic> pdfData = {
      'name': sparePart.name,
      'Part Number': sparePart.partNumber,
      'Description': sparePart.description,
      'Minimum Stock': sparePart.minimumStock,
      'Maximum Stock': sparePart.maximumStock,
      'Condition': sparePart.condition,
      'Lead Time': sparePart.leadTime,
      'Supplier Info': sparePart.supplierInfo,
      'Warranty': sparePart.warranty,
      'Usage Rate': sparePart.usageRate,
    };
    try {
      await EmailSender.sendEmail(
          mailingListController, pdfData, EmailType.sparePartsDetails);
      //show success dialog
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                content: const Text('Email sent Succesfully!'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'))
                ],
              ));
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                content: Text('Error sending email: $e'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'))
                ],
              ));
    }
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
                '${widget.equipmentName} Spares Parts for process ${widget.processName} and for subprocess ${widget.subprocessName}'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _createNewSpares(widget.equipmentName);
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Spare Part',
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: spareParts.isEmpty
                ? const Center(
                    child:
                        Text('No spare parts added yet. Add your first one!'),
                  )
                : ListView.builder(
                    itemCount: spareParts.length,
                    itemBuilder: (context, index) {
                      final sparePart = spareParts[index];
                      return GestureDetector(
                        onLongPress: () => _showDeletConfirmation(index),
                        child: Card(
                          child: ExpansionTile(
                            title: Text(sparePart.name),
                            subtitle:
                                Text('Part Number: ${sparePart.partNumber}'),
                            children: [
                              ListTile(
                                  title: Text(
                                      'Description: ${sparePart.description}')),
                              ListTile(
                                  title: Text(
                                      'Stock: ${sparePart.minimumStock} - ${sparePart.maximumStock}')),
                              ListTile(
                                  title: Text(
                                      'Condition: ${sparePart.condition}')),
                              ListTile(
                                title: Text('Lead Time: ${sparePart.leadTime}'),
                              ),
                              ListTile(
                                title: Text(
                                    'Supplier Info: ${sparePart.supplierInfo}'),
                              ),
                              ListTile(
                                title: Text(
                                    'Criticality: ${sparePart.criticality}'),
                              ),
                              ListTile(
                                title: Text('Warranty: ${sparePart.warranty}'),
                              ),
                              ListTile(
                                title:
                                    Text('Usage Rate: ${sparePart.usageRate}'),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _generatePDF(sparePart),
                                    child: const Text('Print'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _showSubmitList(context, sparePart),
                                    child: const Text('Email'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewSpares(widget.equipmentName),
        tooltip: 'Add Spare Part',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: selectedFiles.map((file) {
          return ListTile(
            leading: Icon(file.path.endsWith('.pdf')
                ? Icons.picture_as_pdf
                : Icons.image),
            title: Text(file.path.split('/').last),
            trailing: IconButton(
                onPressed: () {
                  setState(() {
                    selectedFiles.remove(file);
                  });
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
          );
        }).toList());
  }

  Future<void> _uploadAllFiles(BuildContext context) async {
    for (var file in selectedFiles) {
      await uploadPDf(file);
    }
    setState(() {
      selectedFiles.clear();
    });
  }

  void _createNewSpares(String equipmentName) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              scrollable: true,
              title: Text('Create New Spare Part for $equipmentName'),
              content: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter a name' : null,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _partNumberController,
                            decoration: InputDecoration(
                                labelText: 'Part Number',
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          _pickImage("Part Number");
                                          print('Gallery Icon clicked');
                                        },
                                        icon: Icon(
                                          Icons.image,
                                          color: Colors.blue,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          _pickFile("Part Number");
                                          print('File Icon clicked');
                                        },
                                        icon: Icon(
                                          Icons.attach_file,
                                          color: Colors.blue,
                                        ))
                                  ],
                                )),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter a part number'
                                : null,
                          ),
                        )
                      ],
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minStockController,
                            decoration: const InputDecoration(
                                labelText: 'Minimum Stock'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _maxStockController,
                            decoration: const InputDecoration(
                                labelText: 'Maximum Stock'),
                            keyboardType: TextInputType.number,
                          ),
                        )
                      ],
                    ),
                    TextFormField(
                      controller: _leadTimeController,
                      decoration: const InputDecoration(labelText: 'Lead Time'),
                    ),
                    TextFormField(
                      controller: _supplierInfoController,
                      decoration: InputDecoration(
                          labelText: 'Supplier Information',
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _pickImage("Supplier Information");
                                    print('Gallery Icon clicked');
                                  },
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.blue,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    _pickFile("Supplier Information");
                                    print('File Icon clicked');
                                  },
                                  icon: Icon(
                                    Icons.attach_file,
                                    color: Colors.blue,
                                  ))
                            ],
                          )),
                    ),
                    TextFormField(
                      controller: _criticalityController,
                      decoration:
                          const InputDecoration(labelText: 'Criticality'),
                    ),
                    TextFormField(
                      controller: _conditionController,
                      decoration: InputDecoration(
                          labelText: 'Condition',
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _pickImage("Condition");
                                    print('Gallery Icon clicked');
                                  },
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.blue,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    _pickFile("Condition");
                                    print('File Icon clicked');
                                  },
                                  icon: Icon(
                                    Icons.attach_file,
                                    color: Colors.blue,
                                  ))
                            ],
                          )),
                    ),
                    TextFormField(
                      controller: _warrantyController,
                      decoration: InputDecoration(
                          labelText: 'Warranty Information',
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _pickImage("Waranty Information");
                                    print('Gallery Icon clicked');
                                  },
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.blue,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    _pickFile("Warranty Information");
                                    print('File Icon clicked');
                                  },
                                  icon: Icon(
                                    Icons.attach_file,
                                    color: Colors.blue,
                                  ))
                            ],
                          )),
                    ),
                    TextFormField(
                      controller: _usageRateController,
                      decoration:
                          const InputDecoration(labelText: 'Usage Rate'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildSelectedFilesList(),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _uploadAllFiles(context);
                            _addSparePart();
                            Navigator.pop(context);
                          }

                          // _submitForm();
                        },
                        child: const Text(
                          'Save Spare',
                          style: TextStyle(color: Colors.green),
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ))
                  ],
                ),
              ],
            ));
  }

  Future<void> uploadPDf(File pdfFile) async {
    print('Starting upload process...');
    final url = Uri.parse('http://0.0.0:8000/pdf-transfer');

    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['filemenu'] = 'Spares' ?? '';
      request.fields['process_name'] = widget.processName ?? '';
      request.fields['subprocess_name'] = widget.subprocessName ?? '';
      request.fields['equipment_name'] = widget.equipmentName ?? '';

      var stream = http.ByteStream(pdfFile.openRead());

      var length = await pdfFile.length();

      var multipartFile = http.MultipartFile('file', stream, length,
          filename: pdfFile.path.split('/').last);
      request.files.add(multipartFile);

      print('Sending request...');
      var response = await request.send();
      print('Responce status code: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        print('File uploaded successfully');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File uploaded successfully')));
        }
      } else {
        print('Error uploading file');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error uploading file')));
        }
      }
    } catch (e, stackTrace) {
      print('Error uploading file: $e');
      print('Stack trace $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error uploading PDF: $e')));
      }
    }
  }

  Future<void> _generateAndUploadPDF(SparePart sparePart) async {
    try {
      final pdfFile = await _generateAndSavePDF(sparePart);
      await uploadPDf(pdfFile);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickImage(String fieldName) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _saveFileToFolder(pickedFile.path, fieldName);
    }
  }

  Future<void> _pickFile(String fieldName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String filePath = result.files.single.path!;
      await _saveFileToFolder(filePath, fieldName);
    }
  }

  Future<void> _saveFileToFolder(String filePath, String fieldName) async {
    // Define your custom storage path
    String baseStoragePath = "lib/pages/pages2/equipment/spares/sparesstorage";

    // Define folder structure
    String equipmentFolderPath = '$baseStoragePath/equipment_folder';
    String fieldFolderPath = '$equipmentFolderPath/$fieldName';

    // Ensure the folders exist
    Directory(fieldFolderPath).createSync(recursive: true);

    // Copy file to the appropriate subfolder
    File file = File(filePath);
    String newFilePath = '$fieldFolderPath/${file.uri.pathSegments.last}';
    await file.copy(newFilePath);

    print('File saved to: $newFilePath');
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final sparePart = SparePart(
          equipmentName: widget.equipmentName,
          name: _nameController.text,
          partNumber: _partNumberController.text,
          description: _descriptionController.text,
          minimumStock: int.tryParse(_minStockController.text) ?? 0,
          maximumStock: int.tryParse(_maxStockController.text) ?? 0,
          leadTime: _leadTimeController.text,
          supplierInfo: _supplierInfoController.text,
          criticality: _criticalityController.text,
          condition: _conditionController.text,
          warranty: _warrantyController.text,
          usageRate: _usageRateController.text,
        );
        final SparePartsService _service = SparePartsService();
        await _service.createSparePart(sparePart);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Spare Part Created Succuessfully")));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error creating Spare Part: $e")));
      }
    }
  }

  Future<void> uploadPDF(File pdfFile, BuildContext context) async {
    print('Starting upload process...');
    final url = Uri.parse('http://0.0.0.0:8000/pdf-transfer');
    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['filemenu'] = 'Spares' ?? '';
      request.fields['process_name'] = widget.processName ?? '';
      request.fields['subprocess_name'] = widget.subprocessName ?? '';
      request.fields['equipment_name'] = widget.equipmentName ?? '';

      var stream = http.ByteStream(pdfFile.openRead());
      var length = await pdfFile.length();
      var multipartFile = http.MultipartFile('file', stream, length,
          filename: pdfFile.path.split('/').last);
      request.files.add(multipartFile);

      print("Sending request...");
      var response = await request.send();
      print("Response status code: ${response.statusCode}");

      final responseBody = await response.stream.bytesToString();
      print("Response body: $responseBody");

      if (response.statusCode == 200) {
        print("File uploaded successfully");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File uploaded successfully')));
        }
      }
    } catch (e, stackTrace) {
      print("Error Uploading file: $e");
      print("Stack trace: $stackTrace");
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error uploading: PDF: e")));
      }
    }
  }

  Future<void> handleUpload(BuildContext context) async {
    print("Handle upload Started...");
    try {
      final file = await pickPDFFile();
      if (file != null) {
        print("File Picked, starting upload...");
        await uploadPDF(file, context);
      } else {
        print("No file selected in handleUpload");
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("No file selected")));
        }
      }
    } catch (e) {
      print("Error in handleUpload: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<File?> pickPDFFile() async {
    print("Sarting file picker...");
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      print('FilePicker result: ${result?.files.length ?? "null"}');

      if (result != null && result.files.isNotEmpty) {
        print("File Selected: ${result.files.single.path}");
        return File(result.files.single.path!);
      }
      print("No file selected");
      return null;
    } catch (e) {
      print("Error in pickPDFFile: $e");
      return null;
    }
  }
}
