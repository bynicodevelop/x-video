import 'dart:io';

@Deprecated('Use FileGateway instead')
class FileService {
  Future<void> createDirectory(String path) async {
    final Directory dir = Directory(path);
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
  }

  // TODO: Création de fichier
  // TODO: Suppression de fichier
}
