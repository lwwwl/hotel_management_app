import 'task.dart';
import 'api_models.dart';

class TaskAdapter {
  /// 将API的TaskListItemBO转换为现有的Task模型
  static Task fromTaskListItemBO(TaskListItemBO item) {
    return Task(
      id: item.taskId,
      room: item.roomName ?? item.roomId?.toString() ?? '未知',
      title: item.title,
      description: item.description,
      status: _mapTaskStatus(item.taskStatus),
      priority: _mapTaskPriority(item.priority),
      eta: _getTimeDisplay(item.taskStatus, item.deadlineTime, item.completeTime),
      createdTime: _formatTime(item.createTime),
      createdAt: _formatDateTime(item.createTime),
      comments: [], // API列表项不包含评论，详情页会单独获取
    );
  }

  /// 将API的TaskDetailBO转换为现有的Task模型
  static Task fromTaskDetailBO(TaskDetailBO detail) {
    return Task(
      id: detail.taskId,
      room: detail.roomName ?? detail.roomId?.toString() ?? '未知',
      title: detail.title,
      description: detail.description,
      status: _mapTaskStatus(detail.taskStatus),
      priority: _mapTaskPriority(detail.priority),
      eta: _getTimeDisplay(detail.taskStatus, detail.deadlineTime, detail.completeTime),
      createdTime: _formatTime(detail.createTime),
      createdAt: _formatDateTime(detail.createTime),
      comments: [], // 暂时保持空，后续可以扩展
    );
  }

  /// 映射API状态到现有枚举
  static TaskStatus _mapTaskStatus(String status) {
    switch (status) {
      case 'pending':
        return TaskStatus.pending;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'review':
        return TaskStatus.review;
      case 'completed':
        return TaskStatus.completed;
      default:
        return TaskStatus.pending;
    }
  }

  /// 映射API优先级到现有枚举
  static TaskPriority _mapTaskPriority(String priority) {
    switch (priority) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  /// 根据工单状态获取时间显示
  static String _getTimeDisplay(String taskStatus, int? deadlineTime, int? completeTime) {
    if (taskStatus == 'completed') {
      // 已完成状态：显示完成时间
      if (completeTime != null) {
        return '完成于 ${_formatDateTime(completeTime)}';
      } else {
        return '已完成';
      }
    } else {
      // 非已完成状态：显示截止时间
      if (deadlineTime != null) {
        return '截止 ${_formatDateTime(deadlineTime)}';
      } else {
        return '无截止时间';
      }
    }
  }

  /// 格式化时间戳为时间字符串
  static String _formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化时间戳为日期时间字符串
  static String _formatDateTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
