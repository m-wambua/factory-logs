import 'package:collector/pages/process_1/startup.dart';
import 'package:flutter/material.dart';

class StartUpEntriesPage extends StatefulWidget {
  const StartUpEntriesPage({super.key});

  @override
  _StartupEntriesPageState createState() => _StartupEntriesPageState();
}

class _StartupEntriesPageState extends State<StartUpEntriesPage> {
  StartUpEntryData startUpEntryData = StartUpEntryData();
  List<StartUpEntry> entries = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await startUpEntryData.loadStartUpEntry();
    setState(() {
      entries = startUpEntryData.startupData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StartUp Entries '),
      ),
      body: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ListTile(
              title: Text('Start Up Procedure ${index + 1}'),
              subtitle: Text(
                'Last Update: ${entry.lastUpdate}\nLast Person Update: ${entry.lastPersonUpdate}',
              ),
              onTap: () {
                _showEntryDetails(context, entry);
              },
            );
          }),
    );
  }

  void _showEntryDetails(BuildContext context, StartUpEntry entry) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(' Start Up Procedure Details Details'),
            content: SingleChildScrollView(
              child: ListBody(
                children: entry.startupStep.map((step) => Text(step)).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'))
            ],
          );
        });
  }
}
