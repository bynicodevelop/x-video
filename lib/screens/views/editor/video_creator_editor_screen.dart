import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoCreatorEditorScreen extends ConsumerStatefulWidget {
  const VideoCreatorEditorScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VideoCreatorEditorScreenState();
}

class _VideoCreatorEditorScreenState
    extends ConsumerState<VideoCreatorEditorScreen> {
  @override
  Widget build(BuildContext context) {
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
              ListTile(
                leading: Icon(
                  Icons.video_settings_outlined,
                  color: Colors.green.shade600,
                ),
                title: Text(
                  'Prepare Video Screen',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.music_video_outlined,
                  color: Colors.grey.shade400,
                ),
                title: Text(
                  'Associate Video and Audio Screen',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.subtitles,
                  color: Colors.grey.shade400,
                ),
                title: Text(
                  'Add subtitle Screen',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.high_quality_outlined,
                  color: Colors.grey.shade400,
                ),
                title: Text(
                  'Option Screen',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
