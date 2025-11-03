# App登录功能说明

## 概述

本文档说明了新的App端登录/登出功能实现，替代了之前的Authelia OIDC方案。

## 变更内容

### 1. 删除的内容
- ✅ 删除了 `authelia接入说明.md` 文档
- ✅ 删除了 `flutter_appauth` 依赖
- ✅ 删除了 Android 中的 OIDC 重定向 Intent Filter
- ✅ 删除了 iOS 中的 CFBundleURLTypes 配置
- ✅ 删除了旧的 Authelia OIDC 相关代码

### 2. 新增的内容

#### Flutter App端
- ✅ 重写了 `AuthService` 类，实现基于用户名密码的登录
- ✅ 更新了登录页面 UI，增加用户名和密码输入框
- ✅ Token 使用 `flutter_secure_storage` 安全存储在设备上
- ✅ 支持显示登录错误信息

#### 后端
- ✅ 创建了 `AuthToken` 实体类
- ✅ 创建了 `AuthTokenRepository` 仓库类
- ✅ 实现了 `/api/app-login` 登录接口
- ✅ 实现了 `/api/app-logout` 登出接口
- ✅ 创建了数据库迁移脚本 `auth_tokens.sql`

## 功能特性

### 登录流程
1. 用户在App中输入用户名和密码
2. App调用后端 `/api/app-login` 接口
3. 后端校验用户名和密码（使用LDAP SHA加密）
4. 验证成功后生成一个安全的Token（256位随机数，Base64编码）
5. Token存储到 `auth_tokens` 表中
6. 返回Token给App端
7. App将Token安全存储在设备的Keychain/Keystore中

### 登出流程
1. 用户点击登出
2. App调用后端 `/api/app-logout` 接口，在Header中携带Token
3. 后端从数据库中删除对应的Token
4. App清除本地存储的Token

### Token特性
- **永不过期**：Token不会自动过期，可以长期使用
- **多端登录**：支持同一用户在多个设备上同时登录
- **安全存储**：使用设备的安全存储机制保护Token
- **可撤销**：通过登出接口可以删除Token

## 数据库变更

需要执行 `hotel-management/auth_tokens.sql` 创建新表：

```sql
CREATE TABLE auth_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token TEXT UNIQUE NOT NULL,
    device_info VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## API接口说明

### 1. 登录接口

**请求：**
```
POST /api/app-login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123",
  "deviceInfo": "iPhone 14 Pro"  // 可选
}
```

**成功响应：**
```json
{
  "timestamp": 1698765432000,
  "statusCode": 200,
  "message": "success",
  "data": {
    "token": "xxxxxxxxxxxxxxxxxxx",
    "userId": 1,
    "username": "admin",
    "displayName": "管理员"
  },
  "error": null
}
```

**失败响应：**
```json
{
  "timestamp": 1698765432000,
  "statusCode": 500,
  "message": "用户名或密码错误",
  "data": null,
  "error": null
}
```

### 2. 登出接口

**请求：**
```
POST /api/app-logout
Content-Type: application/json
Authorization: Bearer <token>
```

**成功响应：**
```json
{
  "timestamp": 1698765432000,
  "statusCode": 200,
  "message": "success",
  "data": null,
  "error": null
}
```

## 配置说明

### Flutter App配置

在 `lib/services/auth_service.dart` 中修改API地址：

```dart
static const String _apiBaseUrl = 'https://kefu.5ok.co/api';
```

根据实际环境修改此URL。

## 安全说明

1. **密码传输**：密码通过HTTPS加密传输，确保使用HTTPS协议
2. **密码存储**：后端使用LDAP SHA加密存储密码
3. **Token安全**：Token使用256位随机数生成，碰撞概率极低
4. **Token存储**：App端使用系统安全存储（Keychain/Keystore）
5. **会话管理**：Token可以随时通过登出接口撤销

## 后续计划

- [ ] 为其他App接口添加Token校验中间件
- [ ] 实现Token有效性验证逻辑（可选）
- [ ] 添加设备管理功能（查看/删除已登录设备）
- [ ] 添加登录日志记录

## 开发说明

### 运行Flutter App

```bash
cd hotel_management_app
flutter pub get
flutter run
```

### 编译后端

确保在 `hotel-management` 目录下：

```bash
mvn clean package
```

### 数据库迁移

在PostgreSQL中执行：

```bash
psql -U <username> -d <database> -f auth_tokens.sql
```

## 测试建议

1. **登录测试**
   - 测试正确的用户名密码
   - 测试错误的用户名密码
   - 测试已禁用的账户
   - 测试空用户名或密码

2. **登出测试**
   - 测试正常登出
   - 测试无效Token登出
   - 测试不携带Token登出

3. **Token持久化测试**
   - 关闭App后重新打开，验证是否保持登录状态
   - 多设备同时登录测试

## 故障排查

### 问题：登录时提示"网络异常"
- 检查API地址是否正确
- 检查网络连接
- 确认后端服务是否正常运行

### 问题：登录成功但无法保存Token
- 检查设备是否支持Secure Storage
- Android：检查是否启用了设备锁
- iOS：检查Keychain访问权限

### 问题：后端返回500错误
- 查看后端日志
- 检查数据库连接
- 确认auth_tokens表是否正确创建

## 联系方式

如有问题，请联系开发团队。

