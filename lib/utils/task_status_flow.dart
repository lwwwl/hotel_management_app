import 'package:flutter/material.dart';
import '../models/task.dart';

/// 工单状态流转工具类
class TaskStatusFlow {
  /// 状态流转顺序
  static const List<TaskStatus> _statusFlow = [
    TaskStatus.pending,      // 待处理
    TaskStatus.inProgress,   // 进行中
    TaskStatus.review,       // 待确认
    TaskStatus.completed,    // 已完成
  ];

  /// 获取当前状态的下一个状态
  /// 如果已经是最后一个状态，返回null
  static TaskStatus? getNextStatus(TaskStatus currentStatus) {
    final currentIndex = _statusFlow.indexOf(currentStatus);
    if (currentIndex == -1 || currentIndex >= _statusFlow.length - 1) {
      return null; // 已经是最后一个状态或状态无效
    }
    return _statusFlow[currentIndex + 1];
  }

  /// 获取下一个状态的API值
  /// 如果已经是最后一个状态，返回null
  static String? getNextStatusValue(TaskStatus currentStatus) {
    final nextStatus = getNextStatus(currentStatus);
    if (nextStatus == null) return null;
    
    return statusToApiValue(nextStatus);
  }

  /// 将TaskStatus枚举转换为API状态值
  static String statusToApiValue(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.review:
        return 'review';
      case TaskStatus.completed:
        return 'completed';
    }
  }

  /// 检查是否可以执行状态变更
  /// 只有待处理、进行中、待确认状态可以变更
  static bool canChangeStatus(TaskStatus currentStatus) {
    return currentStatus != TaskStatus.completed;
  }

  /// 检查是否可以认领工单
  /// 只有待处理状态可以认领
  static bool canClaimTask(TaskStatus currentStatus) {
    return currentStatus == TaskStatus.pending;
  }

  /// 获取状态变更按钮的文本
  static String? getStatusChangeButtonText(TaskStatus currentStatus) {
    final nextStatus = getNextStatus(currentStatus);
    if (nextStatus == null) return null;
    
    switch (nextStatus) {
      case TaskStatus.inProgress:
        return '开始处理';
      case TaskStatus.review:
        return '提交审核';
      case TaskStatus.completed:
        return '确认完成';
      default:
        return null;
    }
  }

  /// 获取状态变更按钮的颜色
  static Color getStatusChangeButtonColor(TaskStatus currentStatus) {
    final nextStatus = getNextStatus(currentStatus);
    if (nextStatus == null) return Colors.grey;
    
    switch (nextStatus) {
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.review:
        return Colors.purple;
      case TaskStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
