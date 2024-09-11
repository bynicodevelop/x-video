import 'dart:async';
import 'dart:convert';
import 'dart:io';

class FileGateway {
  FileWrapper getFile(String path) {
    final File file = File(path);
    return _FileWrapperImpl(file);
  }

  Future<void> createDirectory(String path) async {
    final Directory dir = Directory(path);

    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
  }

  DirectoryWrapper getDirectory(String path) {
    final Directory dir = Directory(path);
    return _DirectoryWrapperImpl(dir);
  }
}

abstract class FileWrapper {
  String readAsStringSync();
  void writeAsStringSync(String contents);
  bool existsSync();
  void createSync({bool recursive = false});
  Future<bool> exists();
  Future<String> readAsString({Encoding encoding = utf8});
  Future<File> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  });
  String get path;
}

abstract class DirectoryWrapper {
  DirectoryWrapper(String s);

  List<FileSystemEntity> listSync();
  String get path;
}

class _FileWrapperImpl implements FileWrapper {
  final File _file;

  _FileWrapperImpl(this._file);

  @override
  String readAsStringSync() => _file.readAsStringSync();

  @override
  void writeAsStringSync(String contents) => _file.writeAsStringSync(contents);

  @override
  bool existsSync() => _file.existsSync();

  @override
  void createSync({bool recursive = false}) =>
      _file.createSync(recursive: recursive);

  @override
  Future<bool> exists() async => _file.exists();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      _file.readAsString(encoding: encoding);

  @override
  Future<File> writeAsString(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) =>
      _file.writeAsString(contents,
          mode: mode, encoding: encoding, flush: flush);

  @override
  String get path => _file.path;
}

class _DirectoryWrapperImpl implements DirectoryWrapper {
  final Directory _directory;

  _DirectoryWrapperImpl(this._directory);

  @override
  List<FileSystemEntity> listSync() => _directory.listSync();

  @override
  String get path => _directory.path;
}
