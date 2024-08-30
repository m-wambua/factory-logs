import 'dart:convert';
import 'dart:io';

import 'package:collector/pages/creatorspage.dart';
import 'package:collector/pages/lastEntrySaver.dart';
import 'package:collector/pages/models/notification.dart';
import 'package:collector/pages/process_1/cableSchedule/cablescheduleadd.dart';
import 'package:collector/pages/process_1/codebase/codebase.dart';
import 'package:collector/pages/process_1/codebase/codedetails.dart';
import 'package:collector/pages/process_1/startup.dart';
import 'package:collector/pages/process_1/startuppage.dart';
import 'package:collector/pages/saveddatapage.dart';
import 'package:collector/pages/subprocesscreator.dart';
import 'package:collector/pages/tableloader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class DynamicPageLoader extends StatefulWidget {
  final String processName;
  final List<String> subprocesses; // Add subprocesses as a parameter

  DynamicPageLoader({
    required this.processName,
    required this.subprocesses, // Initialize subprocesses
  });

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

  @override
  void initState() {
    super.initState();
    _loadAllSavedData();
  }

  Future<void> _loadAllSavedData() async {
    for (String subprocess in widget.subprocesses) {
      _savedDataMap[subprocess] = await _loadSavedData(subprocess);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.processName),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.chrome_reader_mode),
              ),
              IconButton(
                  onPressed: () {
                    _showCableScheduleDialog(context);
                  },
                  icon: Icon(Icons.cable_outlined)),
              IconButton(
                  onPressed: () {
                    _showOptionsDialog(context);
                  },
                  icon: Icon(Icons.code)),
              IconButton(
                  onPressed: () {
                    _addStartUpProcedure(context);
                  },
                  icon: Icon(Icons.power_settings_new)),
              IconButton(
                  onPressed: () {
                    _showUpdateProcess(context);
                  },
                  icon: Icon(Icons.border_color_outlined))
            ],
          )
        ],
      ),
      body: FutureBuilder<Widget>(
        future: _loadDynamicPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading page'));
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
              const SizedBox(
                height: 20,
              ),
              // Display subprocess buttons only if production was selected
              if (_productionSelected)
                Column(
                  children: _buildElevatedButtonsForSubprocesses(),
                ),
              if (!_productionSelected)
                Column(
                  children: _buildElevatedButtonsForSubprocessesNoProduction(),
                ),
              const SizedBox(
                height: 100,
              ),
              const Text(
                  ' ODS Occurrence During Shift (Delay Please Indicate time)'),
              TextFormField(
                maxLines: 20,
                controller: _occurenceDuringShiftController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    filled: true,
                    fillColor: Colors.grey[200]),
              ),
              const SizedBox(
                height: 50,
              ),
              CheckboxListTile(
                  title: const Text(' Was the Shift eventfull'),
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

              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      saveButtonClickTime = DateTime.now();
                    });
                    _showRecordsDialog(context);
                  },
                  child: const Text('Submit All Records')),
              if (saveButtonClickTime != null)
                Text('The Data was Saved at$saveButtonClickTime'),
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
          Text(
            'The Subprocesses Logged are:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...widget.subprocesses.map(_buldSubprocessCard),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Cancel'),
              ),
              const SizedBox(
                width: 10,
              ),
              TextButton(onPressed: () {}, child: Text('Submit'))
            ],
          )
        ],
      ),
    );  
  }

  bool _isValidTableJson(Map<String, dynamic> tableJson) {
    return tableJson.containsKey('columns') &&
        tableJson.containsKey('numRows') &&
        tableJson.containsKey('tableData') &&
        tableJson.containsKey('timestamp');
  }

  Widget _buldSubprocessCard(String subprocess) {
    return ExpansionTile(
      title: Text(
        subprocess,
        style: TextStyle(fontWeight: FontWeight.bold),
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
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(columns: columns, rows: rows),
          ),
        ],
      ),
    );
  }

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
          print('Error decoding JSON for $subprocess: $e');
        }
      }
    }

    return tempList;
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
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
    print("Navigating to subprocess: $subprocess");
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
                  subprocessName: subprocess,
                  onNotificationAdded: (notification) {
                    setState(() {
                      notifications.add(notification);
                    });
                  },
                )));
    print("Navigating to subprocess: $subprocess");
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
              child: Text('Upload New/Update Cable Schedule'))
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
      title: Text('Code Base Storage'),
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
              child: Text('View Existing Code Bases')),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context); //close the dialog first
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UploadScreen()));
              },
              child: Text('Upload New Code Bases'))
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
            child: Text('Update the Process Entries'),
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
              title: Text('Add New Entry'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter the details for the new entry:'),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
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
                  SizedBox(height: 10),
                ],
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
                        SnackBar(
                          content:
                              Text('Please enter a name for the new entry'),
                        ),
                      );
                    }
                  },
                  child: Text('Add'),
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
                                  onPressed: () {}, icon: Icon(Icons.image))
                            ],
                          )),
                      onChanged: (value) {},
                    ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: lastUpdatePerson,
                    decoration: InputDecoration(labelText: 'Updated By'),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          startUpController.add(TextEditingController());
                        });
                      },
                      icon: Icon(Icons.add)),
                  SizedBox(
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
                          child: Text('Save')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StartUpEntriesPage(
                                        processName: widget.processName)));
                          },
                          child: Text('View Saved Start Up Procedure')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'))
                    ],
                  )
                ],
              ),
            );
          });
        });
  }
}
