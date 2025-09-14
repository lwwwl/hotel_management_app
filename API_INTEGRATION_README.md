# Flutter 工单管理应用 - API集成说明

## 概述

本Flutter应用已成功集成了工单管理系统的API接口，替换了原有的mock数据。应用现在可以从后端API获取真实的工单数据。

## 主要变更

### 1. 新增依赖
- `http: ^1.1.0` - 用于HTTP请求

### 2. 新增文件

#### API模型类
- `lib/models/api_response.dart` - API响应通用模型
- `lib/models/api_requests.dart` - API请求模型
- `lib/models/api_models.dart` - API响应数据模型
- `lib/models/task_adapter.dart` - API数据到现有Task模型的适配器

#### API服务类
- `lib/services/task_api_service.dart` - 工单API服务

### 3. 更新的页面
- `lib/pages/tasks_page.dart` - 工单列表页面，现在使用API数据
- `lib/pages/task_detail_page.dart` - 工单详情页面，现在使用API数据

## API接口集成

### 已集成的接口

1. **POST /task/list** - 获取工单列表
   - 支持按状态筛选
   - 支持按部门筛选
   - 支持按优先级筛选

2. **POST /task/detail** - 获取工单详情
   - 根据工单ID获取详细信息

### 请求配置

- **Base URL**: `http://localhost:8080`
- **用户ID**: 写死为 `1` (在 `TaskApiService` 中配置)
- **请求头**: 
  - `Content-Type: application/json`
  - `X-User-Id: 1`

## 功能特性

### 工单列表页面
- ✅ 从API加载工单数据
- ✅ 加载状态指示器
- ✅ 错误处理和重试功能
- ✅ 下拉刷新
- ✅ 状态筛选 (全部/待处理/进行中/待确认)
- ✅ 搜索功能
- ✅ 空状态显示

### 工单详情页面
- ✅ 从API加载工单详情
- ✅ 加载状态指示器
- ✅ 错误处理和重试功能
- ✅ 任务状态更新 (本地状态，未调用API)
- ✅ 备注添加 (本地状态，未调用API)
- ✅ 完整的状态流转: 待处理 → 进行中 → 待确认 → 已完成

## 数据映射

API数据通过 `TaskAdapter` 类映射到现有的 `Task` 模型：

### 工单状态 (TaskStatus)
- `pending` → `TaskStatus.pending` (待处理)
- `in_progress` → `TaskStatus.inProgress` (进行中)
- `review` → `TaskStatus.review` (待确认)
- `completed` → `TaskStatus.completed` (已完成)

### 工单优先级 (TaskPriority)
- `low` → `TaskPriority.low` (低)
- `medium` → `TaskPriority.medium` (中)
- `high` → `TaskPriority.high` (高)
- `urgent` → `TaskPriority.urgent` (紧急)

### 颜色映射
- **优先级颜色**:
  - 紧急: 红色
  - 高: 橙色
  - 中: 蓝色
  - 低: 灰色
- **状态颜色**:
  - 待处理: 橙色
  - 进行中: 蓝色
  - 待确认: 紫色
  - 已完成: 绿色

## 运行说明

1. 确保后端API服务运行在 `http://localhost:7788`
2. 运行 `flutter pub get` 安装依赖
3. 运行 `flutter run` 启动应用

## 注意事项

1. **用户认证**: 当前使用写死的用户ID `1`，实际使用时需要实现完整的登录逻辑
2. **状态更新**: 工单状态更新和备注添加目前只更新本地状态，未调用相应的API接口
3. **错误处理**: 已实现基本的网络错误处理，包括超时和连接失败
4. **数据刷新**: 支持下拉刷新重新加载数据

## 后续扩展

可以考虑添加以下功能：
- 完整的用户认证系统
- 工单状态更新API调用
- 备注添加API调用
- 工单创建功能
- 推送通知集成
- 离线数据缓存
