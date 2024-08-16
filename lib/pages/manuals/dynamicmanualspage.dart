import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final String equipmentName;
  const DynamicManualsPage({super.key, required this.equipmentName});

  @override
  State<DynamicManualsPage> createState() => _DynamicManualsPageState();
}

class _DynamicManualsPageState extends State<DynamicManualsPage> {
  List<Map<String, String>> _manuals = [];
  late String _equipmentName;

  @override
  Widget build(BuildContext context) {
    _equipmentName = ModalRoute.of(context)?.settings.arguments as String;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Manuals for ${widget.equipmentName}'),
      ),
    );
  }
}
