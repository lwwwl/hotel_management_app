class Task {
  final int id;
  final String room;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String eta;
  final String createdTime;
  final String createdAt;
  final List<TaskComment> comments;

  Task({
    required this.id,
    required this.room,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.eta,
    required this.createdTime,
    required this.createdAt,
    this.comments = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      room: json['room'],
      title: json['title'],
      description: json['description'],
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      eta: json['eta'],
      createdTime: json['createdTime'],
      createdAt: json['createdAt'],
      comments: (json['comments'] as List<dynamic>?)
          ?.map((comment) => TaskComment.fromJson(comment))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room': room,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'eta': eta,
      'createdTime': createdTime,
      'createdAt': createdAt,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  Task copyWith({
    int? id,
    String? room,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? eta,
    String? createdTime,
    String? createdAt,
    List<TaskComment>? comments,
  }) {
    return Task(
      id: id ?? this.id,
      room: room ?? this.room,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      eta: eta ?? this.eta,
      createdTime: createdTime ?? this.createdTime,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
    );
  }
}

class TaskComment {
  final int id;
  final String author;
  final String time;
  final String text;

  TaskComment({
    required this.id,
    required this.author,
    required this.time,
    required this.text,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'],
      author: json['author'],
      time: json['time'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'time': time,
      'text': text,
    };
  }
}

enum TaskStatus {
  pending,
  inProgress,
  review,
  completed,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return '待处理';
      case TaskStatus.inProgress:
        return '进行中';
      case TaskStatus.review:
        return '待确认';
      case TaskStatus.completed:
        return '已完成';
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return '低';
      case TaskPriority.medium:
        return '中';
      case TaskPriority.high:
        return '高';
      case TaskPriority.urgent:
        return '紧急';
    }
  }
}
