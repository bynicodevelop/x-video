import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_video_ai/controllers/notification_controller.dart';
import 'package:x_video_ai/models/state_notification_model.dart';

void main() {
  group('NotificationControllerProvider tests', () {
    late ProviderContainer container;

    setUp(() {
      // Crée un ProviderContainer pour isoler chaque test
      container = ProviderContainer();
    });

    tearDown(() {
      // Libère les ressources à la fin de chaque test
      container.dispose();
    });

    test('Initial state should be empty', () {
      // Teste l'état initial
      final state = container.read(notificationControllerProvider);

      expect(state, StateNotificationModel.empty());
    });

    test('showNotification should update the state with new notification', () {
      // Variables pour le test
      const message = 'Test notification';
      const duration = Duration(seconds: 5);
      const type = NotificationType.success;

      // Appel de la méthode showNotification
      container.read(notificationControllerProvider.notifier).showNotification(
            message,
            duration,
            type,
          );

      // Vérifie que l'état a bien été mis à jour
      final updatedState = container.read(notificationControllerProvider);

      expect(updatedState.message, message);
      expect(updatedState.duration, duration);
      expect(updatedState.type, type);
    });

    test('hideNotification should reset the state to empty', () {
      // Appel de la méthode showNotification
      container.read(notificationControllerProvider.notifier).showNotification(
            'Test notification',
            const Duration(seconds: 5),
            NotificationType.error,
          );

      // Vérifie que l'état n'est pas vide après showNotification
      expect(container.read(notificationControllerProvider).message,
          'Test notification');

      // Appel de la méthode hideNotification
      container
          .read(notificationControllerProvider.notifier)
          .hideNotification();

      // Vérifie que l'état a bien été réinitialisé
      final updatedState = container.read(notificationControllerProvider);

      expect(updatedState, StateNotificationModel.empty());
    });
  });
}
