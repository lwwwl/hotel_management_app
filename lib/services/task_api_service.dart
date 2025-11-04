import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/api_requests.dart';
import '../models/api_models.dart';
import 'auth_service.dart';

class TaskApiService {
  static const baseUrl = 'https://kefu.5ok.co/api/v1';
  // static const baseUrl = 'http://111.223.37.162:7788';

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

  /// 获取工单列表
  static Future<ApiResponse<List<TaskListColumnBO>>> getTaskList({
    List<String>? taskStatuses,
    int? departmentId,
    String? priority,
  }) async {
    try {
      // 如果没有指定状态，默认获取所有状态
      final statuses = taskStatuses ?? ['pending', 'in_progress', 'review', 'completed'];
      
      final request = TaskListRequest(
        requireTaskColumnList: statuses.map((status) => TaskColumnRequest(
          taskStatus: status,
        )).toList(),
        departmentId: departmentId,
        priority: priority,
      );

      final url = '$baseUrl/app/task/list';
      final requestHeaders = await headers;
      final requestBody = jsonEncode(request.toJson());
      
      debugPrint('========== TASK LIST REQUEST ==========');
      debugPrint('URL: $url');
      debugPrint('Headers: $requestHeaders');
      debugPrint('Body: $requestBody');
      debugPrint('=======================================');
      
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: requestBody,
      );
      
      debugPrint('========== TASK LIST RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: ${response.body}');
      debugPrint('========================================');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = ApiResponse<List<TaskListColumnBO>>.fromJson(
          jsonData,
          (data) => (data as List<dynamic>)
              .map((e) => TaskListColumnBO.fromJson(e))
              .toList(),
        );
        return apiResponse;
      } else {
        return ApiResponse<List<TaskListColumnBO>>(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          statusCode: response.statusCode,
          message: '请求失败',
          error: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<TaskListColumnBO>>(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        statusCode: 500,
        message: '网络错误',
        error: e.toString(),
      );
    }
  }

  /// 获取工单详情
  static Future<ApiResponse<TaskDetailBO>> getTaskDetail(int taskId) async {
    try {
      final request = TaskDetailRequest(taskId: taskId);
      final url = '$baseUrl/app/task/detail';
      final requestHeaders = await headers;
      final requestBody = jsonEncode(request.toJson());
      
      debugPrint('========== TASK DETAIL REQUEST ==========');
      debugPrint('URL: $url');
      debugPrint('Headers: $requestHeaders');
      debugPrint('Body: $requestBody');
      debugPrint('=========================================');

      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: requestBody,
      );
      
      debugPrint('========== TASK DETAIL RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('==========================================');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = ApiResponse<TaskDetailBO>.fromJson(
          jsonData,
          (data) => TaskDetailBO.fromJson(data),
        );
        return apiResponse;
      } else {
        return ApiResponse<TaskDetailBO>(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          statusCode: response.statusCode,
          message: '请求失败',
          error: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<TaskDetailBO>(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        statusCode: 500,
        message: '网络错误',
        error: e.toString(),
      );
    }
  }

  /// 认领工单
  static Future<ApiResponse<String>> claimTask(int taskId) async {
    try {
      final request = TaskClaimRequest(taskId: taskId);
      final url = '$baseUrl/app/task/claim';
      final requestHeaders = await headers;
      final requestBody = jsonEncode(request.toJson());
      
      debugPrint('========== CLAIM TASK REQUEST ==========');
      debugPrint('URL: $url');
      debugPrint('Body: $requestBody');
      debugPrint('========================================');

      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: requestBody,
      );
      
      debugPrint('========== CLAIM TASK RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('=========================================');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = ApiResponse<String>.fromJson(
          jsonData,
          (data) => data.toString(),
        );
        return apiResponse;
      } else {
        return ApiResponse<String>(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          statusCode: response.statusCode,
          message: '认领失败',
          error: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        statusCode: 500,
        message: '网络错误',
        error: e.toString(),
      );
    }
  }

  /// 变更工单状态
  static Future<ApiResponse<String>> changeTaskStatus(int taskId, String newStatus) async {
    try {
      final request = TaskChangeStatusRequest(
        taskId: taskId,
        newTaskStatus: newStatus,
      );
      final url = '$baseUrl/app/task/change-status';
      final requestHeaders = await headers;
      final requestBody = jsonEncode(request.toJson());
      
      debugPrint('========== CHANGE STATUS REQUEST ==========');
      debugPrint('URL: $url');
      debugPrint('Body: $requestBody');
      debugPrint('===========================================');

      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: requestBody,
      );
      
      debugPrint('========== CHANGE STATUS RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('============================================');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final apiResponse = ApiResponse<String>.fromJson(
          jsonData,
          (data) => data.toString(),
        );
        return apiResponse;
      } else {
        return ApiResponse<String>(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          statusCode: response.statusCode,
          message: '状态变更失败',
          error: 'HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        statusCode: 500,
        message: '网络错误',
        error: e.toString(),
      );
    }
  }
}
