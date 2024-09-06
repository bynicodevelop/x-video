// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';

enum UploadStatus { idle, uploading, uploaded, uploadFailed }

class FileUploadState {
  final XFile file;
  final UploadStatus status;
  final String? message;

  FileUploadState({
    required this.file,
    required this.status,
    this.message,
  });

  FileUploadState copyWith({
    UploadStatus? status,
    String? message,
  }) {
    return FileUploadState(
      file: file,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

class UploadStateState {
  final List<FileUploadState> files;

  UploadStateState({required this.files});

  UploadStateState copyWith({
    List<FileUploadState>? files,
  }) {
    return UploadStateState(
      files: files ?? this.files,
    );
  }
}
