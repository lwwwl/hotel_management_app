import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/task_adapter.dart';
import '../services/task_api_service.dart';
import '../utils/task_status_flow.dart';

class TaskDetailPage extends StatefulWidget {
  final int taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  Task? _task;
  final TextEditingController _commentController = TextEditingController();
  bool _showMore = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await TaskApiService.getTaskDetail(widget.taskId);
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _task = TaskAdapter.fromTaskDetailBO(response.data!);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败: $e';
        _isLoading = false;
      });
    }
  }

  /// 认领工单（待处理 -> 进行中）
  Future<void> _claimTask() async {
    if (_task == null) return;
    
    try {
      final response = await TaskApiService.claimTask(_task!.id);
      
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('工单认领成功，状态已更新为进行中'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 重新加载工单详情数据
        await _loadTask();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('认领失败: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('认领失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 变更工单状态
  Future<void> _updateStatus(TaskStatus newStatus) async {
    if (_task == null) return;
    
    try {
      final newStatusValue = TaskStatusFlow.statusToApiValue(newStatus);
      final response = await TaskApiService.changeTaskStatus(_task!.id, newStatusValue);
      
      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == TaskStatus.completed ? '任务已标记为完成！' : '任务状态已更新'),
            backgroundColor: newStatus == TaskStatus.completed ? Colors.green : Colors.blue,
          ),
        );

        // 重新加载工单详情数据
        await _loadTask();

        if (newStatus == TaskStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('状态变更失败: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('状态变更失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _addComment() {
    if (_commentController.text.trim().isEmpty || _task == null) return;

    final newComment = TaskComment(
      id: DateTime.now().millisecondsSinceEpoch,
      author: '李四',
      time: DateTime.now().toString().substring(11, 16),
      text: _commentController.text.trim(),
    );

    setState(() {
      _task = _task!.copyWith(
        comments: [..._task!.comments, newComment],
      );
    });

    _commentController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('备注已添加'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTask,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_task == null) {
      return const Center(
        child: Text('任务不存在'),
      );
    }

    // 确保_task不为null
    final task = _task!;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('任务详情'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showMore = !_showMore;
              });
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          // 任务信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // 房间标签
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '房间 ${task.room}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 优先级标签
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(task.priority).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (task.priority == TaskPriority.urgent) ...[
                                      Icon(
                                        Icons.priority_high,
                                        size: 14,
                                        color: _getPriorityColor(task.priority),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      task.priority.displayName,
                                      style: TextStyle(
                                        color: _getPriorityColor(task.priority),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 状态标签
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.status.displayName,
                                  style: TextStyle(
                                    color: _getStatusColor(task.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 任务标题
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 预计时间
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '预计时间',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.eta,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 任务描述
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // 创建时间
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '创建时间：${task.createdAt}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 对话历史和备注
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 客人对话记录
                  const Text(
                    '客人对话记录',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildChatMessage(
                          '客服 10:25',
                          '您好，有什么可以帮助您的吗？',
                          false,
                        ),
                        const SizedBox(height: 12),
                        _buildChatMessage(
                          null,
                          '我需要2条浴巾和1条面巾，谢谢',
                          true,
                        ),
                        const SizedBox(height: 12),
                        _buildChatMessage(
                          '客服 10:26',
                          '好的，马上为您安排送到房间',
                          false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 处理备注
                  const Text(
                    '处理备注',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 备注列表
                  Expanded(
                    child: task.comments.isEmpty
                        ? Center(
                            child: Text(
                              '暂无备注',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: task.comments.length,
                            itemBuilder: (context, index) {
                              final comment = task.comments[index];
                              return _buildCommentCard(comment);
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  // 添加备注
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: '添加备注...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addComment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('发送'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(task),
    );
  }

  Widget _buildChatMessage(String? sender, String message, bool isUser) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sender != null) ...[
                    Text(
                      sender,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentCard(TaskComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comment.author,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                comment.time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment.text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(Task task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: SafeArea(
        child: task.status == TaskStatus.completed
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      '任务已完成',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  // 待处理状态：显示认领按钮
                  if (TaskStatusFlow.canClaimTask(task.status))
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _claimTask,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('开始处理'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  // 其他状态：显示状态变更按钮
                  if (TaskStatusFlow.canChangeStatus(task.status) && !TaskStatusFlow.canClaimTask(task.status)) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final nextStatus = TaskStatusFlow.getNextStatus(task.status);
                          if (nextStatus != null) {
                            _updateStatus(nextStatus);
                          }
                        },
                        icon: Icon(_getStatusChangeIcon(task.status)),
                        label: Text(TaskStatusFlow.getStatusChangeButtonText(task.status) ?? ''),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TaskStatusFlow.getStatusChangeButtonColor(task.status),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    // 待确认状态：显示返回处理按钮
                    if (task.status == TaskStatus.review) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateStatus(TaskStatus.inProgress),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('返回处理'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.grey;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.review:
        return Colors.purple;
      case TaskStatus.completed:
        return Colors.green;
    }
  }

  IconData _getStatusChangeIcon(TaskStatus status) {
    final nextStatus = TaskStatusFlow.getNextStatus(status);
    if (nextStatus == null) return Icons.error;
    
    switch (nextStatus) {
      case TaskStatus.inProgress:
        return Icons.play_arrow;
      case TaskStatus.review:
        return Icons.visibility;
      case TaskStatus.completed:
        return Icons.check;
      default:
        return Icons.error;
    }
  }

}
