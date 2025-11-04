// 文件: lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // --- 配置信息 ---
  static const String _apiBaseUrl = 'https://kefu.5ok.co/api/v1'; // 根据实际情况修改
  
  // --- 依赖库实例 ---
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // --- 存储键 ---
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';

  /// 获取当前有效的 Token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// 获取当前用户名
  Future<String?> getUsername() async {
    return await _secureStorage.read(key: _usernameKey);
  }

  /// 检查用户是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// 发起登录请求
  /// [username] 用户名
  /// [password] 密码
  /// 返回登录是否成功
  Future<LoginResult> signIn(String username, String password) async {
    try {
      final url = '$_apiBaseUrl/app/auth/app-login';
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'username': username,
        'password': password,
      });
      
      // 打印请求信息
      debugPrint('========== LOGIN REQUEST ==========');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');
      debugPrint('===================================');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      // 打印响应信息
      debugPrint('========== LOGIN RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: ${response.body}');
      debugPrint('====================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 检查返回数据格式
        if (data['statusCode'] == 200 && data['data'] != null) {
          final token = data['data']['token'] as String?;
          
          if (token != null && token.isNotEmpty) {
            // 登录成功，安全地存储令牌和用户名
            await _secureStorage.write(key: _tokenKey, value: token);
            await _secureStorage.write(key: _usernameKey, value: username);
            debugPrint("LOGIN SUCCESS - Token saved");
            return LoginResult(success: true);
          }
        }
        
        // 登录失败，返回错误信息
        final message = data['message'] ?? '登录失败';
        debugPrint('LOGIN FAILED: $message');
        return LoginResult(success: false, errorMessage: message);
      } else {
        final errorMsg = '网络请求失败\n'
            '状态码: ${response.statusCode}\n'
            '请求URL: $url\n'
            '响应体: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}';
        debugPrint('LOGIN FAILED: $errorMsg');
        return LoginResult(
          success: false, 
          errorMessage: errorMsg,
        );
      }
    } catch (e) {
      debugPrint('LOGIN EXCEPTION: $e');
      return LoginResult(
        success: false,
        errorMessage: '网络异常，请检查网络连接: $e',
      );
    }
  }

  /// 登出
  Future<void> signOut() async {
    try {
      final token = await getToken();
      
      if (token != null && token.isNotEmpty) {
        // 调用后端登出接口
        await http.post(
          Uri.parse('$_apiBaseUrl/app/auth/app-logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      debugPrint('LOGOUT EXCEPTION: $e');
    } finally {
      // 无论后端请求是否成功，都清除本地存储的令牌
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _usernameKey);
      debugPrint("LOGOUT SUCCESS");
    }
  }
}

/// 登录结果
class LoginResult {
  final bool success;
  final String? errorMessage;

  LoginResult({
    required this.success,
    this.errorMessage,
  });
}
