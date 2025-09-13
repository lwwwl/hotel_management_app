import '../models/task.dart';
import '../models/notification.dart';
import '../models/user.dart';

class MockData {
  static final List<Task> mockTasks = [
    Task(
      id: 1,
      room: '101',
      title: '需要额外毛巾',
      description: '客人要求送2条浴巾和1条面巾',
      status: TaskStatus.pending,
      priority: TaskPriority.high,
      eta: '5分钟',
      createdTime: '10:30',
      createdAt: '2024-01-01 10:30',
      comments: [
        TaskComment(
          id: 1,
          author: '张三',
          time: '10:35',
          text: '已准备好毛巾，准备送往房间',
        ),
      ],
    ),
    Task(
      id: 2,
      room: '208',
      title: '房间清洁',
      description: '客人外出，要求打扫房间并更换床单',
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
      eta: '15分钟',
      createdTime: '10:25',
      createdAt: '2024-01-01 10:25',
      comments: [],
    ),
    Task(
      id: 3,
      room: '305',
      title: '空调维修',
      description: '空调制冷效果不好，需要检查',
      status: TaskStatus.pending,
      priority: TaskPriority.high,
      eta: '10分钟',
      createdTime: '10:20',
      createdAt: '2024-01-01 10:20',
      comments: [],
    ),
    Task(
      id: 4,
      room: '412',
      title: '送餐服务',
      description: '早餐：美式咖啡×2，三明治×2',
      status: TaskStatus.completed,
      priority: TaskPriority.low,
      eta: '-',
      createdTime: '09:45',
      createdAt: '2024-01-01 09:45',
      comments: [],
    ),
  ];

  static final List<NotificationItem> mockNotifications = [
    NotificationItem(
      id: 1,
      type: NotificationType.task,
      title: '新任务分配',
      message: '房间101需要额外毛巾',
      time: '10:30',
      read: false,
      taskId: 1,
      date: 'today',
    ),
    NotificationItem(
      id: 2,
      type: NotificationType.urgent,
      title: '紧急任务',
      message: '房间305空调故障，请尽快处理',
      time: '10:25',
      read: false,
      taskId: 3,
      date: 'today',
    ),
    NotificationItem(
      id: 3,
      type: NotificationType.completed,
      title: '任务完成',
      message: '房间208清洁任务已完成',
      time: '09:45',
      read: true,
      taskId: 2,
      date: 'today',
    ),
    NotificationItem(
      id: 4,
      type: NotificationType.task,
      title: '任务更新',
      message: '房间412送餐任务已分配给您',
      time: '昨天 18:30',
      read: true,
      taskId: 4,
      date: 'yesterday',
    ),
    NotificationItem(
      id: 5,
      type: NotificationType.task,
      title: '系统通知',
      message: '本月绩效报告已生成',
      time: '昨天 17:00',
      read: true,
      date: 'yesterday',
    ),
  ];

  static final List<User> mockUsers = [
    User(
      id: 'staff001',
      username: 'staff001',
      password: '123456',
      name: '张三',
      role: '客房服务部',
      email: 'zhangsan@hotel.com',
      phone: '13800138001',
    ),
    User(
      id: 'admin',
      username: 'admin',
      password: 'admin123',
      name: '管理员',
      role: '系统管理员',
      email: 'admin@hotel.com',
      phone: '13800138002',
    ),
  ];

  static UserSettings defaultSettings = UserSettings(
    language: 'zh-CN',
    notificationsEnabled: true,
    cacheSize: '12.5 MB',
  );
}
