# 用户设置功能实现文档

## 概述
为 hotel_management_app 的设置页面接入了后端接口，实现了获取用户基本信息和修改密码的功能。

## 后端接口开发

### 1. 创建的文件

#### `UserUpdatePasswordRequest.java`
位置：`hotel-management/src/main/java/com/example/hotelmanagement/model/request/UserUpdatePasswordRequest.java`

修改密码请求模型，包含：
- `oldPassword`: 旧密码
- `newPassword`: 新密码

#### `AppUserController.java`
位置：`hotel-management/src/main/java/com/example/hotelmanagement/controller/AppUserController.java`

App端用户控制器，提供两个接口：

**1. 获取用户详情**
- 路径：`POST /app/user/detail`
- 认证：需要 App Token（通过 `@RequireAppToken` 注解）
- 功能：获取当前登录用户的详细信息
- 返回：用户详情（包括用户ID、用户名、显示名、工号、邮箱、手机、角色、部门等）

**2. 修改密码**
- 路径：`POST /app/user/update-password`
- 认证：需要 App Token
- 请求体：
  ```json
  {
    "oldPassword": "旧密码",
    "newPassword": "新密码"
  }
  ```
- 校验规则：
  - 旧密码不能为空
  - 新密码不能为空
  - 新密码长度不少于6位
  - 新密码不能与旧密码相同
  - 旧密码必须正确
- 功能：修改当前登录用户的密码，并同步到LDAP
- 返回：修改结果（成功/失败）

### 2. 接口特点

- 使用 `/app/` 前缀，区别于管理后台接口
- 使用 `@RequireAppToken` 注解进行Token认证
- 通过 `AppContext.getUserId()` 获取当前登录用户ID，保证安全性
- 复用 `HotelUserService` 的业务逻辑
- 详细的日志记录和错误处理

## 前端 Flutter App 开发

### 1. 创建的文件

#### `user_detail.dart`
位置：`hotel_management_app/lib/models/user_detail.dart`

用户详情数据模型，包含：
- `UserDetail`: 用户详情主类
- `UserDepartmentInfo`: 用户部门信息
- `UserRoleInfo`: 用户角色信息

匹配后端 `UserDetailResponse` 的数据结构。

#### `user_api_service.dart`
位置：`hotel_management_app/lib/services/user_api_service.dart`

用户API服务，提供：
- `getUserDetail()`: 获取当前用户详情
- `updatePassword()`: 修改密码

特点：
- 自动添加 Authorization Token
- 完整的请求/响应日志
- 统一的错误处理
- 返回类型化的 `ApiResponse`

#### `change_password_page.dart`
位置：`hotel_management_app/lib/pages/change_password_page.dart`

修改密码页面，功能：
- 输入旧密码、新密码、确认密码
- 密码可见性切换
- 前端表单验证（非空、长度、一致性）
- 加载状态显示
- 修改成功/失败提示

### 2. 修改的文件

#### `settings_page.dart`
位置：`hotel_management_app/lib/pages/settings_page.dart`

主要更新：
1. **导入新的依赖**
   - `user_detail.dart`: 用户详情模型
   - `user_api_service.dart`: 用户API服务
   - `change_password_page.dart`: 修改密码页面

2. **修改用户数据加载**
   - 从 Mock 数据改为真实 API 调用
   - 添加加载状态（loading）
   - 添加错误处理和重试功能
   - 在 AppBar 添加刷新按钮

3. **修改密码功能**
   - 点击"修改密码"导航到 `ChangePasswordPage`
   - 修改成功后显示提示信息

4. **UI 更新**
   - 显示真实的用户信息（姓名、角色、工号）
   - 支持加载中状态显示
   - 支持错误状态显示和重试

## 使用说明

### 后端部署

1. 确保已配置 `RequireAppToken` 注解和 `AppContext`
2. 确保 `HotelUserRepository` 和 `LdapService` 正常工作
3. 启动后端服务

### 前端使用

1. 用户登录后，进入设置页面
2. 设置页面会自动加载用户信息
3. 点击"修改密码"进入修改密码页面
4. 输入旧密码、新密码、确认密码
5. 点击"确认修改"提交

### API 请求示例

#### 获取用户详情
```bash
POST https://kefu.5ok.co/api/v1/app/user/detail
Headers:
  Content-Type: application/json
  Authorization: Bearer {token}
Body: {}
```

响应：
```json
{
  "timestamp": 1699000000000,
  "statusCode": 200,
  "message": "success",
  "data": {
    "userId": 1,
    "username": "zhangsan",
    "displayName": "张三",
    "employeeNumber": "E001",
    "email": "zhangsan@example.com",
    "phone": "13800138000",
    "superAdmin": false,
    "active": 1,
    "department": {
      "departmentId": 1,
      "departmentName": "前台部"
    },
    "roles": [
      {
        "roleId": 2,
        "roleName": "前台员工"
      }
    ]
  }
}
```

#### 修改密码
```bash
POST https://kefu.5ok.co/api/v1/app/user/update-password
Headers:
  Content-Type: application/json
  Authorization: Bearer {token}
Body:
{
  "oldPassword": "oldpass123",
  "newPassword": "newpass123"
}
```

响应（成功）：
```json
{
  "timestamp": 1699000000000,
  "statusCode": 200,
  "message": "success",
  "data": true
}
```

响应（失败）：
```json
{
  "timestamp": 1699000000000,
  "statusCode": 400,
  "message": "修改密码失败",
  "error": "旧密码错误"
}
```

## 安全特性

1. **Token 认证**：所有接口都需要有效的 App Token
2. **用户隔离**：通过 AppContext 自动获取当前用户ID，防止越权访问
3. **密码验证**：修改密码时必须验证旧密码
4. **密码加密**：使用 PasswordUtil.hashPassword 加密存储
5. **LDAP 同步**：密码修改后同步到 LDAP 系统

## 测试建议

### 后端测试
1. 测试未登录访问（应返回401）
2. 测试获取用户详情（应返回当前用户信息）
3. 测试修改密码各种场景：
   - 旧密码错误
   - 新密码太短
   - 新密码与旧密码相同
   - 正常修改成功

### 前端测试
1. 测试设置页面加载用户信息
2. 测试网络错误时的重试功能
3. 测试修改密码表单验证
4. 测试修改密码成功/失败的提示

## 后续优化建议

1. **个人资料编辑**：添加修改显示名、邮箱、手机号等功能
2. **头像上传**：支持用户上传和修改头像
3. **密码强度检测**：在前端添加密码强度提示
4. **会话管理**：添加查看和管理登录设备的功能
5. **操作日志**：记录密码修改等敏感操作的日志

## 技术栈

- **后端**：Spring Boot, JPA, LDAP
- **前端**：Flutter, Dart
- **认证**：Token-based Authentication
- **数据存储**：MySQL + LDAP

## 相关文件清单

### 后端
- `hotel-management/src/main/java/com/example/hotelmanagement/controller/AppUserController.java`
- `hotel-management/src/main/java/com/example/hotelmanagement/model/request/UserUpdatePasswordRequest.java`

### 前端
- `hotel_management_app/lib/models/user_detail.dart`
- `hotel_management_app/lib/services/user_api_service.dart`
- `hotel_management_app/lib/pages/change_password_page.dart`
- `hotel_management_app/lib/pages/settings_page.dart`（已修改）

## 版本信息
- 创建时间：2025-11-04
- 版本：v1.0
- 作者：AI Assistant

