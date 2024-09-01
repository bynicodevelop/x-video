import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PathGateway {
  static Future<Directory> get application async {
    return getApplicationSupportDirectory();
  }

  static Future<Directory?> get download async {
    return getDownloadsDirectory();
  }

  static Future<Directory?> get documents async {
    return getApplicationDocumentsDirectory();
  }
}
