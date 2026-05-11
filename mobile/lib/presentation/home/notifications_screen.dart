import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          _buildNotificationItem(
            context,
            icon: Icons.local_gas_station,
            iconColor: AppTheme.error,
            title: 'Fuel Price Hike',
            message: 'Nag-anunsyo ang DOE ng pagtaas sa presyo ng petrolyo bukas.',
            time: '2 hours ago',
            isUnread: true,
          ),
          const Divider(height: 1),
          _buildNotificationItem(
            context,
            icon: Icons.shopping_cart,
            iconColor: AppTheme.primary,
            title: 'Rice Price Update',
            message: 'Tinanggal na ang price ceiling sa bigas.',
            time: 'Yesterday',
            isUnread: false,
          ),
          const Divider(height: 1),
          _buildNotificationItem(
            context,
            icon: Icons.directions_bus,
            iconColor: AppTheme.secondary,
            title: 'Transport Update',
            message: 'May mga bagong ruta para sa modern jeepneys.',
            time: 'Oct 12',
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      color: isUnread ? AppTheme.primaryContainer.withOpacity(0.1) : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              time,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.outline),
            ),
          ],
        ),
        trailing: isUnread
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
