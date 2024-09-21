import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/controllers/content_controller.dart';
import 'package:x_video_ai/gateway/ffmpeg.dart';
import 'package:x_video_ai/gateway/file_getaway.dart';
import 'package:x_video_ai/models/video_information.dart';
import 'package:x_video_ai/models/video_model.dart';
import 'package:x_video_ai/models/video_section_model.dart';
import 'package:x_video_ai/services/video_service.dart';
import 'package:x_video_ai/utils/generate_md5_name.dart';

enum VignetteReaderStatus {
  idle,
  uploading,
  uploaded,
  error,
}

class VignetteReaderState {
  final VideoSectionModel section;
  final VideoDataModel? videoDataModel;
  final VignetteReaderStatus status;

  VignetteReaderState({
    required this.section,
    this.videoDataModel,
    this.status = VignetteReaderStatus.idle,
  });

  VignetteReaderState mergeWith({
    VideoSectionModel? section,
    VideoDataModel? videoDataModel,
    VignetteReaderStatus? status,
  }) {
    return VignetteReaderState(
      section: section ?? this.section,
      videoDataModel: videoDataModel ?? this.videoDataModel,
      status: status ?? this.status,
    );
  }

  VignetteReaderState reset() {
    return VignetteReaderState(
      section: section,
      status: VignetteReaderStatus.idle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section': section.toJson(),
      'videoDataModel': videoDataModel?.toJson(),
      'status': status.toString(),
    };
  }
}

class VignetteReaderControllerProvider
    extends StateNotifier<List<VignetteReaderState?>> {
  final VideoService _videoService;
  final ContentController _contentController;

  VignetteReaderControllerProvider(
    VideoService videoService,
    ContentController contentController,
  )   : _videoService = videoService,
        _contentController = contentController,
        super([]);

  Future<void> initState(
    VideoSectionModel section,
  ) async {
    state = [
      ...state,
      VignetteReaderState(
        section: section,
      ),
    ];
  }

  Future<void> addVideoDataModel(
    VideoSectionModel section,
    XFile file,
  ) async {
    final VignetteReaderState? vignetteReaderState = state.firstWhere(
      (element) => element?.section.id == section.id,
      orElse: () => null,
    );

    if (vignetteReaderState == null) {
      throw Exception('VignetteReaderState not found');
    }

    final String name = await generateMD5Name(file);

    final videoDataModel = VideoDataModel(
      name: name,
      file: file,
      start: 0,
      end: 0,
      duration: 0,
    );

    state = state.map((e) {
      if (e?.section.id == section.id) {
        return e?.mergeWith(
          videoDataModel: videoDataModel,
          status: VignetteReaderStatus.uploading,
        );
      }

      return e;
    }).toList();
  }

  Future<void> upload(
    VignetteReaderState section,
  ) async {
    final VignetteReaderState? vignetteReaderState = state.firstWhere(
      (element) => element?.section.id == section.section.id,
      orElse: () => null,
    );

    if (vignetteReaderState == null) {
      throw Exception('VignetteReaderState not found');
    }

    final VideoDataModel? videoDataModel = vignetteReaderState.videoDataModel;

    if (videoDataModel == null) {
      throw Exception('VideoDataModel not found');
    }

    final String projectPath = _contentController.state.path;

    final VideoDataModel tmpVideoDateModel =
        await _videoService.uploadToTmpFolder(
      videoDataModel,
      projectPath,
    );

    final VideoDataModel standardizeVideoDataModel =
        await _videoService.standardizeVideo(
      tmpVideoDateModel,
      projectPath,
    );

    final VideoInformation videoInformation =
        await _videoService.getInformation(standardizeVideoDataModel.file!);

    VideoDataModel videoDataModelWithInfos =
        standardizeVideoDataModel.mergeWith({
      'duration': videoInformation.duration,
    });

    state = state.map((e) {
      if (e?.section.id == section.section.id) {
        return e?.mergeWith(
          videoDataModel: videoDataModelWithInfos,
          status: VignetteReaderStatus.uploaded,
        );
      }

      return e;
    }).toList();
  }

  void updateVideoSectionModel(
    VideoSectionModel section,
  ) {
    state = state.map((e) {
      if (e?.section.id == section.id) {
        return e?.mergeWith(
          section: section,
        );
      }

      return e;
    }).toList();
  }

  void resetVignetteReaderState(
    VignetteReaderState vignetteReaderState,
  ) {
    state = state.map((e) {
      if (e?.section.id == vignetteReaderState.section.id) {
        return e?.reset();
      }

      return e;
    }).toList();
  }
}

final vignetteReaderControllerProvider = StateNotifierProvider<
    VignetteReaderControllerProvider, List<VignetteReaderState?>>(
  (ref) {
    return VignetteReaderControllerProvider(
      VideoService(
        FileGateway(),
        FFMpeg(),
      ),
      ref.watch(contentControllerProvider.notifier),
    );
  },
);
