import 'package:flutter/material.dart';

import '../models/notification.dart';
import '../services/notification_api_service.dart';
import 'settings_page.dart';
import 'task_detail_page.dart';
import 'tasks_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  List<NotificationItem> _notifications = [];
  bool _isInitialLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int? _lastNotificationId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchNotifications(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications({bool reset = false}) async {
    if (_isInitialLoading || _isLoadingMore) {
      return;
    }

    if (reset) {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
        _hasMore = true;
        _lastNotificationId = null;
      });
    } else {
      if (!_hasMore) {
        return;
      }
      setState(() {
        _isLoadingMore = true;
        _errorMessage = null;
      });
    }

    final response = await NotificationApiService.getNotificationList(
      lastNotificationId: reset ? null : _lastNotificationId,
    );

    if (!mounted) {
      return;
    }

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      final fetched = data.notifications.map(NotificationItem.fromApi).toList();

      setState(() {
        if (reset) {
          _notifications = fetched;
        } else {
          final existingIds = _notifications.map((e) => e.id).toSet();
          for (final item in fetched) {
            if (!existingIds.contains(item.id)) {
              _notifications.add(item);
            }
          }
        }
        _hasMore = data.hasMore;
        _lastNotificationId = data.lastNotificationId;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = response.error ?? response.message;
      });
    }

    if (!mounted) {
      return;
    }

    setState(() {
      if (reset) {
        _isInitialLoading = false;
      } else {
        _isLoadingMore = false;
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) {
      return;
    }

    final threshold = 200;
    if (_scrollController.position.extentAfter < threshold) {
      _fetchNotifications();
    }
  }

  Future<void> _refreshNotifications() async {
    await _fetchNotifications(reset: true);
  }

  void _handleNotificationClick(NotificationItem notification) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(read: true);
      }
    });

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

  List<_NotificationGroup> _buildNotificationGroups() {
    final Map<String, List<NotificationItem>> grouped = {};
    for (final item in _notifications) {
      grouped.putIfAbsent(item.date, () => []).add(item);
    }

    final List<_NotificationGroup> groups = [];
    if (grouped.containsKey('today')) {
      groups.add(_NotificationGroup('today', grouped['today']!));
    }
    if (grouped.containsKey('yesterday')) {
      groups.add(_NotificationGroup('yesterday', grouped['yesterday']!));
    }

    final otherKeys = grouped.keys
        .where((key) => key != 'today' && key != 'yesterday')
        .toList()
      ..sort((a, b) => b.compareTo(a));
    for (final key in otherKeys) {
      groups.add(_NotificationGroup(key, grouped[key]!));
    }

    return groups;
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
            onPressed: _notifications.isEmpty ? null : _markAllAsRead,
            child: Text(
              '全部已读',
              style: TextStyle(
                color: _notifications.isEmpty ? Colors.white60 : Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: _buildNotificationContent(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildNotificationContent() {
    if (_isInitialLoading && _notifications.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null && _notifications.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage ?? '加载失败',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _fetchNotifications(reset: true),
                    child: const Text('重新加载'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300,
            child: _buildEmptyState(),
          ),
        ],
      );
    }

    final groups = _buildNotificationGroups();
    final List<Widget> children = [];
    for (final group in groups) {
      children.add(_buildSectionHeader(group.dateKey));
      children.addAll(group.items.map((notification) => _buildNotificationItem(notification)));
    }

    if (_isLoadingMore) {
      children.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    } else if (!_hasMore) {
      children.add(const SizedBox(height: 24));
    }

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      children: children,
    );
  }

  Widget _buildSectionHeader(String dateKey) {
    final displayTitle = _resolveDisplayDate(dateKey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: Text(
        displayTitle,
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
      case NotificationType.alert:
        return Colors.orange;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.info:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return Icons.warning_outlined;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.info:
        return Icons.notifications_none;
    }
  }
}

class _NotificationGroup {
  final String dateKey;
  final List<NotificationItem> items;

  _NotificationGroup(this.dateKey, this.items);
}

String _resolveDisplayDate(String dateKey) {
  switch (dateKey) {
    case 'today':
      return '今天';
    case 'yesterday':
      return '昨天';
    default:
      return dateKey;
  }
}
