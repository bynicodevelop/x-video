import 'dart:convert';
import 'dart:io';

import 'package:x_video_ai/services/abstracts/json_deserializable.dart';

class ConfigService<T extends JsonDeserializable<T>> {
  String? _path;
  String? _name;
  T? _model;
  bool _isLoaded = false;

  ConfigService({
    String? path,
    String? name,
    T? model,
  })  : _path = path,
        _name = name,
        _model = model;

  T? get model => _model;
  bool get isLoaded => _isLoaded;

  Future<ConfigService<T>> createConfiguration() async {
    _isLoaded = true;

    if (_path == null || _name == null || _model == null) {
      throw Exception('Path or name not defined');
    }

    final Directory directory = Directory(_path!);

    if (!await directory.exists()) {
      await directory.create(
        recursive: true,
      );
    }

    final File fileConfig = File(
      '$_path/$_name',
    );

    if (!fileConfig.existsSync()) {
      fileConfig.writeAsStringSync(
        jsonEncode(_model!.toJson()),
      );
    }

    _isLoaded = false;

    return this;
  }

  Future<ConfigService<T>> loadConfiguration(
    String path,
    T model, {
    String name = 'config.json',
  }) async {
    _isLoaded = true;

    final File fileConfig = File(
      '$path/$name',
    );

    if (!fileConfig.existsSync()) {
      throw Exception('Config file not found');
    }

    final String content = fileConfig.readAsStringSync();
    final Map<String, dynamic> json = jsonDecode(content);

    _name = name;
    _path = path;
    _model = model.fromJson(json);

    _isLoaded = false;

    return this;
  }

  Future<ConfigService<T>> updateConfiguration(
    String key,
    dynamic value,
  ) async {
    _isLoaded = true;

    if (_path == null || _name == null || _model == null) {
      throw Exception('Path, name, or model not defined');
    }

    final File fileConfig = File('$_path/$_name');

    if (!await fileConfig.exists()) {
      throw Exception('Config file not found');
    }

    try {
      final String content = await fileConfig.readAsString();
      final Map<String, dynamic> json = jsonDecode(content);

      json[key] = value;

      await fileConfig.writeAsString(jsonEncode(json));

      _model = _model!.fromJson(json);
    } catch (e) {
      throw Exception('Failed to update configuration: $e');
    } finally {
      _isLoaded = false;
    }

    return this;
  }

  ConfigService<T> copyWith({
    String? path,
    String? name,
    T? model,
    bool? isLoaded,
  }) {
    return ConfigService<T>(
      path: path ?? _path,
      name: name ?? _name,
      model: model ?? _model,
    );
  }
}
