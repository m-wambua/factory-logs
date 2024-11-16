import 'dart:io';

import 'package:file_picker/file_picker.dart';

enum MyFileType { pdf, image, video }

class FilePickerRepository {
  Future<File?> pickFile(MyFileType fileType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _getAllowedExtensions(fileType),
      );

      if (result != null && result.files.isNotEmpty) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  List<String> _getAllowedExtensions(MyFileType fileType) {
    return switch (fileType) {
      MyFileType.pdf => ['pdf'],
      MyFileType.image => ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      MyFileType.video => ['mp4', 'mov', 'avi', 'mkv'],
    };
  }
}