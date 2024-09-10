import 'dart:io';
import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/models/video_model.dart';
import 'package:x_video_ai/services/abstracts/file_service.dart';
import 'package:x_video_ai/utils/constants.dart';
import 'package:x_video_ai/utils/generate_md5_name.dart';

class VideoService extends FileService {
  final FFMpeg _ffmpeg;
  final String _tmpFolder = 'tmp';
  final String _videosFolder = 'videos';

  VideoService(
    this._ffmpeg,
  );

  String _getFileExtension(XFile file) {
    final List<String> split = file.path.split('.');
    return split.last;
  }

  Future<VideoDataModel> uploadToTmpFolder(
    XFile file,
    String projectPath,
  ) async {
    final String tmpPath = '$projectPath/$_tmpFolder';
    final String md5Name = await generateMD5Name(file);
    final String fileExtension = _getFileExtension(file);
    final String filePath = '$tmpPath/$md5Name.$fileExtension';

    try {
      await createDirectory(tmpPath);
      await file.saveTo(filePath);
      return VideoDataModel(
        name: md5Name,
        start: 0,
        end: 0,
        duration: 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoDataModel> getInformation(
    VideoDataModel video,
    String projectPath,
  ) async {
    final String pathFile =
        '$projectPath/$_tmpFolder/${video.name}.$kVideoExtension';

    try {
      final Map<String, dynamic> information =
          await _ffmpeg.getVideoInformation(pathFile);

      return video.mergeWith({
        'duration': information['duration'],
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> standardizeVideo(
    String fileName,
    String projectPath, {
    String format = kOrientation16_9,
  }) async {
    final String tmpPath = '$projectPath/$_tmpFolder';
    final String standardizePath = '$projectPath/$_videosFolder';

    final XFile file = XFile('$tmpPath/$fileName.$kVideoExtension');

    final String standardizeFilePath =
        '$standardizePath/$fileName.$kVideoExtension';

    try {
      await createDirectory(standardizePath);
      await _ffmpeg.processVideo(
        inputPath: file.path,
        outputPath: standardizeFilePath,
        format: format,
      );

      File fileToDelete = File(file.path);
      await fileToDelete.delete();

      return {
        'name': fileName,
        'file': XFile(standardizeFilePath),
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Uint8List?> generateThumbnail(
      {required XFile file,
      required String outputPath,
      String? fileName}) async {
    try {
      await createDirectory('$outputPath/$_tmpFolder');

      return await _ffmpeg.generateThumbnail(
        inputFile: file.path,
        outputPath: '$outputPath/$_tmpFolder',
        filename: fileName ?? await generateMD5Name(file),
      );
    } catch (e) {
      rethrow;
    }
  }
}
