# Flutter App 整合 Authelia OIDC 登录开发指南

## 1. 核心目标与实现原理

### 1.1. 目标

本文档旨在提供一个完整的、端到端的解决方案，指导开发者将 Flutter 移动应用与 Authelia 身份认证服务器进行集成。我们将采用行业标准的 **OIDC (OpenID Connect) 协议**，实现安全、可靠的单点登录（SSO）功能。

### 1.2. 实现原理：OIDC 授权码流程 (Authorization Code Flow)

整个登录授权过程涉及到四个关键角色：

1.  **用户 (User)**: 操作 App 的最终使用者。
2.  **Flutter App (客户端)**: 需要访问受保护资源（例如后端 API）的移动应用程序。
3.  **Authelia (认证服务器)**: 负责验证用户身份，并颁发访问令牌 (Token)。
4.  **Nginx (反向代理 / API 网关)**: 接收 App 的所有请求，将认证请求转发给 Authelia，将受保护的 API 请求转发给后端业务服务。

**登录授权流程详解：**

1.  **发起登录**: 用户在 Flutter App 中点击“登录”按钮。App 会构建一个 OIDC 授权请求，并打开一个应用内浏览器（或系统浏览器）重定向到 Authelia 的登录页面。
2.  **用户认证**: 用户在 Authelia 页面输入用户名和密码。Authelia 验证用户身份。
3.  **颁发授权码**: 身份验证成功后，Authelia 不会直接返回敏感信息，而是通过重定向返回一个临时的**授权码 (Authorization Code)**。重定向的目标地址是 App 在第二步中注册的自定义 URL (例如 `co.5ok.kefu.auth://callback`)。
4.  **唤醒 App**: 移动操作系统根据这个自定义 URL，自动将控制权交还给 Flutter App，并将授权码传递给 App。
5.  **交换令牌**: App 在后台收到授权码后，会立即向 Authelia 的 Token 端点发起一个请求，用这个授权码交换**访问令牌 (Access Token)** 和**刷新令牌 (Refresh Token)**。
6.  **安全存储**: App 获取到令牌后，使用 `flutter_secure_storage` 将它们安全地存储在设备的钥匙串 (iOS) 或 Keystore (Android) 中。
7.  **访问受保护 API**: 当 App 需要请求后端业务 API 时，它会从安全存储中读取 Access Token，并将其放入 HTTP 请求的 `Authorization` 头中 (格式为 `Bearer <Access Token>`)。
8.  **API 网关验证**: Nginx 作为 API 网关，会拦截这个请求，并将 Access Token 转发给 Authelia 进行验证。验证通过后，Nginx 才会将请求真正转发给后端的业务服务。

这个流程的核心优势在于，用户的密码永远不会暴露给 Flutter App，并且 Access Token 的生命周期通常很短，即使泄露，风险也相对可控。

---

## 2. 详细实现步骤

### 第 1 步：服务端配置 (Authelia & Nginx)

这是整个流程的基础，确保认证服务器和服务网关能够识别我们的 App。

#### **Authelia (`configuration.yml`)**

在 Authelia 的主配置文件中，添加 `identity_providers` 部分。这部分包含了用于签发 JWT（ID Tokens）的私钥和我们移动 App 的客户端注册信息。

> **[说明] 如何生成私钥:**
> 下方的 `jwks` (JSON Web Key Set) 配置需要一个 `RS256` 算法的私钥。您可以通过 `openssl` 命令行工具轻松生成一个新的：
> ```bash
> openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
> ```
> 执行该命令后，会在当前目录下生成一个 `private_key.pem` 文件，将其中的内容完整地拷贝到 `key:` 字段下方即可。

```yaml
identity_providers:
  oidc:
    jwks:
      - algorithm: RS256
        key: |
          -----BEGIN PRIVATE KEY-----
          MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCvPOSccUG4ROss
          mbT5R6XpfDITa6fYqyiYbOUaZHXOMRtMK/yd4RSze7YoJKjD1MIrf1x/nMT+8lte
          6bnWI9UwSw+FR/Ivn9V2sqPz+oTnDReqPxZwRC/T5Q6IIDsamNRCBu1mWcmvaFAQ
          Ym04uone9BnZxKgTpDr6/Mi+WHSUJT+TD+HdW+FKXkGy1OshwLDAnqveN/NPN6Mt
          Z/dTwDEQLY3g7oDgC5qvQqj6YFcvfie7JJ6s9pYrGyrxrtK8ZmbrtXk+RN3dQNpO
          5jhfuCVujyROk+SDIffzC0wbju/2aUlSPvBUpLAEw0LQmNMWuZEHH5Jpq9hpTAXS
          VGQMiwX3AgMBAAECggEAM3Njg/NU4m+JxRyUICTDN9x5L26KZ3lJgAdo9OjOFe4h
          H6pCj3BIjbIi94Jb8rODFxZb6DP1Ow2ZejKRl6gJrhY7xlwrZYQ+Po2Qyc+iOdyE
          OD4xrmC20jYMoDcmY1a/62rxRP3T06aC62yauO88D7QH6wJsfufXUV3q6sg54kzZ
          D5U6ftgkwOqffFidzq4GYY++UOHJ8Bq1Gvl5bq21hJYUrrNYO2KdrhJRWWFqytcR
          T/I+SfmiZJ9r0y+A51cdSMplH63TH/YsQ8aaZ08m02YZk8OudzEFhpSSsbXGMr4v
          LVeFUCf0r41cu+dQYV6n71+IIbTg27A0iwgdMxssYQKBgQDT1vdYdifzM9hFw8Fa
          lq/1jBAvyAlGZSgM2c8yMHxVgud0eJHJuWEkgV4LsiOUTvB/52KmG4QhAaAZVR+J
          JBXxjB/oKqX6Zj/47URI+EO63vrpWeE4aV/sA7rO0i8Y+mKMOJfzV2x/Bc6JpDHM
          7CvR+bq8X0SyBmmzNYJuOiCEPwKBgQDTxKIgxxdbnvQIByENlfNQlzgWszlcc6UH
          5UwGnoAR6LSxmQCIBIrjzAbybup1fw/Sd5C3MDG24aq+xXdCRDRnpQleLHXY++U7
          L4Rsi30P7NRRLPwU+sQV/4SEwoQ2+x3V/ERr+jIj256I44w+3BkhczR378fxqtiH
          GDixQyawSQKBgDAi7NmhH7rX0REpRkp7a0h0p0j0P4dLfSpOZBKXiek0cbu5mgco
          pLZS3zfxJryQo32s6nGsVv3ZDLQ075GOLZ5RpP5wkn6vtWGvKJEcOOfBu2pDDjZv
          W2iaAFz2zdTzMGmEgqK8/t5uR1xnfxl9oQd5o8EiNM3vPx2FzzmU48apAoGAK0D8
          hIllwfcDjSg3nhjEq+9XK3vL+ZA9YxF4p9lz+zR2w9emfiG/ZKvlt1rkVL9xMeHu
          Exyq6tnJEFIw+74GnizdbvjR0VISDja0a59KGhibfUEc9AQMTRn1rVA1xS0hePWf
          3BYsa5qOFRO1L5mxIF3xl5XIVxo4Q8+0tLAslNECgYAEE+tisqxFwWv2W/yNIQVP
          8uk+dIYyzWxWRRjgkFu2BhpyrBLKQQWVpeQoDjA5xZwRgivjLSsmitYdjedY/bTa
          zCiwmmZ3qSjeZ9By1qVEX4T265kxMuNSXwtF8Q4Nxzwi5NcGqOLKwMOF9j5HUzI3
          kaTrqCfzbcyq4la+ey+3cQ==
          -----END PRIVATE KEY-----

    clients:
      - client_id: 'my-mobile-app'
        client_name: 'Hotel Management Mobile App'
        public: true
        scopes:
          - 'openid'
          - 'profile'
          - 'email'
          - 'groups'
        redirect_uris:
          - 'co.5ok.kefu.auth://callback'
        userinfo_signed_response_alg: 'none'
```

#### **Nginx (`nginx.conf`)**

Nginx 需要正确代理 OIDC 协议所需的标准端点，以便 App 能够发现配置并完成令牌交换。在你的 `server` 配置块中添加以下 `location`。

```nginx
# --- [新增] OIDC Provider Endpoints ---

# 代理 OIDC 发现端点 (/.well-known/openid-configuration)
# AppAuth 库会首先访问这个地址来自动获取所有其他 OIDC 端点的 URL
location /.well-known/openid-configuration {
    proxy_pass http://127.0.0.1:9091/.well-known/openid-configuration;
    # 传递必要的头信息
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
}

# 代理 OIDC 核心 API (例如：令牌交换、用户信息获取等)
location /api/oidc/ {
    proxy_pass http://127.0.0.1:9091/api/oidc/;
    # 传递必要的头信息
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

### 第 2 步：Flutter 项目依赖配置

在 `pubspec.yaml` 文件中，添加 OIDC 库和安全存储库。

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 用于处理 OIDC 认证流程
  flutter_appauth: ^6.0.0

  # 用于在设备上安全地存储令牌
  flutter_secure_storage: ^9.0.0
```
添加后，运行 `flutter pub get` 安装依赖。

### 第 3 步：平台特定配置 (注册回调 URI)

为了让 Authelia 登录成功后能唤醒我们的 App，需要为 App 注册一个唯一的 **Custom URL Scheme**。

**我们统一使用 `co.5ok.kefu.auth` 作为 App 的 URL Scheme。**

#### **Android 配置 (`android/app/src/main/AndroidManifest.xml`)**

直接在 `MainActivity` 的 `<activity>` 标签内，添加一个新的 `<intent-filter>`。

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application ...>
        <activity
            android:name=".MainActivity"
            ...>
            
            <!-- Flutter App 的主入口 Intent Filter -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- [新增] OIDC 重定向 Intent Filter -->
            <!-- 这个 Filter 会告诉安卓系统，所有 co.5ok.kefu.auth:// 开头的链接都由本 App 处理 -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="co.5ok.kefu.auth" android:host="callback" />
            </intent-filter>

        </activity>
        ...
    </application>
</manifest>
```

#### **iOS 配置 (`ios/Runner/Info.plist`)**

在 `Info.plist` 的主 `<dict>` 标签内，添加 `CFBundleURLTypes` 数组。

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- 这个值必须与 Authelia 和 Android 配置中的 Scheme 部分完全一致 -->
            <string>co.5ok.kefu.auth</string>
        </array>
    </dict>
</array>
```

### 第 4 步：创建认证服务 (`AuthService`)

将所有认证逻辑封装在一个 `AuthService` 类中，便于管理和复用。创建 `lib/services/auth_service.dart` 文件。

```dart
// 文件: lib/services/auth_service.dart
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // --- 配置信息 (必须与 Authelia 和 Nginx 配置完全匹配) ---
  static const String _authDomain = 'kefu.5ok.co';
  static const String _clientId = 'my-mobile-app'; // 对应 Authelia 中的 client.id
  static const String _redirectUrl = 'co.5ok.kefu.auth://callback'; // 对应 Authelia 中的 client.redirect_uris
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
        print("登录成功，令牌已存储");
        return true;
      }
      return false;
    } catch (e, s) {
      print('登录或授权失败: $e');
      print('堆栈跟踪: $s');
      return false;
    }
  }

  /// 登出
  Future<void> signOut() async {
    // 仅需清除本地存储的令牌即可
    await _secureStorage.deleteAll();
    print("已登出，令牌已清除");
  }
}
```

### 第 5 步：UI 集成

在登录页面调用 `AuthService` 的 `signIn` 方法即可。

```dart
// 文件: lib/pages/login_page.dart
// (部分代码示例)

ElevatedButton(
  child: const Text('通过 Authelia 登录'),
  onPressed: () async {
    final authService = AuthService();
    final success = await authService.signIn();
    if (success && context.mounted) {
      // 登录成功后跳转到主页
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TasksPage()),
      );
    } else if (context.mounted) {
      // 显示登录失败提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录失败，请检查网络或联系管理员')),
      );
    }
  },
),
```

---

## 3. 最终核对清单

在部署和测试前，请务必确保以下各项配置完全匹配，这是成功的关键：

| 配置项 | Authelia (`configuration.yml`) | Flutter (`auth_service.dart`) | Android (`AndroidManifest.xml`) | iOS (`Info.plist`) |
| :--- | :--- | :--- | :--- | :--- |
| **Client ID** | `client_id: 'my-mobile-app'` | `_clientId = 'my-mobile-app'` | - | - |
| **Issuer URL** | - | `_issuer = 'https://kefu.5ok.co'` | - | - |
| **Redirect URI** | `redirect_uris: ['co.5ok.kefu.auth://callback']` | `_redirectUrl = 'co.5ok.kefu.auth://callback'` | `scheme="co.5ok.kefu.auth"` & `host="callback"` | `string>co.5ok.kefu.auth</string>` |

完成以上所有步骤后，您的 Flutter 应用将具备完整的、基于 OIDC 的 Authelia 单点登录能力。