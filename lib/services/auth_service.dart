// 文件: lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // --- 配置信息 ---
  static const String _apiBaseUrl = 'https://kefu.5ok.co/api'; // 根据实际情况修改
  
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
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/app-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 检查返回数据格式
        if (data['statusCode'] == 200 && data['data'] != null) {
          final token = data['data']['token'] as String?;
          
          if (token != null && token.isNotEmpty) {
            // 登录成功，安全地存储令牌和用户名
            await _secureStorage.write(key: _tokenKey, value: token);
            await _secureStorage.write(key: _usernameKey, value: username);
            print("登录成功");
            return LoginResult(success: true);
          }
        }
        
        // 登录失败，返回错误信息
        final message = data['message'] ?? '登录失败';
        return LoginResult(success: false, errorMessage: message);
      } else {
        return LoginResult(
          success: false, 
          errorMessage: '网络请求失败 (${response.statusCode})',
        );
      }
    } catch (e) {
      print('登录请求异常: $e');
      return LoginResult(
        success: false,
        errorMessage: '网络异常，请检查网络连接',
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
          Uri.parse('$_apiBaseUrl/app-logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      print('登出请求异常: $e');
    } finally {
      // 无论后端请求是否成功，都清除本地存储的令牌
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _usernameKey);
      print("已登出");
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
