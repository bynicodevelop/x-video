// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/controllers/video_data_controller.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/models/upload_state_model.dart';
import 'package:x_video_ai/models/video_model.dart';
import 'package:x_video_ai/services/video_service.dart';
import 'package:x_video_ai/utils/generate_md5_name.dart';

class UploadControllerProvider extends StateNotifier<UploadStateState> {
  final VideoService _videoService;
  final ContentController _contentController;
  final VideoDataControllerProvider _videoDataController;

  UploadControllerProvider(
    VideoService videoService,
    ContentController contentController,
    VideoDataControllerProvider videoDataController,
  )   : _videoService = videoService,
        _contentController = contentController,
        _videoDataController = videoDataController,
        super(UploadStateState(files: []));

  Future<void> upload(
    XFile file,
    Key? key,
  ) async {
    final FileUploadState fileUploadState = FileUploadState(
      file: file,
      status: UploadStatus.uploading,
    );

    try {
        VideoDataModel videoTmp = await _videoService.uploadToTmpFolder(
          file,
          _contentController.state.path,
        );
    } catch (e) {}

    // print(fileName);

    // VideoDataModel video = VideoDataModel(
    //   name: fileName,
    //   file: file,
    //   start: 0,
    //   end: 0,
    //   duration: 0,
    // );

    // Ajouter le fichier à la liste avec l'état "uploading"
    // final newFileState = FileUploadState(
    //   key: key!,
    //   file: file,
    //   status: UploadStatus.uploading,
    //   traitementState: TraitementStateEnum.idle,
    // );

    // _videoDataController.addVideo(video);

    // video = video.mergeWith({
    //   'fileState': newFileState,
    // });

    // state = state.copyWith(
    //   files: [...state.files, newFileState],
    // );

    // try {
    //   VideoDataModel videoTmp = await _videoService.uploadToTmpFolder(
    //     file,
    //     _contentController.state.path,
    //   );

    //   VideoDataModel videoInformation = await _videoService.getInformation(
    //     videoTmp,
    //     _contentController.state.path,
    //   );

    //   video = video.mergeWith(videoInformation.toJson());

    //   _videoDataController.updateVideo(video);

    //   print("Uploading video");
    //   print(video.toString());
    // } catch (e) {
    //   _updateVideoStatus(
    //     video,
    //     UploadStatus.uploadFailed,
    //     e.toString(),
    //   );
    // }
  }

  Future<void> completeUpload(
    VideoDataModel video,
  ) async {
    VideoDataModel videoDataModel =
        _videoDataController.getVideoByName(video.name);

    if (videoDataModel.name.isEmpty) {
      throw Exception("Video not found");
    }

    await _videoService.standardizeVideo(
      videoDataModel.name,
      _contentController.state.path,
    );

    print("Complete upload");
    print(videoDataModel.toString());

    _updateVideoStatus(
      video,
      UploadStatus.uploaded,
    );
  }

  void _updateVideoStatus(
    VideoDataModel video,
    UploadStatus status, [
    String? message,
  ]) {
    final updatedFiles = state.files.map((fileState) {
      if (fileState.file == video.file) {
        return fileState.copyWith(
          status: status,
          message: message,
        );
      }

      return fileState;
    }).toList();

    // Mettre à jour l'état global
    state = state.copyWith(files: updatedFiles);
  }
}

final uploadControllerProvider =
    StateNotifierProvider<UploadControllerProvider, UploadStateState>(
  (ref) => UploadControllerProvider(
    VideoService(
      FFMpeg(),
    ),
    ref.read(contentControllerProvider.notifier),
    ref.read(videoDataControllerProvider.notifier),
  ),
);
