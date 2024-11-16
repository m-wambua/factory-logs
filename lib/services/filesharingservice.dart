import 'dart:async';
import 'dart:io';

import 'package:collector/services/filepickerrepository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



enum FileType { pdf, image, video }

class FileUploadService {
  //singleton pattern

  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() {
    return _instance;
  }
  FileUploadService._internal();

  //configurtion
  static const String baseUrl = 'http://0.0.0.0:8000';
  static const Map<FileType, int> maxFileSizes = {
    FileType.pdf: 10 * 1024 * 1024,
    FileType.image: 5 * 1024 * 1024,
    FileType.video: 100 * 1024 * 1024,
  };
  //Upload status stream controller
  final _uploadStatusController = StreamController<UploadStatus>.broadcast();
  Stream<UploadStatus> get uploadStatus => _uploadStatusController.stream;

  Future<FileUploadResult> uploadFile(
    File file,
    FileType fileType, {
    void Function(double)? onProgress,
  }) async {
    try {
      //validate file size
      final fileSize = await file.length();
      if (fileSize > maxFileSizes[fileType]!) {
        return FileUploadResult.error(
            'File Size exceeds maximum allowed size of ${maxFileSizes[fileType]! ~/ (1024 * 1024)}MB');
      }
      final endpoint = _getEndpointForFileType(fileType);
      final url = Uri.parse('$baseUrl$endpoint');

      var request = http.MultipartRequest('POST', url);
      var stream = http.ByteStream(file.openRead());
      var multipartFile = http.MultipartFile(
        'file',
        stream,
        fileSize,
        filename: file.path.split('/').last,
      );

      request.files.add(multipartFile);
      request.fields['fileType'] = fileType.name;
      final response = await request.send().timeout(const Duration(minutes: 5),
          onTimeout: () {
        throw TimeoutException('Upload timed out');
      });

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return FileUploadResult.success(responseBody);
      } else {
        return FileUploadResult.error(
            'Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      return FileUploadResult.error(e.toString());
    }
  }

  String _getEndpointForFileType(FileType fileType) {
    return switch (fileType) {
      FileType.pdf => '/pdf-transfer',
      FileType.image => '/image-transfer',
      FileType.video => '/video-transfer'
    };
  }

  void dispose() {
    _uploadStatusController.close();
  }
}

class UploadStatus {
  final double progress;
  final String? message;
  final bool isCompleted;
  final bool hasError;

  UploadStatus({
    required this.progress,
    this.message,
    this.isCompleted = false,
    this.hasError = false,
  });
  factory UploadStatus.progress(double progress) {
    return UploadStatus(progress: progress);
  }
  factory UploadStatus.completed(String message) {
    return UploadStatus(progress: 0.0, message: message, hasError: true);
  }
}

class FileUploadResult {
  final bool success;
  final String message;
  final dynamic data;

  FileUploadResult({required this.success, required this.message, this.data});
  factory FileUploadResult.success(dynamic data) {
    return FileUploadResult(
      success: true,
      message: 'Upload Successfull',
      data: data,
    );
  }

  factory FileUploadResult.error(String message) {
    return FileUploadResult(success: false, message: message);
  }
}
class FileUploadProvider extends ChangeNotifier {
  final FileUploadService _uploadService = FileUploadService();
  final FilePickerRepository _pickerRepository = FilePickerRepository();

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;

  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;

  Future<void> uploadFile(MyFileType fileType) async {
    try {
      _error = null;
      final file = await _pickerRepository.pickFile(fileType);

      if (file != null) {
        _isUploading = true;
        notifyListeners();

        final result = await _uploadService.uploadFile(
          file,
          fileType as FileType,
          onProgress: (progress) {
            _uploadProgress = progress;
            notifyListeners();
          },
        );

        if (!result.success) {
          _error = result.message;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }
}
class RetryStrategy {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;

  RetryStrategy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 10),
  });

  Future<T> execute<T>(Future<T> Function() operation) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) rethrow;

        await Future.delayed(delay);
        delay *= 2;
        if (delay > maxDelay) delay = maxDelay;
      }
    }
  }
}
