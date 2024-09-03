class ProgressStateModel {
  final int currentStep;
  final int totalSteps;
  final String message;
  final double progressPercentage;

  ProgressStateModel({
    required this.currentStep,
    required this.totalSteps,
    required this.message,
    required this.progressPercentage,
  });

  bool get isCompleted => currentStep >= totalSteps;

  ProgressStateModel copyWith({
    int? currentStep,
    int? totalSteps,
    String? message,
    double? progressPercentage,
  }) =>
      ProgressStateModel(
        currentStep: currentStep ?? this.currentStep,
        totalSteps: totalSteps ?? this.totalSteps,
        message: message ?? this.message,
        progressPercentage: progressPercentage ?? this.progressPercentage,
      );
}
