import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_video_ai/models/state_notification_model.dart';

class NotificationControllerProvider extends StateNotifier<StateNotificationModel> {
  NotificationControllerProvider() : super(StateNotificationModel.empty());

  void showNotification(
    String message,
    Duration duration,
    NotificationType type,
  ) {
    state = StateNotificationModel(
      message: message,
      duration: duration,
      type: type,
    );
  }

  void hideNotification() {
    state = StateNotificationModel.empty();
  }
}

final notificationControllerProvider =
    StateNotifierProvider<NotificationControllerProvider, StateNotificationModel>(
  (ref) => NotificationControllerProvider(),
);
