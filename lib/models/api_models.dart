class TaskListColumnBO {
  final String taskStatus;
  final String taskStatusDisplayName;
  final int taskCount;
  final List<TaskListItemBO> tasks;

  TaskListColumnBO({
    required this.taskStatus,
    required this.taskStatusDisplayName,
    required this.taskCount,
    required this.tasks,
  });

  factory TaskListColumnBO.fromJson(Map<String, dynamic> json) {
    return TaskListColumnBO(
      taskStatus: json['taskStatus'] ?? '',
      taskStatusDisplayName: json['taskStatusDisplayName'] ?? '',
      taskCount: json['taskCount'] ?? 0,
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((e) => TaskListItemBO.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskStatus': taskStatus,
      'taskStatusDisplayName': taskStatusDisplayName,
      'taskCount': taskCount,
      'tasks': tasks.map((e) => e.toJson()).toList(),
    };
  }
}

class TaskListItemBO {
  final int taskId;
  final String title;
  final String description;
  final int? roomId;
  final String? roomName;
  final int? guestId;
  final String? guestName;
  final int? deptId;
  final String? deptName;
  final String taskStatus;
  final String taskStatusDisplayName;
  final String priority;
  final String priorityDisplayName;
  final int createTime;
  final int updateTime;
  final int? deadlineTime;
  final int? completeTime;

  TaskListItemBO({
    required this.taskId,
    required this.title,
    required this.description,
    this.roomId,
    this.roomName,
    this.guestId,
    this.guestName,
    this.deptId,
    this.deptName,
    required this.taskStatus,
    required this.taskStatusDisplayName,
    required this.priority,
    required this.priorityDisplayName,
    required this.createTime,
    required this.updateTime,
    this.deadlineTime,
    this.completeTime,
  });

  factory TaskListItemBO.fromJson(Map<String, dynamic> json) {
    return TaskListItemBO(
      taskId: json['taskId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      roomId: json['roomId'],
      roomName: json['roomName'],
      guestId: json['guestId'],
      guestName: json['guestName'],
      deptId: json['deptId'],
      deptName: json['deptName'],
      taskStatus: json['taskStatus'] ?? '',
      taskStatusDisplayName: json['taskStatusDisplayName'] ?? '',
      priority: json['priority'] ?? '',
      priorityDisplayName: json['priorityDisplayName'] ?? '',
      createTime: json['createTime'] ?? 0,
      updateTime: json['updateTime'] ?? 0,
      deadlineTime: json['deadlineTime'],
      completeTime: json['completeTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'title': title,
      'description': description,
      if (roomId != null) 'roomId': roomId,
      if (roomName != null) 'roomName': roomName,
      if (guestId != null) 'guestId': guestId,
      if (guestName != null) 'guestName': guestName,
      if (deptId != null) 'deptId': deptId,
      if (deptName != null) 'deptName': deptName,
      'taskStatus': taskStatus,
      'taskStatusDisplayName': taskStatusDisplayName,
      'priority': priority,
      'priorityDisplayName': priorityDisplayName,
      'createTime': createTime,
      'updateTime': updateTime,
      if (deadlineTime != null) 'deadlineTime': deadlineTime,
      if (completeTime != null) 'completeTime': completeTime,
    };
  }
}

class TaskDetailBO {
  final int taskId;
  final String title;
  final String description;
  final int? roomId;
  final String? roomName;
  final int? guestId;
  final String? guestName;
  final int? deptId;
  final String? deptName;
  final int? creatorUserId;
  final String? creatorName;
  final int? executorUserId;
  final String? executorName;
  final int? conversationId;
  final String? conversationName;
  final int? deadlineTime;
  final int? completeTime;
  final String priority;
  final String priorityDisplayName;
  final String taskStatus;
  final String taskStatusDisplayName;
  final int createTime;
  final int updateTime;

  TaskDetailBO({
    required this.taskId,
    required this.title,
    required this.description,
    this.roomId,
    this.roomName,
    this.guestId,
    this.guestName,
    this.deptId,
    this.deptName,
    this.creatorUserId,
    this.creatorName,
    this.executorUserId,
    this.executorName,
    this.conversationId,
    this.conversationName,
    this.deadlineTime,
    this.completeTime,
    required this.priority,
    required this.priorityDisplayName,
    required this.taskStatus,
    required this.taskStatusDisplayName,
    required this.createTime,
    required this.updateTime,
  });

  factory TaskDetailBO.fromJson(Map<String, dynamic> json) {
    return TaskDetailBO(
      taskId: json['taskId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      roomId: json['roomId'],
      roomName: json['roomName'],
      guestId: json['guestId'],
      guestName: json['guestName'],
      deptId: json['deptId'],
      deptName: json['deptName'],
      creatorUserId: json['creatorUserId'],
      creatorName: json['creatorName'],
      executorUserId: json['executorUserId'],
      executorName: json['executorName'],
      conversationId: json['conversationId'],
      conversationName: json['conversationName'],
      deadlineTime: json['deadlineTime'],
      completeTime: json['completeTime'],
      priority: json['priority'] ?? '',
      priorityDisplayName: json['priorityDisplayName'] ?? '',
      taskStatus: json['taskStatus'] ?? '',
      taskStatusDisplayName: json['taskStatusDisplayName'] ?? '',
      createTime: json['createTime'] ?? 0,
      updateTime: json['updateTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'title': title,
      'description': description,
      if (roomId != null) 'roomId': roomId,
      if (roomName != null) 'roomName': roomName,
      if (guestId != null) 'guestId': guestId,
      if (guestName != null) 'guestName': guestName,
      if (deptId != null) 'deptId': deptId,
      if (deptName != null) 'deptName': deptName,
      if (creatorUserId != null) 'creatorUserId': creatorUserId,
      if (creatorName != null) 'creatorName': creatorName,
      if (executorUserId != null) 'executorUserId': executorUserId,
      if (executorName != null) 'executorName': executorName,
      if (conversationId != null) 'conversationId': conversationId,
      if (conversationName != null) 'conversationName': conversationName,
      if (deadlineTime != null) 'deadlineTime': deadlineTime,
      if (completeTime != null) 'completeTime': completeTime,
      'priority': priority,
      'priorityDisplayName': priorityDisplayName,
      'taskStatus': taskStatus,
      'taskStatusDisplayName': taskStatusDisplayName,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }
}
