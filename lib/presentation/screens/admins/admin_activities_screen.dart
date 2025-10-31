import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/activity_log.dart';
import '../../../core/constants/api_constants.dart';
import '../../providers/admin_provider.dart';

class AdminActivitiesScreen extends StatefulWidget {
  const AdminActivitiesScreen({super.key});

  @override
  State<AdminActivitiesScreen> createState() => _AdminActivitiesScreenState();
}

class _AdminActivitiesScreenState extends State<AdminActivitiesScreen> {
  String? _selectedActivityType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Admin Activities'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter by type',
            onSelected: (value) {
              setState(() {
                _selectedActivityType = value == 'all' ? null : value;
              });
              adminProvider.fetchActivities(activityType: _selectedActivityType);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Activities'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'login',
                child: Text('?? Login'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('?? Logout'),
              ),
              const PopupMenuItem(
                value: 'view_device',
                child: Text('??? View Device'),
              ),
              const PopupMenuItem(
                value: 'view_sms',
                child: Text('?? View SMS'),
              ),
              const PopupMenuItem(
                value: 'send_command',
                child: Text('? Send Command'),
              ),
              const PopupMenuItem(
                value: 'create_admin',
                child: Text('? Create Admin'),
              ),
              const PopupMenuItem(
                value: 'update_admin',
                child: Text('?? Update Admin'),
              ),
              const PopupMenuItem(
                value: 'delete_admin',
                child: Text('??? Delete Admin'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => adminProvider.fetchActivities(
              activityType: _selectedActivityType,
            ),
          ),
        ],
      ),
      body: adminProvider.isLoadingActivities
          ? const Center(child: CircularProgressIndicator())
          : adminProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        adminProvider.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => adminProvider.fetchActivities(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : adminProvider.activities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 64,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text('No activities found'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => adminProvider.fetchActivities(
                        activityType: _selectedActivityType,
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: adminProvider.activities.length,
                        itemBuilder: (context, index) {
                          final activity = adminProvider.activities[index];
                          return _ActivityCard(
                            activity: activity,
                            isDark: isDark,
                          );
                        },
                      ),
                    ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityLog activity;
  final bool isDark;

  const _ActivityCard({
    required this.activity,
    required this.isDark,
  });

  Color _getActivityColor() {
    switch (activity.activityType.toLowerCase()) {
      case 'login':
        return const Color(0xFF10B981);
      case 'logout':
        return const Color(0xFF6B7280);
      case 'send_command':
        return const Color(0xFF6366F1);
      case 'create_admin':
        return const Color(0xFF10B981);
      case 'delete_admin':
        return const Color(0xFFEF4444);
      case 'update_admin':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getActivityIcon() {
    switch (activity.activityType.toLowerCase()) {
      case 'login':
        return Icons.login_rounded;
      case 'logout':
        return Icons.logout_rounded;
      case 'view_device':
        return Icons.visibility_rounded;
      case 'view_sms':
        return Icons.message_rounded;
      case 'send_command':
        return Icons.flash_on_rounded;
      case 'create_admin':
        return Icons.person_add_rounded;
      case 'update_admin':
        return Icons.edit_rounded;
      case 'delete_admin':
        return Icons.person_remove_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !activity.success
              ? const Color(0xFFEF4444).withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getActivityColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getActivityIcon(),
                color: _getActivityColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ActivityType.getDisplayName(activity.activityType),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        activity.timeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoBadge(
                        icon: Icons.person_rounded,
                        label: activity.adminUsername,
                        isDark: isDark,
                      ),
                      if (activity.ipAddress != null)
                        _InfoBadge(
                          icon: Icons.location_on_rounded,
                          label: activity.ipAddress!,
                          isDark: isDark,
                        ),
                      if (activity.deviceId != null)
                        _InfoBadge(
                          icon: Icons.smartphone_rounded,
                          label: activity.deviceId!,
                          isDark: isDark,
                        ),
                      if (!activity.success)
                        _InfoBadge(
                          icon: Icons.error_rounded,
                          label: 'Failed',
                          isDark: isDark,
                          color: const Color(0xFFEF4444),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? (isDark ? Colors.white54 : const Color(0xFF64748B));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? (isDark ? Colors.white : Colors.black)).withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
