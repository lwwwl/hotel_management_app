class NotificationItem {
  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final String time;
  final bool read;
  final int? taskId;
  final String date;

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
        orElse: () => NotificationType.task,
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
}

enum NotificationType {
  task,
  urgent,
  completed,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.task:
        return '任务';
      case NotificationType.urgent:
        return '紧急';
      case NotificationType.completed:
        return '完成';
    }
  }
}
