import 'dart:convert';
import 'dart:io';

import 'package:collector/pages/pages2/equipment/spares/allspares.dart';
import 'package:collector/pages/pages2/creatorspage.dart';
import 'package:collector/pages/pages2/dailydeltas/dailydeltacreator.dart';
import 'package:collector/pages/pages2/dailydeltas/dailydeltatableloader.dart';
import 'package:collector/pages/pages2/dailydeltas/delltafilemanager.dart';
import 'package:collector/pages/pages2/emaiandstorage/emailsender.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/pages2/cableSchedule/cablescheduleadd.dart';
import 'package:collector/pages/pages2/codebase/codebase.dart';
import 'package:collector/pages/pages2/codebase/codedetails.dart';
import 'package:collector/pages/pages2/startupprocedure/startup.dart';
import 'package:collector/pages/pages2/startupprocedure/startuppage.dart';
import 'package:collector/pages/pages2/subprocesscreator.dart';
import 'package:collector/pages/pages2/datafortables/tableloader.dart';
import 'package:collector/widgets/appassets.dart';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class DynamicPageLoader extends StatefulWidget {
  final String processName;
  final List<String> subprocesses; // Add subprocesses as a parameter
  final List<String> subdeltas;

  DynamicPageLoader(
      {required this.processName,
      required this.subprocesses, // Initialize subprocesses
      List<String>? subdeltas})
      : this.subdeltas = subdeltas ?? [];

  @override
  State<DynamicPageLoader> createState() => _DynamicPageLoaderState();
}

class _DynamicPageLoaderState extends State<DynamicPageLoader> {
  final List<NotificationModel> notifications = [];
  StartUpEntryData startUpEntryData = StartUpEntryData();
  List<ColumnInfo> _columns = [
    ColumnInfo(name: 'Equipment')
  ]; // Ensure default column
  int _numRows = 5;
  List<List<String>> _tableData = [];
  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  bool _productionSelected = false;

  DateTime? saveButtonClickTime;
  bool _eventfulShift = false;
  TextEditingController _eventDescriptionController = TextEditingController();
  TextEditingController _occurenceDuringShiftController =
      TextEditingController();

  Map<String, List<Map<String, dynamic>>> _savedDataMap = {};
  List<TextEditingController> mailingListController = [TextEditingController()];
  TextEditingController _nameController = TextEditingController();
  List<String>? subdeltas; // Initialize subdeltas
  Map<String, dynamic> _savedDeltaDataMap = {};
  @override
  void initState() {
    super.initState();

    _loadAllSavedData();

    _loadSubdeltas();
  }

  // Load subdeltas for the given process
// Assuming you have a Map to hold the saved delta data

// Load subdeltas for the given process
  void _loadSubdeltas() async {
    List<String>? loadedSubdeltas =
        await DeltaFileManager.loadSubdeltasForProcess(widget.processName);
    setState(() {
      subdeltas = loadedSubdeltas ?? [];
    });

    // Load saved data for each subdelta
    await _loadSavedDeltaData();
  }

// Load saved data for each individual subdelta
  Future<void> _loadSavedDeltaData() async {
    for (String subdelta in subdeltas!) {
      //print('Loading data for subdelta: $subdelta');
      var loadedData = await _loadSavedDeltaTables(subdelta);
      //print('Loaded data: $loadedData');
      _savedDeltaDataMap[subdelta] = loadedData;
    }
    setState(() {
      //print('Updated savedDeltaDataMap: $_savedDeltaDataMap');
    });
  }

  Future<void> _loadAllSavedData() async {
    for (String subprocess in widget.subprocesses) {
      _savedDataMap[subprocess] = await _loadSavedData(subprocess);
    }
    setState(() {
      //print('Update SavedDataMap $_savedDataMap');
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
            Text(widget.processName),
          ],
        ),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllEquipmentSparesPage()));
                },
                icon: const Icon(Icons.chrome_reader_mode),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DailyDeltaCreator(
                                processName: widget.processName,
                                subdeltas: subdeltas,
                              )));
                },
                icon: const Icon(Icons.compare),
              ),
              IconButton(
                  onPressed: () {
                    _showCableScheduleDialog(context);
                  },
                  icon: const Icon(Icons.cable_outlined)),
              IconButton(
                  onPressed: () {
                    _showOptionsDialog(context);
                  },
                  icon: const Icon(Icons.code)),
              IconButton(
                  onPressed: () {
                    _addStartUpProcedure(context);
                  },
                  icon: const Icon(Icons.power_settings_new)),
              IconButton(
                  onPressed: () {
                    _showUpdateProcess(context);
                  },
                  icon: const Icon(Icons.border_color_outlined))
            ],
          )
        ],
      ),
      body: FutureBuilder<Widget>(
        future: _loadDynamicPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading page'));
          } else {
            return snapshot.data ?? Center(child: Text('Page not found'));
          }
        },
      ),
    );
  }

  Future<Widget> _loadDynamicPage() async {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio Buttons for production selection
              Row(
                children: [
                  Radio(
                      value: true,
                      groupValue: _productionSelected,
                      onChanged: (value) {
                        setState(() {
                          _productionSelected = value!;
                        });
                      }),
                  const Text('Production'),
                  Radio(
                      value: false,
                      groupValue: _productionSelected,
                      onChanged: (value) {
                        setState(() {
                          _productionSelected = value!;
                        });
                      }),
                  const Text('No Production'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Logs',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        // Display subprocess buttons only if production was selected
                        if (_productionSelected)
                          ..._buildElevatedButtonsForSubprocesses(),
                        if (!_productionSelected)
                          ..._buildElevatedButtonsForSubprocessesNoProduction(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Delta',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        ..._buildElevatedButtonsForSubDeltas()
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),
              const Text(
                  'ODS Occurrence During Shift (Delay Please Indicate time)'),
              TextFormField(
                maxLines: 20,
                controller: _occurenceDuringShiftController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    filled: true,
                    fillColor: Colors.grey[200]),
              ),
              const SizedBox(height: 50),
              CheckboxListTile(
                  title: const Text('Was the Shift eventful'),
                  value: _eventfulShift,
                  onChanged: (value) {
                    setState(() {
                      _eventfulShift = value!;
                    });
                  }),
              if (_eventfulShift)
                TextFormField(
                  controller: _eventDescriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Describe the event...',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      saveButtonClickTime = DateTime.now();
                    });
                    _showRecordsDialog(context);
                  },
                  child: const Text('Submit All Records')),
              if (saveButtonClickTime != null)
                Text('The Data was Saved at $saveButtonClickTime'),
            ],
          ),
        ),
      ),
    );
  }

///////////////////////////////////////////////////////////

  void _showRecordsDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Records'),
            content: _displayRecords(),
          );
        });
  }

  void _showSubmitList(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Submit to: '), content: _submissionList());
        });
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> createExcelFile(Map<String, dynamic> savedData,
      String processName, String subprocessName) async {
    var excelFile = excel.Excel.createExcel(); // Create a new Excel file
    String timestamp = savedData['timestamp'] ?? 'Unknown';
    var sheet = excelFile['Sheet1'];

    // Add column headers
    List<dynamic> columnsJson = savedData['columns'] ?? [];
    List<String> columnNames =
        columnsJson.map((columnJson) => columnJson['name'].toString()).toList();

    // Add column names to sheet
    // Convert column names to CellValue
    var columnHeaders =
        columnNames.map((name) => excel.TextCellValue(name)).toList();
    sheet.appendRow(columnHeaders);

    // Add table data
    List<dynamic> tableDataJson = savedData['tableData'] ?? [];
    for (var row in tableDataJson) {
      // Ensure each cell is a string
      List<dynamic> rowValues = row.map((cell) => cell.toString()).toList();
      sheet.appendRow(
          rowValues.map((value) => excel.TextCellValue(value)).toList());
    }

    // Save Excel file
    List<String> filePaths = [];
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    // Replace spaces with underscores for better file naming
    String sanitizedProcessName = processName.replaceAll(' ', '_');
    String sanitizedSubprocessName = subprocessName.replaceAll(' ', '_');
    String sanitizedTimeStamp = timestamp.replaceAll(' ', '_');
    String fileName =
        '${sanitizedProcessName}_${sanitizedSubprocessName}_$sanitizedTimeStamp.xlsx';
    File file = File('$tempPath/$fileName');

    // Write the Excel file to disk
    var bytes = excelFile.encode();
    if (bytes != null) {
      file.writeAsBytesSync(bytes);
    }

    filePaths.add(file.path);
    return filePaths;
  }

  void _sendEmailWithAttachments(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    Map<String, dynamic> pdfData = {
      'processName': widget.processName,
      'productionState': _productionSelected ? 'Production' : 'No Production',
      'odsOccurrence': _occurenceDuringShiftController.text,
      'eventfulShift': _eventfulShift ? 'Yes' : 'No',
      'eventDescription': _eventDescriptionController.text,
      'subprocesses': widget.subprocesses.map((subprocess) {
        if (_savedDataMap[subprocess]?.isNotEmpty ?? false) {
          return {'name': subprocess, 'data': _savedDataMap[subprocess]!.last};
        } else {
          return {'name': subprocess, 'data': null};
        }
      }).toList(),
      'dailydelta': subdeltas!.map((subdelta) {
        if (_savedDeltaDataMap[subdelta]?.isNotEmpty ?? false) {
          return {'name': subdelta, 'data': _savedDeltaDataMap[subdelta]!.last};
        } else {
          return {'name': subdelta, 'data': null};
        }
      }).toList(),
    };

    try {
      await EmailSender.sendEmail(
          mailingListController, pdfData, EmailType.productionSummary);

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.green),
            content: const Text('Email sent successfully!'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Icon(Icons.error, color: Colors.red),
            content: Text('Failed to send email: $e'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _submissionList() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setStateDialog) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < mailingListController.length; i++)
                TextFormField(
                  controller: mailingListController[i],
                  decoration:
                      const InputDecoration(labelText: 'enter email address:'),
                  onChanged: (value) {},
                ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () {
                  setStateDialog(() {
                    mailingListController.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        _sendEmailWithAttachments(context);
                      },
                      child: const Text('Okay')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  String _collectTextData() {
    String productionState =
        _productionSelected ? 'Production' : ' No Prodution';
    String odsOccurence = _occurenceDuringShiftController.text;
    String eventfulShift = _eventfulShift ? 'Yes' : 'No';
    String eventDescription = _eventDescriptionController.text;

    return '''
Production State: $productionState
ODS Occurence During Shift: $odsOccurence
Eventful Shift: $eventfulShift
Event Description: $eventDescription
''';
  }

  String _formatEmailBody() {
    String textData = _collectTextData();
    return '''
    Dear Team,
    Please find below the  production details for the shift:
    $textData

    Best regards,
    ${_nameController.text}
    ''';
  }
///////////////////////////////////////////////////////////

  Widget _displayRecords() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoText('Production State',
              _productionSelected ? 'Production' : 'No Production'),
          _buildInfoText('ODS Occurrence During Shift',
              _occurenceDuringShiftController.text),
          _buildInfoText('Eventful Shift', _eventfulShift ? 'Yes' : 'No'),
          _buildInfoText('Event Description', _eventDescriptionController.text),
          const SizedBox(height: 10),
          const Text(
            'The Subprocesses Logged are:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...widget.subprocesses.map(_buldSubprocessCard),
          const SizedBox(
            height: 10,
          ),
          const Text(
            ' The Daily Delta Logged are:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          ...subdeltas!.map(_buildDailyDeltaCard2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(
                width: 10,
              ),
              TextButton(
                  onPressed: () async {
                    createAndStorePDF();
                  },
                  child: const Text('Submit')),
              TextButton(
                  onPressed: () {
                    _showSubmitList(context);
                  },
                  child: const Text('Submit and Forward'))
            ],
          )
        ],
      ),
    );
  }

  Future<File> createAndStorePDF() async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(build: (pw.Context context) {
      return [
        pw.Header(level: 0, child: pw.Text('Process Summary')),
        pw.Paragraph(
            text:
                'Production State: ${_productionSelected ? 'Production' : 'No Production'}'),
        pw.Paragraph(
            text:
                'ODS Occurrence During Shift: ${_occurenceDuringShiftController.text}'),
        pw.Paragraph(
            text: 'Eventful Shift: ${_eventfulShift ? ' Yes' : ' No'}'),
        pw.Paragraph(
            text: 'Event Description: ${_eventDescriptionController.text}'),
        pw.Header(level: 1, child: pw.Text('Subprocesses')),
        ...widget.subprocesses
            .map((subprocess) => _buildPDFSubprocessSection(subprocess)),
        pw.Header(level: 1, child: pw.Text('Daily Delta')),
        ...subdeltas!.map((subdelta) => _buildPDFSubdeltaSection(subdelta))
      ];
    }));

    final String timestamp =
        DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String fileName = '${widget.processName}_${timestamp}_Summary.pdf';

    Directory appDocDir = Directory('services/summary_files');
    final String appDocPath = appDocDir.path;

    final String fullPath = '$appDocPath/pages/summary_files/$fileName';

    await Directory('$appDocPath/pages/summary_files').create(recursive: true);
    final File file = File(fullPath);
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildPDFSubprocessSection(String subprocess) {
    if (_savedDataMap[subprocess]?.isNotEmpty ?? false) {
      final savedData = _savedDataMap[subprocess]!.last;
      final timestamp = savedData['timestamp'] ?? 'Unknown';
      final columnsJson = savedData['columns'] ?? [];
      final tableDataJson = savedData['tableData'] ?? [];

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 2, child: pw.Text(subprocess)),
          pw.Paragraph(text: 'Saved on: $timestamp'),
          pw.TableHelper.fromTextArray(
            headers: columnsJson
                .map<String>((column) =>
                    '${column['name']}${column['unit']?.isNotEmpty ?? false ? ' (${column['unit']})' : ''}')
                .toList(),
            data: tableDataJson
                .map<List<String>>((row) => (row as List<dynamic>)
                    .map((cell) => cell.toString())
                    .toList())
                .toList(),
          ),
        ],
      );
    } else {
      return pw.Paragraph(text: 'No Data available for $subprocess');
    }
  }

 pw.Widget _buildPDFSubdeltaSection(String subdelta) {
  if (_savedDeltaDataMap[subdelta]?.isNotEmpty ?? false) {
    final savedData = _savedDeltaDataMap[subdelta]!.last;
    final timestamp = savedData['timestamp'] ?? 'Unknown';
    final columnLabels = List<String>.from(savedData['columnLabels'] ?? []);
    final columnUnits = List<String>.from(savedData['columnUnits'] ?? []);
    final tableDataJson = savedData['tableData'] ?? [];

    // Combine column labels with their units
    final headers = List<String>.generate(
      columnLabels.length,
      (index) {
        final label = columnLabels[index];
        final unit = index < columnUnits.length ? columnUnits[index] : '';
        return unit.isNotEmpty ? '$label ($unit)' : label;
      },
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(level: 2, child: pw.Text(subdelta)),
        pw.Paragraph(text: 'Saved on: $timestamp'),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: tableDataJson
              .map<List<String>>((row) => 
                  (row as List<dynamic>)
                      .map((cell) => cell.toString())
                      .toList())
              .toList(),
        )
      ],
    );
  } else {
    return pw.Paragraph(text: 'No Data available for $subdelta');
  }
}
  bool _isValidTableJson(Map<String, dynamic> tableJson) {
    return tableJson.containsKey('columns') &&
        tableJson.containsKey('numRows') &&
        tableJson.containsKey('tableData') &&
        tableJson.containsKey('timestamp');
  }

////////////////////////////////////////////////
  /// Delta Data

  Widget _buildDailyDataCard(String dailydelta) {
    return ExpansionTile(
      title: Text(
        dailydelta,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        // Always display the message indicating no data if there is no data
        if (_savedDeltaDataMap[dailydelta].isEmpty ?? false)
          _buildDeltaDataTable(_savedDeltaDataMap[dailydelta]!
              .last) // Display the data if available
        else
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
                'No Data available for $dailydelta'), // Show no data message
          ),
      ],
    );
  }

  List<Widget> _buildDailyDataCards() {
    // Check if subdeltas are null or empty
    if (subdeltas == null || subdeltas!.isEmpty) {
      return [
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('No delta has been uploaded')],
        ),
      ];
    }

    // Generate daily data cards for each subdelta
    return widget.subdeltas.map((delta) {
      return _buildDailyDataCard(delta);
    }).toList();
  }

  Widget _buildDeltaDataTable(Map<String, dynamic> tableData) {
    //print('Building table with data: $tableData');

    // Add null checks and default values
    List<String> units = [];
    if (tableData.containsKey('columnUnits')) {
      if (tableData['columnUnits'] is List) {
        units = (tableData['columnUnits'] as List)
            .map((u) => u?.toString() ?? '')
            .toList();
      }
    }

    // Add null check for columnLabels
    final columnLabels = tableData['columnLabels'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved on: ${tableData['timestamp'] ?? 'Unknown'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: List<Widget>.generate(
                    columnLabels.length,
                    (index) {
                      final label = columnLabels[index]?.toString() ?? '';
                      final unit = index < units.length ? units[index] : '';

                      return TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            unit.isNotEmpty ? '$label ($unit)' : label,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ...(tableData['tableData'] as List? ?? []).map<TableRow>((row) {
                  return TableRow(
                    children: (row as List? ?? []).map<Widget>((cell) {
                      return TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(cell?.toString() ?? ''),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyDeltaCard2(String subdelta) {
    return ExpansionTile(
      title: Text(
        subdelta,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        if (_savedDeltaDataMap[subdelta]?.isNotEmpty ?? false)
          _buildDailyDeltaTable(_savedDeltaDataMap[subdelta]!.last)
        else
          (Text('No Data Available for $subdelta'))
      ],
    );
  }

  Widget _buildDailyDeltaTable(Map<String, dynamic> tableData) {
    // Extract units and column labels
    List<String> units = [];
    if (tableData.containsKey('columnUnits')) {
      if (tableData['columnUnits'] is List) {
        units = (tableData['columnUnits'] as List)
            .map((u) => u?.toString() ?? '')
            .toList();
      }
    }

    // Create DataColumns
    List<DataColumn> columns = List<DataColumn>.generate(
      tableData['columnLabels'].length,
      (index) {
        final label = tableData['columnLabels'][index] ?? '';
        final unit = index < units.length ? units[index] : '';
        return DataColumn(
          label: Text(
            unit.isNotEmpty ? '$label ($unit)' : label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );

    // Create DataRows
    List<DataRow> rows = tableData['tableData'].map<DataRow>((row) {
      return DataRow(
        cells: row.map<DataCell>((cell) {
          return DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                cell.toString(),
                textAlign: TextAlign.left,
              ),
            ),
          );
        }).toList(),
      );
    }).toList();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Saved on: ${tableData['timestamp']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns,
              rows: rows,
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
              headingRowHeight: 56,
              columnSpacing: 24,
              horizontalMargin: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buldSubprocessCard(String subprocess) {
    return ExpansionTile(
      title: Text(
        subprocess,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        if (_savedDataMap[subprocess]?.isNotEmpty ?? false)
          _buildDataTable(_savedDataMap[subprocess]!.last)
        else
          Text('No Data available for $subprocess')
      ],
    );
  }

  Widget _buildDataTable(Map<String, dynamic> savedData) {
    String timestamp = savedData['timestamp'] ?? 'Unknown';
    List<dynamic> columnsJson = savedData['columns'] ?? [];
    List<dynamic> tableDataJson = savedData['tableData'] ?? [];

    List<DataColumn> columns = columnsJson.map((columnJson) {
      return DataColumn(
        label: Text(
            '${columnJson['name']}${columnJson['unit']?.isNotEmpty ?? false ? ' (${columnJson['unit']})' : ''}'),
      );
    }).toList();
    List<DataRow> rows = tableDataJson.map((row) {
      return DataRow(
        cells: (row as List<dynamic>)
            .map((cell) => DataCell(Text(cell.toString())))
            .toList(),
      );
    }).toList();
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Saved on: $timestamp',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(columns: columns, rows: rows),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadSavedDeltaTables(String delta) async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataFile = File('${savedDataDir.path}/${delta}_snapshots.json');

    if (!await savedDataFile.exists()) {
      return [];
    }

    List<Map<String, dynamic>> tempList = [];
    try {
      final jsonString = await savedDataFile.readAsString();
      final List<dynamic> tableJsonList =
          json.decode(jsonString) as List<dynamic>;

      tempList =
          tableJsonList.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error Loading Data!')));
    }
    return tempList;
  }
/*
  Future<List<Map<String, dynamic>>> _loadSavedDeltaTables(String delta) async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataFile = File('${savedDataDir.path}/${delta}_snapshots.json');
    print('$savedDataFile');
    if (!await savedDataFile.exists()) {
      return [];
    }
    List<Map<String, dynamic>> tempList = [];
    try {
      final jsonString = await savedDataFile.readAsString();
      final tableJson = json.decode(jsonString) as Map<String, dynamic>;
      if (_isValidTableJson(tableJson)) {
        tempList.add(tableJson);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error Loading Data!')));
    }
    return tempList;
  }

  */

  Future<List<Map<String, dynamic>>> _loadSavedData(String subprocess) async {
    final savedDataDir = await getApplicationDocumentsDirectory();
    final savedDataDirFile =
        Directory('${savedDataDir.path}/${subprocess}_saved');

    if (!await savedDataDirFile.exists()) {
      return [];
    }

    final files = savedDataDirFile.listSync();
    List<Map<String, dynamic>> tempList = [];

    for (var file in files) {
      if (file is File) {
        try {
          final jsonString = await file.readAsString();
          final tableJson = json.decode(jsonString) as Map<String, dynamic>;

          if (_isValidTableJson(tableJson)) {
            tempList.add(tableJson);
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error Loading Data!')),
          );
        }
      }
    }

    return tempList;
  }

  /////////////////////////////////////////////////

  List<Widget> _buildElevatedButtonsForSubprocesses() {
    return widget.subprocesses.map((subprocess) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _navigateToSubprocess(subprocess);
            },
            child: Text(subprocess),
          ),
          const SizedBox(height: 20),
        ],
      );
    }).toList();
  }

  void _navigateToSubprocess(String subprocess) {
    // Navigate to the specific subprocess page
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TableLoaderPage(
              processName: widget.processName,
                  subprocessName: subprocess,
                  onNotificationAdded: (notification) {
                    setState(() {
                      notifications.add(notification);
                    });
                  },
                )));
    // print("Navigating to subprocess: $subprocess");
  }

  ///////////////////////////////////////////////////////////////

  List<Widget> _buildElevatedButtonsForSubprocessesNoProduction() {
    return widget.subprocesses.map((subprocess) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _navigateToSubprocessNoProduction(subprocess);
            },
            child: Text(subprocess),
          ),
          const SizedBox(height: 20),
        ],
      );
    }).toList();
  }

  void _navigateToSubprocessNoProduction(String subprocess) {
    // Navigate to the specific subprocess page
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TableLoaderPage(
              processName: widget.processName,
                  subprocessName: subprocess,
                  onNotificationAdded: (notification) {
                    setState(() {
                      notifications.add(notification);
                    });
                  },
                )));
    print("Navigating to subprocess: $subprocess");
  }

  List<Widget> _buildElevatedButtonsForSubDeltas() {
    // Example logic to generate buttons
    if (subdeltas == null || subdeltas!.isEmpty) {
      return [
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('No delta has been uploaded')],
        )
      ];
    }

    return subdeltas!.map((delta) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _navigateToSubDelta(delta);
            },
            child: Text(delta),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      );
    }).toList();
  }

  void _navigateToSubDelta(String subDelta) {
    // Navigate to the specific subdelta page
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DeltaTableLoaderPage(
              processName: widget.processName,  
                  subDeltaName: subDelta,
                  onNotificationAdded: (notification) {
                    setState(() {
                      notifications.add(notification);
                    });
                  },
                )));
  }

  void _showCableScheduleDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return uploadCableScheduleorNot(context);
        });
  }

  Widget uploadCableScheduleorNot(BuildContext context) {
    return AlertDialog(
      title: const Text('Cabale Schedule Storage'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
//Handle view existing cable schedule
              },
              child: const Text('View Existing Cable Schedule')),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context); //close the dialog first
                //handle the uploading of the cable schedule
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UploadScreenCableSchedule()));
              },
              child: const Text('Upload New/Update Cable Schedule'))
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return uploadOrNot(context);
        });
  }

  Widget uploadOrNot(BuildContext context) {
    return AlertDialog(
      title: const Text('Code Base Storage'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the Dialog
                //Handle view existing code bases
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExistingCodeBasesPage()));
              },
              child: const Text('View Existing Code Bases')),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context); //close the dialog first
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UploadScreen()));
              },
              child: const Text('Upload New Code Bases'))
        ],
      ),
    );
  }

  void _showUpdateProcess(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildUpdateProcess(context);
      },
    );
  }

  Widget _buildUpdateProcess(BuildContext context) {
    return AlertDialog(
      title: const Text('Process Updater'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextButton(
            onPressed: () {
              _addNewEntry(context);
            },
            child: const Text('Update the Process Entries'),
          ),
        ],
      ),
    );
  }

  void _addNewEntry(BuildContext context) {
    String newEntryName = '';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Add New Entry'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter the details for the new entry:'),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter New Entry Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                    onChanged: (value) {
                      setState(() {
                        newEntryName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
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
                    if (newEntryName.isNotEmpty) {
                      // Retrieve existing subprocesses from CreatorPage
                      List<String> existingSubprocesses =
                          widget.subprocesses ?? [];

                      // Add the new entry to the existing subprocesses
                      existingSubprocesses.add(newEntryName);

                      // Navigate to CreatorPage with the updated subprocess list
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatorPage(
                            processName: widget.processName,
                            subprocesses: existingSubprocesses,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please enter a name for the new entry'),
                        ),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  ////////////////////////////////////////////////////////////
  // Method for start up procedure
  Future<void> _addStartUpProcedure(BuildContext context) async {
    List<TextEditingController> startUpController = [TextEditingController()];
    TextEditingController lastUpdatePerson = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                  'Add/Update Start-Up Procedure for ${widget.processName}'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 1; i < startUpController.length; i++)
                    TextField(
                      controller: startUpController[i],
                      decoration: InputDecoration(
                          labelText: 'Procedure $i',
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.image))
                            ],
                          )),
                      onChanged: (value) {},
                    ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: lastUpdatePerson,
                    decoration: const InputDecoration(labelText: 'Updated By'),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          startUpController.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add)),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            final startUpEntry = StartUpEntry(
                                startupStep: startUpController
                                    .map((controller) => controller.text)
                                    .toList(),
                                lastPersonUpdate: lastUpdatePerson.text,
                                lastUpdate: DateTime.now());
                            startUpEntryData.savingStartUpEntry(
                                startUpEntry, widget.processName);
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('Save')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StartUpEntriesPage(
                                        processName: widget.processName)));
                          },
                          child: const Text('View Saved Start Up Procedure')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'))
                    ],
                  )
                ],
              ),
            );
          });
        });
  }
}
