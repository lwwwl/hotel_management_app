class TaskListRequest {
  final List<TaskColumnRequest> requireTaskColumnList;
  final int? departmentId;
  final String? priority;

  TaskListRequest({
    required this.requireTaskColumnList,
    this.departmentId,
    this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'requireTaskColumnList': requireTaskColumnList.map((e) => e.toJson()).toList(),
      if (departmentId != null) 'departmentId': departmentId,
      if (priority != null) 'priority': priority,
    };
  }
}

class TaskColumnRequest {
  final String taskStatus;
  final int? lastTaskId;
  final int? lastTaskCreateTime;

  TaskColumnRequest({
    required this.taskStatus,
    this.lastTaskId,
    this.lastTaskCreateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'taskStatus': taskStatus,
      if (lastTaskId != null) 'lastTaskId': lastTaskId,
      if (lastTaskCreateTime != null) 'lastTaskCreateTime': lastTaskCreateTime,
    };
  }
}

class TaskDetailRequest {
  final int taskId;

  TaskDetailRequest({required this.taskId});

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
    };
  }
}

class TaskClaimRequest {
  final int taskId;

  TaskClaimRequest({required this.taskId});

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
    };
  }
}

class TaskChangeStatusRequest {
  final int taskId;
  final String newTaskStatus;

  TaskChangeStatusRequest({
    required this.taskId,
    required this.newTaskStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'newTaskStatus': newTaskStatus,
    };
  }
}
