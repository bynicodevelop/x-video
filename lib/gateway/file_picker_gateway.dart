import 'package:file_picker/file_picker.dart';
import 'package:x_video_ai/gateway/path_gateway.dart';

class FilePickerGateway {
  static Future<String?> openFolder({String? folder}) async {
    return await FilePicker.platform.getDirectoryPath(
      initialDirectory: (await PathGateway.documents)?.path ?? folder,
    );
  }
}
