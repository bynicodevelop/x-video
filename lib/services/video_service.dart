import 'dart:io';
import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/video_information.dart';
import 'package:x_video_ai/models/video_model.dart';
import 'package:x_video_ai/utils/constants.dart';
import 'package:x_video_ai/utils/generate_md5_name.dart';

class VideoService {
  final FileGateway _fileGateway;
  final FFMpeg _ffmpeg;
  final String _tmpFolder = 'tmp';
  final String _videosFolder = 'videos';

  VideoService(
    this._fileGateway,
    this._ffmpeg,
  );

  String _getFileExtension(XFile file) {
    final List<String> split = file.path.split('.');
    return split.last;
  }

  Future<VideoDataModel> uploadToTmpFolder(
    VideoDataModel videoDataModel,
    String projectPath,
  ) async {
    final String tmpPath = '$projectPath/$_tmpFolder';
    final String fileExtension = _getFileExtension(videoDataModel.file!);
    final String filePath = '$tmpPath/${videoDataModel.name}.$fileExtension';

    try {
      await _fileGateway.createDirectory(tmpPath);
      await videoDataModel.file!.saveTo(filePath);

      return videoDataModel.mergeWith({
        'file': XFile(filePath),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoInformation> getInformation(
    XFile video,
  ) async {
    try {
      final Map<String, dynamic> information =
          await _ffmpeg.getVideoInformation(video.path);

      return VideoInformation(
        duration: information['duration'],
        width: information['width'],
        height: information['height'],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<VideoDataModel> standardizeVideo(
    VideoDataModel videoDataModel,
    String projectPath, {
    String format = kOrientation16_9,
  }) async {
    final String standardizePath = '$projectPath/$_videosFolder';
    final String standardizeFilePath =
        '$standardizePath/${videoDataModel.file!.name}.$kVideoExtension';

    try {
      await _fileGateway.createDirectory(standardizePath);
      await _ffmpeg.processVideo(
        inputPath: videoDataModel.file!.path,
        outputPath: standardizeFilePath,
        format: format,
      );

      // rename file
      XFile newFile = XFile(standardizeFilePath);
      final String fileName = await generateMD5Name(newFile);
      final String newFilePath = '$standardizePath/$fileName.$kVideoExtension';

      await File(standardizeFilePath).rename(newFilePath);
      await File(videoDataModel.file!.path).delete();

      return videoDataModel.mergeWith({
        'name': fileName,
        'file': XFile(newFilePath),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Uint8List?> generateThumbnail(
      {required XFile file,
      required String outputPath,
      String? fileName}) async {
    try {
      await _fileGateway.createDirectory('$outputPath/$_tmpFolder');

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
