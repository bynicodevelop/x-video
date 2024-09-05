class OpentAiConfigModel {
  final String apiKey;
  final String model;
  final String voice;
  final String path;
  final String audioFileName;

  OpentAiConfigModel({
    required this.apiKey,
    required this.model,
    this.voice = '',
    this.path = '',
    this.audioFileName = 'audio',
  });
}
