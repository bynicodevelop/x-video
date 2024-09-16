enum NotificationType {
  success,
  error,
}

class StateNotificationModel {
  final String message;
  final Duration duration;
  final NotificationType type;

  const StateNotificationModel({
    required this.message,
    required this.duration,
    this.type = NotificationType.success,
  });

  factory StateNotificationModel.empty() {
    return const StateNotificationModel(
      message: '',
      duration: Duration.zero,
    );
  }
}
