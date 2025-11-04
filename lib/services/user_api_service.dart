import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/user_detail.dart';
import 'auth_service.dart';

/// 用户API服务
class UserApiService {
  static const baseUrl = 'https://kefu.5ok.co/api/v1';

  /// 获取请求头（包含 Authorization token）
  static Future<Map<String, String>> get headers async {
    final authService = AuthService();
    final token = await authService.getToken();
    
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  /// 获取当前用户详情
  static Future<ApiResponse<UserDetail>> getUserDetail() async {
    try {
      final url = '$baseUrl/app/user/detail';
      final requestHeaders = await headers;
      
      debugPrint('========== USER DETAIL REQUEST ==========');
      debugPrint('URL: $url');
      debugPrint('Headers: $requestHeaders');
      debugPrint('=========================================');

      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: jsonEncode({}), // 空请求体
      );

      debugPrint('========== USER DETAIL RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('==========================================');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiResponse.fromJson(
          jsonData,
          (data) => UserDetail.fromJson(data as Map<String, dynamic>),
        );
      } else {
        return ApiResponse(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          statusCode: response.statusCode,
          message: '获取用户详情失败',
          error: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('获取用户详情异常: $e');
      return ApiResponse(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        statusCode: 500,
        message: '网络异常',
        error: e.toString(),
      );
    }
  }

  /// 修改密码
  /// [oldPassword] 旧密码
  /// [newPassword] 新密码
  static Future<ApiResponse<bool>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final url = '$baseUrl/app/user/update-password';
      final requestHeaders = await headers;
      final requestBody = jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });

      debugPrint('========== UPDATE PASSWORD REQUEST ==========');
      debugPrint('URL: $url');
      debugPrint('Headers: $requestHeaders');
      debugPrint('Body: $requestBody');
      debugPrint('=============================================');

      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: requestBody,
      );

      debugPrint('========== UPDATE PASSWORD RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('==============================================');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiResponse.fromJson(
          jsonData,
          (data) => data as bool,
        );
      } else {
        // 解析错误信息
        try {
          final jsonData = jsonDecode(response.body);
          return ApiResponse(
            timestamp: jsonData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
            statusCode: jsonData['statusCode'] ?? response.statusCode,
            message: jsonData['message'] ?? '修改密码失败',
            error: jsonData['error'],
          );
        } catch (_) {
          return ApiResponse(
            timestamp: DateTime.now().millisecondsSinceEpoch,
            statusCode: response.statusCode,
            message: '修改密码失败',
            error: 'HTTP ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      debugPrint('修改密码异常: $e');
      return ApiResponse(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        statusCode: 500,
        message: '网络异常',
        error: e.toString(),
      );
    }
  }
}

