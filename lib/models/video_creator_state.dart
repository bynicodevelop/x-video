class VideoCreatorState {
  final bool hasPrepared;
  final double prepareProgress;
  final bool hasConcatenated;
  final double concatenateProgress;
  final bool hasAddedAudios;
  final double addAudiosProgress;
  final bool hasAddedSubtitles;
  final double addSubtitlesProgress;
  final bool isFinished;

  VideoCreatorState({
    this.hasPrepared = true,
    this.prepareProgress = 0.0,
    this.hasConcatenated = false,
    this.concatenateProgress = 0.0,
    this.hasAddedAudios = false,
    this.addAudiosProgress = 0.0,
    this.hasAddedSubtitles = false,
    this.addSubtitlesProgress = 0.0,
    this.isFinished = false,
  });

  VideoCreatorState mergeWith({
    bool? hasPrepared,
    double? prepareProgress,
    bool? hasConcatenated,
    double? concatenateProgress,
    bool? hasAddedAudios,
    double? addAudiosProgress,
    bool? hasAddedSubtitles,
    double? addSubtitlesProgress,
    bool? isFinished,
  }) {
    return VideoCreatorState(
      hasPrepared: hasPrepared ?? this.hasPrepared,
      prepareProgress: prepareProgress ?? this.prepareProgress,
      hasConcatenated: hasConcatenated ?? this.hasConcatenated,
      concatenateProgress: concatenateProgress ?? this.concatenateProgress,
      hasAddedAudios: hasAddedAudios ?? this.hasAddedAudios,
      addAudiosProgress: addAudiosProgress ?? this.addAudiosProgress,
      hasAddedSubtitles: hasAddedSubtitles ?? this.hasAddedSubtitles,
      addSubtitlesProgress: addSubtitlesProgress ?? this.addSubtitlesProgress,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}
