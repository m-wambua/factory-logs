import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static Future<String?> get _localPath async {
    // final directory = await getApplicationCacheDirectory();
    final directory = 'pages';

    return directory;
  }

  static Future<void> createProcessFolders(String processName) async {
    final path = await _localPath;
    final processDirectory = Directory('$path/$processName');
    await processDirectory.create(recursive: true);
  }

  static Future<void> createProcessFiles(String processName) async {
    final path = await _localPath;
    final processPath = '$path/$processName';
    await _createFile('$processPath/${processName}Page.dart', '''
import 'package:flutter/material.dart';

class ${_capitalize(processName)}Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$processName'),
        
      ),
      body: ListView(
        children: [
          for (var subprocess in _subprocesses)
            ListTile(
              title: Text(subprocess),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/${processName}/' + subprocess + '_p');
                    },
                    child: Text('Production'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/${processName}/' + subprocess + '_np');
                    },
                    child: Text('No Production'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

final List<String> _subprocesses = ${_generateSubprocessList()};
''');
  }

  static Future<void> createSubprocessFolders(
      String processName, List<String> subprocesses) async {
    final path = await _localPath;
    for (final subprocess in subprocesses) {
      final subprocessDirectory = Directory('$path/$processName/$subprocess');

      await subprocessDirectory.create(recursive: true);
    }
  }

  static Future<void> createSubprocessFiles(
      String processName, String subprocess) async {
    final path = await _localPath;
    final subprocessPath = '$path/$processName/$subprocess';

    await _createFile('$subprocessPath/${subprocess}_p.dart',
        '// Placeholder for ${subprocess}_p.dart');

    await _createFile('$subprocessPath/${subprocess}_np.dart',
        '// Placeholder for ${subprocess}_np.dart');

    await _createFile('$subprocessPath/${subprocess}_data_display.dart',
        '// Placeholder for ${subprocess}_data_display.dart');

    await _createFile('$subprocessPath/${subprocess}_data.dart',
        '// Placeholder for ${subprocess}_data.dart');
  }

  static Future<void> _createFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }

  static String _generateProcessPage(String processName) {
    return '''
import 'package:flutter/material.dart';

class ${_capitalize(processName)}Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$processName'),
      ),
      body: ListView(
        children: [
          for (var subprocess in _subprocesses)
            ListTile(
              title: Text(subprocess),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/${processName.toLowerCase()}/' + subprocess.toLowerCase() + '_p');
                    },
                    child: Text('Production'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/${processName.toLowerCase()}/' + subprocess.toLowerCase() + '_np');
                    },
                    child: Text('No Production'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

final List<String> _subprocesses = ${_generateSubprocessList()};
''';
  }

  static String _generateSubprocessPage(String subprocess,
      {required bool isProduction}) {
    final type = isProduction ? 'p' : 'np';
    return '''
import 'package:flutter/material.dart';

class ${_capitalize(subprocess)}${type.toUpperCase()}Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$subprocess ${isProduction ? 'Production' : 'No Production'}'),
      ),
      body: Center(
        child: Text('$subprocess ${isProduction ? 'Production' : 'No Production'} Page'),
      ),
    );
  }
}
''';
  }

  static String _generateSubprocessList() {
    // Generate list of subprocess names dynamically
    final subprocesses = [
      'Subprocess1P',
      'Subprocess2NP',
      'Subprocess3P'
    ]; // Replace with your dynamic list
    return '[${subprocesses.map((s) => "'$s'").join(', ')}]';
  }

  static String _capitalize(String s) =>
      s.substring(0, 1).toUpperCase() + s.substring(1);
}
