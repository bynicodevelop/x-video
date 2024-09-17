import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:x_video_ai/controllers/video_creator_controller.dart';

class VideoCreatorEditorScreen extends ConsumerStatefulWidget {
  const VideoCreatorEditorScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VideoCreatorEditorScreenState();
}

class _VideoCreatorEditorScreenState
    extends ConsumerState<VideoCreatorEditorScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => ref.read(videoCreatorControllerProvider.notifier).startWorkflow(),
    );
  }

  ListTile _item(
    String label,
    IconData icon,
    bool active, {
    double? progress,
  }) =>
      ListTile(
        leading: Icon(
          icon,
          color: progress == 1
              ? Theme.of(context).primaryColor
              : Colors.grey.shade400,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: active ? Colors.grey.shade800 : Colors.grey.shade400,
          ),
        ),
        // Progress bar
        subtitle: progress != null
            ? LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              )
            : null,
      );

  @override
  Widget build(BuildContext context) {
    ref.watch(videoCreatorControllerProvider);

    final videoCreatorController =
        ref.read(videoCreatorControllerProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          // center from widget width
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 3,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              _item(
                'Prepare Video Data',
                Icons.video_settings_outlined,
                videoCreatorController.hasPrepared,
                progress: videoCreatorController.prepareProgress,
              ),
              _item(
                'Concatenate Videos',
                Icons.merge_outlined,
                videoCreatorController.hasConcatenated,
                progress: videoCreatorController.concatenateProgress,
              ),
              _item(
                'Add Audio',
                Icons.music_video_outlined,
                videoCreatorController.hasAddedAudios,
                progress: videoCreatorController.addAudiosProgress,
              ),
              _item(
                'Add subtitle Screen',
                Icons.subtitles,
                videoCreatorController.hasAddedSubtitles,
                progress: videoCreatorController.addSubtitlesProgress,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: videoCreatorController.isFinished
              ? () async {
                  final String folderPath =
                      videoCreatorController.getFinalVideoPath();
                  final Uri folderUri = Uri.file(folderPath, windows: true);

                  if (await canLaunchUrl(folderUri)) {
                    await launchUrl(folderUri);
                  } else {
                    throw 'Could not open the folder: $folderPath';
                  }
                }
              : null,
          // TODO : Add Translation
          child: const Text('Open Final Video Folder'),
        ),
      ],
    );
  }
}
