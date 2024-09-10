class VideoInformation {
  final double height;
  final double width;
  final double duration;

  VideoInformation({
    required this.height,
    required this.width,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'height': height,
        'width': width,
        'duration': duration,
      };
}
