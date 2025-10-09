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
