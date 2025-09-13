# 酒店管理系统 - 员工端APP

这是一个基于Flutter开发的酒店管理系统员工端应用，主要用于员工处理工单任务。

## 功能特性

### 🔐 登录页面
- 用户名/密码登录
- 记住我功能
- 统一身份认证(SSO)支持
- 错误提示和加载状态

### 📋 任务管理
- 任务列表展示
- 按状态筛选（全部/待处理/进行中）
- 搜索功能
- 任务详情查看
- 任务状态更新（开始/完成/暂停）
- 添加处理备注

### 🔔 通知中心
- 通知列表展示
- 按日期分组（今天/昨天）
- 标记已读/全部已读
- 左滑删除通知
- 点击通知跳转任务详情

### ⚙️ 用户设置
- 个人信息展示
- 语言切换
- 推送通知开关
- 缓存管理
- 版本信息
- 退出登录

## 技术架构

### 数据模型
- `Task`: 任务模型，包含任务信息、状态、优先级等
- `NotificationItem`: 通知模型
- `User`: 用户模型
- `UserSettings`: 用户设置模型

### 页面结构
- `LoginPage`: 登录页面
- `TasksPage`: 任务列表页面
- `TaskDetailPage`: 任务详情页面
- `NotificationsPage`: 通知列表页面
- `SettingsPage`: 设置页面

### 数据管理
- 使用Mock数据模拟后端API
- 支持本地状态管理
- 数据持久化（通过SharedPreferences，待实现）

## 设计特点

### UI设计
- 完全按照HTML模板1:1还原
- 现代化Material Design风格
- 响应式布局适配手机端
- 统一的色彩主题（蓝色系）

### 交互体验
- 流畅的页面切换动画
- 直观的操作反馈
- 友好的错误提示
- 符合移动端使用习惯

## 开发说明

### 项目结构
```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── task.dart
│   ├── notification.dart
│   └── user.dart
├── pages/                    # 页面组件
│   ├── login_page.dart
│   ├── tasks_page.dart
│   ├── task_detail_page.dart
│   ├── notifications_page.dart
│   └── settings_page.dart
└── data/                     # 数据管理
    └── mock_data.dart
```

### 运行项目
```bash
# 安装依赖
flutter pub get

# 运行项目
flutter run
```

### 测试账号
- 用户名: `staff001` 密码: `123456`
- 用户名: `admin` 密码: `admin123`

## 待完善功能

1. **后端集成**: 替换Mock数据为真实API调用
2. **数据持久化**: 使用SharedPreferences存储用户设置
3. **推送通知**: 集成Firebase推送服务
4. **离线支持**: 添加离线数据缓存
5. **多语言**: 完善国际化支持
6. **主题切换**: 支持深色模式

## 版本信息

- 版本: v2.0.0
- Flutter版本: ^3.10.0
- 开发时间: 2024年1月

---

© 2024 酒店管理系统. All rights reserved.