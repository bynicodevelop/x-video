import 'dart:io';
import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/utils/constants.dart';

class VideoService {
  final FFMpeg _ffmpeg;
  final String _tmpFolder = 'tmp';
  final String _videosFolder = 'videos';

  VideoService(
    this._ffmpeg,
  );

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

  Future<XFile> uploadToTmpFolder(
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
      return XFile(filePath);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> standardizeVideo(
    XFile file,
    String projectPath, {
    String format = kOrientation16_9,
  }) async {
    final String standardizePath = '$projectPath/$_videosFolder';
    final String md5Name = await _convertFileToMD5Name(file);
    final String standardizeFilePath =
        '$standardizePath/$md5Name.$kVideoExtension';

    try {
      await _createDirectory(standardizePath);
      await _ffmpeg.processVideo(
        inputPath: file.path,
        outputPath: standardizeFilePath,
        format: format,
      );

      File fileToDelete = File(file.path);
      await fileToDelete.delete();

      return {
        'name': md5Name,
        'file': XFile(standardizeFilePath),
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Uint8List?> generateThumbnail({
    required XFile file,
    required String outputPath,
  }) async {
    try {
      return await _ffmpeg.generateThumbnail(
        inputFile: file.path,
        outputPath: '$outputPath/$_videosFolder',
        filename: await _convertFileToMD5Name(file),
      );
    } catch (e) {
      rethrow;
    }
  }
}
