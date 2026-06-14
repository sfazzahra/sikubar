import 'package:flutter/material.dart';
import 'notification_service.dart';


class NotificationBadgeIcon extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;

  const NotificationBadgeIcon({
    super.key,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationService.instance,
      builder: (context, _) {
        final count = NotificationService.instance.unreadCount;
        return GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_outlined, color: iconColor, size: 26),
                if (count > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: _BadgeDot(count: count),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Badge dot merah dengan angka
class _BadgeDot extends StatelessWidget {
  final int count;
  const _BadgeDot({required this.count});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Versi sederhana — hanya titik merah tanpa angka
class NotificationDot extends StatelessWidget {
  const NotificationDot({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationService.instance,
      builder: (context, _) {
        if (!NotificationService.instance.hasUnread) {
          return const SizedBox.shrink();
        }
        return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Untuk BottomNavigationBar — wrap icon dengan badge
class BottomNavNotificationIcon extends StatelessWidget {
  final IconData icon;
  const BottomNavNotificationIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationService.instance,
      builder: (context, _) {
        final count = NotificationService.instance.unreadCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon),
            if (count > 0)
              Positioned(
                top: -4,
                right: -6,
                child: _BadgeDot(count: count),
              ),
          ],
        );
      },
    );
  }
}