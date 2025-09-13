import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/notification.dart';
import 'task_detail_page.dart';
import 'tasks_page.dart';
import 'settings_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = List.from(MockData.mockNotifications);
    });
  }

  List<NotificationItem> get _todayNotifications {
    return _notifications.where((n) => n.date == 'today').toList();
  }

  List<NotificationItem> get _yesterdayNotifications {
    return _notifications.where((n) => n.date == 'yesterday').toList();
  }

  void _handleNotificationClick(NotificationItem notification) {
    // 标记为已读
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(read: true);
      }
    });

    // 如果有任务ID，跳转到任务详情
    if (notification.taskId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TaskDetailPage(taskId: notification.taskId!),
        ),
      );
    }
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已将所有通知标记为已读'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteNotification(int id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('通知已删除'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _goToTasks() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const TasksPage(),
      ),
    );
  }

  void _goToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('通知中心'),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              '全部已读',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 通知列表
          Expanded(
            child: _notifications.isEmpty
                ? _buildEmptyState()
                : ListView(
                    children: [
                      // 今天的通知
                      if (_todayNotifications.isNotEmpty) ...[
                        _buildSectionHeader('今天'),
                        ..._todayNotifications.map((notification) => _buildNotificationItem(notification)),
                      ],
                      // 昨天的通知
                      if (_yesterdayNotifications.isNotEmpty) ...[
                        _buildSectionHeader('昨天'),
                        ..._yesterdayNotifications.map((notification) => _buildNotificationItem(notification)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Container(
        color: notification.read ? Colors.white : Colors.blue.shade50,
        child: InkWell(
          onTap: () => _handleNotificationClick(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 通知图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // 通知内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            notification.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (notification.taskId != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '查看任务 #${notification.taskId} →',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 未读标识
                if (!notification.read)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无通知',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.assignment_outlined, '任务', false, _goToTasks),
              _buildNavItem(Icons.notifications, '通知', true, () {}),
              _buildNavItem(Icons.settings_outlined, '设置', false, _goToSettings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return Colors.blue;
      case NotificationType.urgent:
        return Colors.orange;
      case NotificationType.completed:
        return Colors.green;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return Icons.assignment_outlined;
      case NotificationType.urgent:
        return Icons.warning_outlined;
      case NotificationType.completed:
        return Icons.check_circle_outline;
    }
  }
}
