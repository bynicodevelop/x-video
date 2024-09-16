import 'package:flutter/material.dart';
import 'package:x_video_ai/models/state_notification_model.dart';

class SlideTransitionWidget extends StatefulWidget {
  final Widget child;

  const SlideTransitionWidget({super.key, required this.child});

  @override
  SlideTransitionWidgetState createState() => SlideTransitionWidgetState();
}

class SlideTransitionWidgetState extends State<SlideTransitionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}

void showNotification(
  BuildContext context,
  String message,
  NotificationType type, {
  Duration? duration,
}) {
  // Vérifie si une notification est déjà affichée
  if (Overlay.of(context).context.findAncestorWidgetOfExactType<Overlay>() !=
      null) {
    // Optionnel : Vous pouvez décider de ne pas afficher une nouvelle notification
    // si une est déjà présente, ou de la remplacer.
    return;
  }

  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: SlideTransitionWidget(
          child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.up,
            onDismissed: (_) => overlayEntry.remove(),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 4,
              ),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    type == NotificationType.success
                        ? Icons.check
                        : Icons.error_outline,
                    color: type == NotificationType.success
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // TODO: translate
                          type == NotificationType.success
                              ? 'Succès'
                              : 'Erreur',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      overlayEntry.remove();
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  Future.delayed(duration ?? const Duration(seconds: 3), () {
    if (overlayEntry.mounted) overlayEntry.remove();
  });
}
