import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/api_requests.dart';
import '../models/api_models.dart';

class TaskApiService {
  static const String baseUrl = 'http://localhost:7788';
  static const String userId = '1'; // 写死的用户ID

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-User-Id': userId,
  };

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

      final response = await http.post(
        Uri.parse('$baseUrl/task/list'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

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

      final response = await http.post(
        Uri.parse('$baseUrl/task/detail'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

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

      final response = await http.post(
        Uri.parse('$baseUrl/task/claim'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

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

      final response = await http.post(
        Uri.parse('$baseUrl/task/change-status'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

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
