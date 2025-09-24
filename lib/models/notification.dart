import 'api_models.dart';

class NotificationItem {
  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final String time;
  final bool read;
  final int? taskId;
  final String date; // 分组使用的key: today/yesterday/具体日期

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
    this.taskId,
    required this.date,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.info,
      ),
      title: json['title'],
      message: json['message'],
      time: json['time'],
      read: json['read'],
      taskId: json['taskId'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'time': time,
      'read': read,
      'taskId': taskId,
      'date': date,
    };
  }

  NotificationItem copyWith({
    int? id,
    NotificationType? type,
    String? title,
    String? message,
    String? time,
    bool? read,
    int? taskId,
    String? date,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      read: read ?? this.read,
      taskId: taskId ?? this.taskId,
      date: date ?? this.date,
    );
  }

  factory NotificationItem.fromApi(NotificationData data) {
    final createDateTime = data.createTime != null
        ? DateTime.fromMillisecondsSinceEpoch(data.createTime!)
        : DateTime.now();
    final dateKey = _formatDateKey(createDateTime);
    final timeLabel = _formatTimeLabel(createDateTime, dateKey);
    return NotificationItem(
      id: data.id,
      type: _parseNotificationType(data.notificationType),
      title: data.title,
      message: data.body,
      time: timeLabel,
      read: data.alreadyRead,
      taskId: data.taskId,
      date: dateKey,
    );
  }

  String get displayDate {
    switch (date) {
      case 'today':
        return '今天';
      case 'yesterday':
        return '昨天';
      default:
        return date;
    }
  }

  static String _formatDateKey(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = today.difference(target).inDays;

    if (_isSameDay(today, target)) {
      return 'today';
    }
    if (diff == 1) {
      return 'yesterday';
    }
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}';
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _formatTimeLabel(DateTime dateTime, String dateKey) {
    if (dateKey == 'today' || dateKey == 'yesterday') {
      return '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
    }
    return '${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
        return NotificationType.alert;
      case 'success':
        return NotificationType.success;
      case 'info':
      default:
        return NotificationType.info;
    }
  }

  static String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

enum NotificationType {
  info,
  alert,
  success,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.info:
        return '通知';
      case NotificationType.alert:
        return '提醒';
      case NotificationType.success:
        return '完成';
    }
  }
}
