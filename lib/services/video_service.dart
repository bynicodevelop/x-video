import 'dart:io';
import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';

class VideoService {
  final String _tmpFolder = 'tmp';

  Future<String> _convertFileToMD5Name(XFile file) async {
    final Uint8List fileBytes = await file.readAsBytes();
    final Digest md5Hash = md5.convert(fileBytes);
    return md5Hash.toString();
  }

  String _getFileExtension(XFile file) {
    final List<String> split = file.path.split('.');
    return split.last;
  }

  Future<void> _createDirectory(String path) async {
    final Directory dir = Directory(path);
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
  }

  Future<void> uploadToTmpFolder(
    XFile file,
    String projectPath,
  ) async {
    final String tmpPath = '$projectPath/$_tmpFolder';
    final String md5Name = await _convertFileToMD5Name(file);
    final String fileExtension = _getFileExtension(file);
    final String filePath = '$tmpPath/$md5Name.$fileExtension';

    try {
      await _createDirectory(tmpPath);
      await file.saveTo(filePath);
    } catch (e) {
      rethrow;
    }
  }
}
