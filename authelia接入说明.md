# Flutter App Authelia OIDC 集成开发指南

## 1. 目标

本文档旨在指导开发者完成 Flutter 移动应用与 Authelia 身份认证服务器的集成。我们将采用行业标准的 **OIDC (OpenID Connect) 授权码流程**，实现安全、可靠的单点登录（SSO）功能。

## 2. 核心技术栈

- **认证协议**: OIDC (Authorization Code Flow with PKCE)
- **Flutter 库**:
    - `flutter_appauth`: 用于处理 OIDC 协议的所有复杂交互。
    - `flutter_secure_storage`: 用于在设备上安全地存储认证令牌（Tokens）。

---

## 3. 实现步骤

### 第 1 步：项目依赖配置

在项目根目录的 `pubspec.yaml` 文件中，添加以下两个核心依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 用于处理 OIDC 认证流程
  flutter_appauth: ^6.0.0

  # 用于在设备上安全地存储令牌
  flutter_secure_storage: ^9.0.0
```

添加后，在终端运行 `flutter pub get` 来安装依赖。

### 第 2 步：平台特定配置 (回调 URI)

为了让 Authelia 登录成功后能够返回并唤醒我们的 App，需要为 App 注册一个唯一的 **Custom URL Scheme**。

**我们约定使用 `co.5ok.kefu.auth` 作为 App 的 URL Scheme。**

#### **Android 配置**

打开文件 `android/app/build.gradle`，在 `defaultConfig` 部分添加 `manifestPlaceholders`：

```groovy
// 文件: android/app/build.gradle
android {
    // ...
    defaultConfig {
        // ...
        manifestPlaceholders = {
            'appAuthRedirectScheme': 'co.5ok.kefu.auth' // <-- 只写 Scheme 部分
        }
    }
}
```

#### **iOS 配置**

打开文件 `ios/Runner/Info.plist`，添加 `CFBundleURLTypes` 数组：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>co.5ok.kefu.auth</string> </array>
    </dict>
</array>
```

### 第 3 步：创建认证服务 (`AuthService`)

为了代码整洁和可维护性，我们将所有认证逻辑封装在一个 `AuthService` 类中。

在 `lib/` 目录下创建一个 `services/auth_service.dart` 文件，并填入以下完整代码：

```dart
// 文件: lib/services/auth_service.dart
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // --- 配置信息 (请根据 Authelia 服务器的实际情况修改) ---
  static const String _authDomain = 'kefu.5ok.co';
  static const String _clientId = 'my-mobile-app';
  static const String _redirectUrl = 'co.5ok.kefu.auth://callback';
  static const String _issuer = 'https://$_authDomain';

  // --- 依赖库实例 ---
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // --- 存储键 ---
  static const String _refreshTokenKey = 'refresh_token';
  static const String _accessTokenKey = 'access_token';

  /// 获取当前有效的 Access Token
  Future<String?> getAccessToken() async {
    // 实际项目中，这里应增加检查 Token 是否过期的逻辑，如果过期则尝试刷新
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// 检查用户是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  /// 发起登录请求
  Future<bool> signIn() async {
    try {
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          issuer: _issuer,
          scopes: ['openid', 'profile', 'email', 'groups'],
          // 建议开启，避免登录会话与系统主浏览器共享
          preferEphemeralSession: true,
        ),
      );

      if (result != null) {
        // 登录成功，安全地存储令牌
        await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);
        await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
        print("登录成功");
        return true;
      }
      return false;
    } catch (e) {
      print('登录或授权失败: $e');
      return false;
    }
  }

  /// 登出
  Future<void> signOut() async {
    // 仅需清除本地存储的令牌即可
    await _secureStorage.deleteAll();
    print("已登出");
  }
}
```

### 第 4 步：实现 App 启动路由逻辑

App 启动时需要判断用户登录状态，以决定显示登录页还是主页。

在 `lib/main.dart` 中实现这个逻辑：

```dart
// 文件: lib/main.dart
import 'package:flutter/material.dart';
// 导入你的页面和 AuthService
import 'services/auth_service.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我的应用',
      home: AuthWrapper(), // 使用一个包装器来处理路由
    );
  }
}

/// AuthWrapper 负责在 App 启动时检查登录状态
class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  late Future<bool> _checkLoginFuture;

  @override
  void initState() {
    super.initState();
    _checkLoginFuture = _authService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginFuture,
      builder: (context, snapshot) {
        // 正在检查登录状态时，显示加载动画
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 如果检查结果为已登录，进入主页
        if (snapshot.hasData && snapshot.data == true) {
          return HomePage();
        }
        
        // 否则，进入登录页
        return LoginPage();
      },
    );
  }
}
```

### 第 5 步：创建登录页和主页

#### **登录页 (`lib/pages/login_page.dart`)**
页面上需要一个按钮来触发 `authService.signIn()`。

```dart
// 文件: lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart'; // 登录成功后跳转到主页

class LoginPage extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("登录")),
      body: Center(
        child: ElevatedButton(
          child: Text("通过 Authelia 登录"),
          onPressed: () async {
            final success = await _authService.signIn();
            if (success && context.mounted) {
              // 登录成功后替换当前页面栈，跳转到主页
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          },
        ),
      ),
    );
  }
}
```

#### **主页 (`lib/pages/home_page.dart`)**
页面上需要一个登出按钮，并演示如何调用受保护的 API。

```dart
// 文件: lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'login_page.dart'; // 登出后跳转到登录页

class HomePage extends StatelessWidget {
  final AuthService _authService = AuthService();

  // 模拟调用受保护的 API
  Future<void> _fetchProtectedData() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      print("无法获取 Token，用户未登录。");
      return;
    }

    try {
      final response = await http.get(
        // 使用为 App 配置的专用 API 路由
        Uri.parse('[https://kefu.5ok.co/api/mobile/v1/profile](https://kefu.5ok.co/api/mobile/v1/profile)'), 
        headers: {
          'Authorization': 'Bearer $token', // 在请求头中携带 Access Token
        },
      );

      if (response.statusCode == 200) {
        print("成功获取受保护的数据: ${response.body}");
        // 在 UI 中显示成功提示
      } else {
        print("API 请求失败，状态码: ${response.statusCode}");
        // 如果是 401, 应触发 Token 刷新逻辑
      }
    } catch (e) {
      print("调用 API 时发生错误: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("主页"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          child: Text("获取用户数据 (调用 API)"),
          onPressed: _fetchProtectedData,
        ),
      ),
    );
  }
}
```

---

## 4. 最终核对清单

在交付前，请确保以下配置完全匹配：

1.  **[Authelia]** `configuration.yml` 中的 `client_id` 和 `redirect_uris`。
2.  **[Android]** `build.gradle` 中的 `appAuthRedirectScheme`。
3.  **[iOS]** `Info.plist` 中的 `CFBundleURLSchemes`。
4.  **[Dart]** `AuthService` 类中的 `_clientId` 和 `_redirectUrl` 常量。
5.  **[Nginx]** 已经配置了专门用于 App Token 验证的 API 路由 (例如 `/api/mobile/v1/`)。

完成以上步骤后，App 将具备完整的 Authelia OIDC 登录、登出和 API 认证能力。